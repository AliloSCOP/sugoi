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
		this.LANG = App.App.config.LANG;
		this.HOST = App.App.config.HOST;
		this.DATA_HOST = App.App.config.DATA_HOST;
		this.DEBUG = App.App.config.DEBUG;
		this.NAME = App.App.config.NAME;
		this.isAdmin = app.user != null && app.user.isAdmin();
		if ( App.App.config.SQL_LOG  ) {			
			this.sqlLog = untyped app.cnx == null ? null : app.cnx.log;
		}
	}
	

	function getMessages() {
		var session = App.current.session;
		if ( session == null ) return null;
		if (session.messages == null) return null;
		var n = session.messages.pop();
		if( n == null ) return null;
		return { text : n.text, error : n.error, next : session.messages.length > 0 };
	}
	

	function urlEncode(str:String) {
		return StringTools.urlEncode(str);
	}
	
	/**
	 * To safely print a string in javascript
	 * @param	str
	 */
	public function escapeJS( str : String ) {
		return str.split("\\").join("\\\\").split("'").join("\\'").split("\r").join("\\r").split("\n").join("\\n");
	}
	
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
	 * Return the filename of db.File record
	 */
	function file( id : Int ) {
		return File.makeSign(id);
	}
	
	
}
