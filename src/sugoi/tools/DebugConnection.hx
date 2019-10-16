package sugoi.tools;
import haxe.CallStack;

class DebugConnection implements sys.db.Connection {

	var cnx : sys.db.Connection;
	public var log : List<{ t : Int, sql : String, length : Int, bad : Bool, explain : String, stack : String }>;

	public function new(cnx) {
		this.cnx = cnx;
		log = new List();
	}

	static function isBadSql( explain : {
		select_type : String,
		rows : Int,
		type : String,
		id : Int,
		key : String,
		ref : String,
		Extra : String,
		table : String,
		possible_keys : String,
		key_len : Int,
		error : String,
	} ) {
		if( explain.error != null ) {
			if( StringTools.startsWith(explain.error,"EXPLAIN INSERT INTO") ||
				StringTools.startsWith(explain.error,"EXPLAIN UPDATE") ||
				StringTools.startsWith(explain.error,"EXPLAIN COMMIT")
			)
				return false;
			return true;
		}
		var t = if( explain.table != null ) Type.resolveClass("db."+explain.table) else null;
		if( t != null && (cast t).IGNORE_PERF_WARNING )
			return false;
		if( explain.Extra != null ) {
			if( ~/Using filesort/.match(explain.Extra) )
				return true;
			// SELECT LAST_INSERT_ID() and other constants
			if( ~/No tables used/.match(explain.Extra) )
				return false;
			// WHERE on not existing primary key
			if( ~/Impossible WHERE/.match(explain.Extra) )
				return false;
		}
		if( explain.type == "ALL" )
			return false;
		if( explain.key == null )
			return true;
		return false;
	}

	public function request( rq ) {
		var t = Sys.time();
		var r = cnx.request(rq);
		var explain = try cnx.request("EXPLAIN "+rq).next() catch( e : Dynamic ) { error : Std.string(e) };
		var buf = new StringBuf();
		for( f in Reflect.fields(explain) ) {
			buf.add(f);
			buf.add(" : ");
			buf.add(Reflect.field(explain,f));
			buf.add("\\n");
		}
		var s = CallStack.callStack();
		s.pop();
		if( rq.length > 100 ) {
			var rbig = ~/^(UPDATE Session SET.* data = )'(.*?)'([ ,])/;
			if( rbig.match(rq) )
				rq = rbig.matched(1)+"["+rbig.matched(2).split("\\0").join("\x00").length +" bytes]"+rbig.matched(3)+rbig.matchedRight();
		}
		log.add({
			t : Std.int((Sys.time() - t)*1000),
			sql : rq,
			length : r.length,
			bad : isBadSql(cast explain),
			explain : buf.toString().split("\\").join("\\\\").split("'").join("\\'").split("\r").join("\\r").split("\n").join("\\n"),
			stack : CallStack.toString(s).split("\\").join("\\\\").split("'").join("\\'").split("\r").join("\\r").split("\n").join("\\n")
		});
		return r;
	}

	public function close() {
		cnx.close();
	}

	public function startTransaction() {
		cnx.startTransaction();
	}

	public function commit() {
		cnx.commit();
	}

	public function rollback() {
		cnx.rollback();
	}

	public function dbName() {
		return cnx.dbName();
	}

	public function escape(s) {
		return cnx.escape(s);
	}

	public function quote(s) {
		return cnx.quote(s);
	}

	public function addValue(s:StringBuf,v:Dynamic) {
		cnx.addValue(s,v);
	}

	public function lastInsertId() {
		return cnx.lastInsertId();
	}

}
