package sugoi.db;
import sys.db.Types;

@:id(name)
class Variable extends sys.db.Object {

	public var name : SString<50>;
	public var value : SString<50>;

	public static function get( name ) {
		var v = manager.get(name,false);
		return v == null ? null : v.value;
	}
	
	public static function set(name, val:Dynamic) {
		var v = Variable.manager.get(name,true);
		if (v==null) {
			v = new Variable();
			v.name = name;
			v.value = Std.string(val);
			v.insert();
		}
		else {
			v.value = Std.string(val);
			v.update();
		}
	}

	public static function increment(name, ?inc=1) {
		var v = Variable.manager.get(name,true);
		if (v==null) {
			v = new Variable();
			v.name = name;
			v.value = Std.string(inc);
			v.insert();
		}
		else {
			v.value = Std.string(Std.parseInt(v.value)+1);
			v.update();
		}
	}
	
	public static function getInt( name ) {
		var v = manager.get(name,false);
		return v == null ? 0 : Std.parseInt(v.value);
	}

}
