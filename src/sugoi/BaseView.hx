package sugoi;

import sugoi.db.Variable;
import sugoi.db.File;

class BaseView{

	var _vcache : Map<String,String>;
	var user : db.User;
	var session : sugoi.db.Session;
	var LANG : String;
	var HOST : String;
	var DATA_HOST : String;
	var DEBUG : Bool;
	var NAME : String;
	var isAdmin : Bool;
	var sqlLog : Array<Dynamic>;

	public function new() {
		_vcache = new Map();
	}

	public function init() {
		//copy fields of view into a dynamic 
		var view:Dynamic = {};
		var baseView = new View();
		for(field in Type.getInstanceFields(View)){
			Reflect.setField(view,field,Reflect.field(baseView,field));
		}

		var app = App.current;
		
		this.user = app.user;
		this.session = app.session;
		this.LANG = App.config.LANG;
		this.HOST = App.config.HOST;
		this.DATA_HOST = App.config.DATA_HOST;
		this.DEBUG = App.config.DEBUG;
		this.NAME = App.config.NAME;
		this.isAdmin = app.user != null && app.user.isAdmin();
		
		//Access basic functions in views
		//this.Std = Std;
		//this.Math = Math;
		
		
		if ( App.config.SQL_LOG  ) {			
			this.sqlLog = untyped app.cnx == null ? null : app.cnx.log;
		}
	}
	
	function getMessage() {
		var session = App.current.session;
		if ( session == null ) return null;
		if (session.messages == null) return null;
		var n = session.messages.pop();
		if( n == null ) return null;
		return { text : n.text, error : n.error, next : session.messages.length > 0 };
	}
	

	function getMessages() {
		var out = [];
		var session = App.current.session;
		if ( session == null ) return [];
		if (session.messages == null) return [];
		
		for ( m in session.messages) {
			if( m == null ) continue;
			out.push( { text : m.text, error : m.error } );
		}
		session.messages = [];
		return out;
	}
	

	function urlEncode(str:String) {
		return StringTools.urlEncode(str);
	}
	
	/**
	 * To safely print a string in javascript
	 * @param	str
	 */
	public function escapeJS( str : String ) {
		if (str == null) return "";
		return str.split("\\").join("\\\\").split("'").join("\\'").split("\r").join("\\r").split("\n").join("\\n");
	}
	
	/**
	 * Get a value from the Variable table
	 * @param	file
	 */
	function getVariable( file : String ) {
		
		var v = _vcache.get(file);
		if( v != null )
			return v;
		if( App.current.maintain )
			return "";
		v = Variable.get(file);
		if( v == null ) v = "";
		_vcache.set(file,v);
		return v;
	}

	function getParam( p : String ) {
		if(App.current==null || App.current.params==null) return null;
		return App.current.params.get(p);
	}
	
	/**
	 * Return the url of a db.File record
	 */
	public function file( file : sugoi.db.File):String {
		if (file == null) return "";
		return "/file/"+sugoi.db.File.makeSign(file.id)+"."+file.getExtension();
	}
	
	/**
	 * Try to print an HTML table from any kind of object
	 * @param	data
	 */
	function table(data:Dynamic) {
		return new sugoi.helper.Table("table table-bordered").toString(data);
	}
	
	/**
	 * newline to <br/>
	 * @param	txt
	 */
	public function nl2br(txt:String):String {	
		if (txt == null) return "";
		return txt.split("\n").join("<br/>");		
	}


	public function _(str:String):String {
		if (sugoi.i18n.Locale.texts != null) {
			return sugoi.i18n.Locale.texts.get(str);
		} else {
			return str;
		}
	}
	
	//same function with params ( templo doesnt manage optionnal params in functions )
	public function __(str:String, params:Dynamic){
		return sugoi.i18n.Locale.texts.get(str, params);
	}
/*
#else
	public function _(str:String):String {
		neko.Web.logMessage("_call "+str);
		return StringTools.rtrim( str.split("||")[0] );
	}
	
	//same function with params ( templo doesnt manage optionnal params in functions )
	public function __(str:String, params:Dynamic):String {
		neko.Web.logMessage("_call "+str);
		str = StringTools.rtrim( str.split("||")[0] );
		var list = str.split("::");
		if(params != null) {
			for (k in Reflect.fields(params)) {
				str = StringTools.replace(str, "::" + k + "::", Reflect.field(params, k));
			}
		}
		return str;
	}
#end
*/

	public function loopList(start:Int,end:Int):List<Int> {
		var list = new List<Int>();
		for (i in start...end) {
			list.add(i);
		}
		return list;
	}
	
}
