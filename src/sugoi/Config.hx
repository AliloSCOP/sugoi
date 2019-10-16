package sugoi;

import sugoi.Web;

class Config {

	public var PATH :String;
	public var xml : Xml;
	public var LANG 		:String;
	public var LANGS 		:Array<String>;
	public var TPL 			:String;
	public var TPL_TMP 		:String;
	public var DEBUG 		:Bool;
	public var HOST 		:String;
	public var NAME 		:String;
	public var KEY 			:String;
	public var DATA_HOST 	:String;
	public var SQL_LOG 		:Bool;

	public function new(?path:String) {
		PATH = (path != null) ? path : sugoi.Web.getCwd() + "../";
		xml = Xml.parse(sys.io.File.getContent(PATH + "config.xml")).firstElement();
		
		LANG = get("lang");
		LANGS = get("langs").split(";");
		TPL = PATH + "lang/" + LANG + "/tpl/";
		TPL_TMP = PATH + "lang/" + LANG + "/tmp/";
		DEBUG = get("debug","0") == "1";
		HOST = get("host");
		NAME = get("name");
		KEY = get("key");
		DATA_HOST = get("dataHost","data."+HOST);
		SQL_LOG = getBool("sqllog", false);
	}
	
	public function defined( val : String ) {
		//return Reflect.field(xml,val) != null;
		return xml.get(val) != null;
	}

	public function getBool( val : String, ?def ) {
		var v = get(val);
		if( v == null ) return def;
		return( v == "1" || v == "true" );
	}

	public function get( val : String, ?def : String ) : String {
		//var v = Reflect.field(xml,val);
		var v = xml.get(val);
		if( v == null )
			v = def;
		if( v == null )
			throw "Missing config attribute : '"+val+"'";
		return v;
	}

	public function getInt( val : String, ?def : Int ) : Int {
		return Std.parseInt(get(val,Std.string(def)));
	}

}
