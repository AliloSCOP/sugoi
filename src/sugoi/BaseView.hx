package sugoi;

import sugoi.db.Variable;
import sugoi.db.File;

class BaseView implements Dynamic {

	var _vcache : Map<String,String>;

	public function new() {
		_vcache = new Map();
	}

	public function init() {
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
		this.Std = Std;
		this.Math = Math;
		
		
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
		return App.current.params.get(p);
	}
	
	/**
	 * Return the url of a db.File record
	 */
	public function file( file : sugoi.db.File) {
		if (file == null) throw "file is null";
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
	
	/**
	 * Live translation function
	 * @param	str
	 * @param	params
	 */
	public function _(str:String){
		return sugoi.i18n.Locale.texts.get(str);
	}
	
	//same function with params ( templo doesnt manage optionnal params in functions )
	public function __(str:String, params:Dynamic){
		return sugoi.i18n.Locale.texts.get(str, params);
	}
	
	
}
