package sugoi.db;
import sys.db.Types;

/**
 * Key-Value temporary storage in a Memcached style
 */
@:id(name)
class Cache extends sys.db.Object
{
	public var name : SString<128>;
	public var value : SText;
	public var expire : SDateTime;
	public var cdate : SNull<SDateTime>;
	
	public function new(){
		super();
		cdate = Date.now();
	}
	
	/**
	 * Read the value for key $id
	 */
	public static function get(id:String):Dynamic {
		if (Std.random(1000) == 0) Cache.manager.delete($expire < Date.now());
		
		var c = manager.get(id, true);
		if (c == null) return null;
		if (c.expire.getTime() < Date.now().getTime()) {
			c.delete();
			return null;
		}
		return haxe.Unserializer.run(c.value);
	}
	
	/**
	 * Set a value for key $id 
	 * and optionnaly a lifetime in seconds
	 */
	public static function set(id:String, value:Dynamic,expireInSeconds:Float) {
		var c = manager.get(id, true);
		var niou = false;
		if (c == null) {
			niou = true;
			c = new Cache();			
			c.name = id;
		}
		c.value = haxe.Serializer.run(value);
		c.expire = DateTools.delta(Date.now(), expireInSeconds*1000.0);
		if (niou) {
			c.insert();
		}else {
			c.update();
		}
	}
	
	/**
	 * Delete a value for key $id
	 */
	public static function destroy(id:String) {
		var c = manager.get(id, true);
		if (c != null) c.delete();
	}
	
	
}