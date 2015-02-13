package sugoi.db;
import sys.db.Types;
import db.User;

@:id(sid)
@:index(uid,unique)
class Session extends sys.db.Object {

	public var sid : SString<32>;
	public var ip : SString<15>;
	public var lang : SString<2>;
	public var messages : SData<Array<{ error : Bool, text : String }>>;
	public var lastTime : SDateTime;
	public var createTime : SDateTime;
	
	public var sdata : SNekoSerialized;
	@:skip public var data : Dynamic;

	@:relation(uid)
	public var user : SNull<db.User>;
	public var uid : SNull<SInt>;
	

	public function new() {
		super();
		messages = [];
		data = { };
		
	}
	
	/**
	 * Stores a message in session
	 */
	public function addMessage( text : String, ?error=false ) {
		messages.push({ error : error, text : text });
	}
	
	
	public function setUser( u : User ):Void {		
		if ( uid != u.id ) {
			//remove any previous session for this user
			manager.delete({ uid : u.id });
		}
		lang = u.lang;
		user = u;
	}

	public override function update() {
		sdata = neko.Lib.serialize(data);
		lastTime = Date.now();
		super.update();
	}

	private static function get( sid:String ):Session {
		if ( sid == null ) return null;
				
		var s = manager.get(sid,true);
		if ( s == null ) return null;
		try{
			s.data = neko.Lib.localUnserialize(s.sdata);
		}catch (e:Dynamic) {
			s.data = null;
		}
		
		return s;
	}


	public static function init( sids : Array<String> ) {
		for( sid in sids ) {
			var s = get(sid);
			if( s != null ) return s;
		}
		var ip = neko.Web.getClientIP();
		var s = new Session();
		s.ip = ip;
		s.createTime = Date.now();
		s.lastTime = Date.now();
		
		s.sid = generateId();
		var count = 20;
		while( try { s.insert(); false; } catch( e : Dynamic ) true ) {
			s.sid = generateId();
			// prevent infinite loop in SQL error
			if( count-- == 0 ) {
				s.insert();
				break;
			}
		}
		
		return s;
	}
	
	/**
	 * Generate a random 32 chars string
	 */
	public static var S = "abcdefjhijklmnopqrstuvwxyABCDEFJHIJKLMNOPQRSTUVWXYZ0123456789";
	public static function generateId():String {
		
		var id = "";
		for ( x in 0...32 ) {			
			id += S.substr(Std.random(S.length),1);
		}
		return id;
	}
	
	/**
	 * Delete sessions older than 1 month
	 */
	public static function clean() {
		manager.delete($lastTime < DateTools.delta(Date.now(),-1000.0*60*60*24*30));
	}

}
