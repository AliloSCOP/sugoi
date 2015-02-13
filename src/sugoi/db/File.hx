package sugoi.db;
import sys.db.Types;

/**
 * Store files in DB
 */
class File extends sys.db.Object {

	public var id : SId;
	public var name : STinyText;
	public var comment : STinyText;
	public var data : SBinary;
	
	static var CACHE = [];
	
	/**
	 * Get the file name related to this File record.
	 * Usually files should be generated in /file/
	 */
	public static function makeSign( id : Int ) {
		if( id == null )
			return "";
		var s = CACHE[id];
		if( s != null ) return s;
		s = id+"_"+haxe.crypto.Md5.encode(id + App.App.config.get('key'));
		CACHE[id] = s;
		return s;
	}
	
	public override function toString() {
		return "#" + id + " " + name;
	}
	
	/**
	 * Creates a File record
	 * from data (typically sent from a form) and a file name
	 */
	public static function create(stringData:String, ?fileName=""):File {
		
		var f = new File();
		f.name = fileName;
		f.data = new haxe.io.StringInput(stringData).readAll();
		f.insert();
		return f;
		
	}
	
}