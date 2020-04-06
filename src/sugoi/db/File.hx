package sugoi.db;
import sys.db.Manager;
import sys.db.Types;

/**
 * Store files in DB
 */
 @:index(cdate)
class File extends sys.db.Object {
	
	public var id : SId;
	public var name : STinyText; 		 //filename
	public var cdate : SDateTime; //creation datetime
	public var data : SBinary;
	
	@:skip
	static var CACHE = [];

	override public function new(){
		super();
		cdate = Date.now();
	}
	
	/**
	 * Get the file name related to this File record.
	 * Usually files should be generated in /file/
	 */
	public static function makeSign( id : Int ) {
		if( id == null )
			return "";
		var s = CACHE[id];
		if( s != null ) return s;
		s = id+"_"+haxe.crypto.Md5.encode(id + App.config.get('key'));
		CACHE[id] = s;
		return s;
	}
	
	public override function toString() {
		return "#" + id + " " + name;
	}
	
	/**
	 * Creates a File record
	 * from string data (typically sent from a form) and a file name
	 */
	public static function create(stringData:String, ?fileName=""):File {
		
		var bytes = new haxe.io.StringInput(stringData).readAll();
		return createFromBytes(bytes, fileName);
		
	}
	
	
	public static function createFromBytes(b:haxe.io.Bytes, ?fileName=""):File {
		
		#if neko
		var f = new File();
		f.name = fileName;		
		f.data = b;
		f.insert();
		return f;
		#else
		//there is a bug in PHP, we do it manually		
		var hexa = b.toHex();
		Manager.cnx.request("INSERT INTO File (name,data) VALUES ('"+fileName+"', 0x"+hexa+")");
		return File.manager.select($name==fileName);
		#end
		
	}

	public static function createFromDataUrl(dataUrl:String,?fileName=""){		
		dataUrl = dataUrl.substr( "data:image/png;base64,".length );
		var b = haxe.crypto.Base64.decode(dataUrl);
		/*
		//DEBUG
		var path = sugoi.Web.getCwd()+"../tmp/_image.png";
		File.saveBytes(path , b);*/
		return createFromBytes(b, fileName);		
	}
	
	public function getExtension():String {
		if (name == null || name=="") return "png";		
		return name.split(".")[1];
	}
	
}
