package sugoi;
import sugoi.i18n.TemplateTranslator;
import sugoi.Web;

class BaseApp {

	public var cnx			: sys.db.Connection;
	public var template		: templo.Loader;
	public var maintain		: Bool;
	public var session		: sugoi.db.Session;
	public var view 		: Dynamic;
	public var user    		: db.User;
	public var params 		: Map<String,String>;
	public var cookieName	: String;
	public var cookieDomain	: String;
	public var uri 			: String;
	
	public static var config: Config;
	//public static var classPathes = sugoi.tools.Macros.getClassPathes();

	public var headers : Map<String,String>;
	public static var defaultHeaders = [
		"Pragma"=>"no-cache",
		"Cache-Control"=>"no-store, no-cache, must-revalidate",
		"Expires"=>"-1",
		"P3P"=>"CP=\"ALL DSP COR NID CURa OUR STP PUR\"",
		"Content-Type"=>"text/html; Charset=UTF-8",
		//"Expires"=>"Mon, 26 Jul 1997 05:00:00 GMT"
	];

	public function new() {
		
		if (config == null) {
			loadConfig();
		}
		
		cookieName = "sid";
		cookieDomain = App.config.get("cookie_domain") == null ? "." + App.config.HOST : App.config.get("cookie_domain");

		//populate default headers
		headers = new Map<String,String>();
		for(k in BaseApp.defaultHeaders.keys() ) {
			headers.set(k,BaseApp.defaultHeaders.get(k));
		}
		
		#if plugins
		if( false ) sugoi.plugin.PlugIn.copyTpl();
		#end
		
		// This macro generates translated templates for each langage
		#if i18n_generation
		if( false ) TemplateTranslator.parse("../lang/master");
		#end
	}
	
	public function loadConfig() {
		App.config = BaseApp.config = new sugoi.Config();	
	}

	public function loadTemplate( t : String ) {
		templo.Loader.OPTIMIZED = App.config.DEBUG == false;
		templo.Loader.BASE_DIR = App.config.TPL;
		templo.Loader.TMP_DIR = App.config.TPL_TMP;
		if ( t == null ) return null;		
		#if neko
		return new templo.Loader(t, App.config.getBool("cachetpl"));		
		#else
		return new templo.Loader(t);		
		#end
	}

	public function setTemplate( t : String ) {
		template = t == null ? null : loadTemplate(t);
	}

	public function initLang( lang : String ) {
		
		if (lang == null || lang == "") lang = config.LANG;
		
		//Define template path
		var path;
		if (!App.config.DEBUG){
			path = Web.getCwd() + "../lang/" + lang + "/";
		}else{
			path = Web.getCwd() + "../lang/master/";
		}

		App.config.TPL = path + "tpl/";
		App.config.TPL_TMP = path + "tmp/";
		
		//init system locale
		if ( !Sys.setTimeLocale("en_US.UTF-8") ) {			
			Sys.setTimeLocale("en");
		}
		
		//init gettext translator
		sugoi.i18n.Locale.init(lang);
		
		return true;
	}

	function saveAndClose() {
		
		if( cnx == null ) return;
		if( session.sid != null )
			session.update();
		
		cnx.commit();
		cnx.close();
		untyped cnx.close = function() {}
		untyped cnx.request = function(s) return null;
	}

	function executeTemplate( ?save ) {
		view.init();
		var result = template.execute(view);
		if ( save ) saveAndClose();
		#if php
		//strange bug with templo in PHP
		if (result.substr(0, 4) == "null") result = result.substr(4);
		#end
		Sys.print(result);
	}

	function onMeta( m : String, args : Array<Dynamic> ) {
		switch( m ) {
		case "tpl":
			setTemplate(args[0]);
		case "logged":
			if ( user == null )				
				throw sugoi.ControllerAction.RedirectAction("/?__redirect="+Web.getURI());
		case "admin":
			#if neko
			//allow to call admin actions thru CLI to perform migrations
			if (!sugoi.Web.isModNeko && !sugoi.Web.isTora) return;
			#end
			if( user == null || !user.isAdmin() ){				
				throw sugoi.ControllerAction.RedirectAction("/");
			}
				
		default:
		}
	}

	/**
	 * Detect lang from HTTP headers
	 */
	function detectLang() {
		var l = Web.getClientHeader("Accept-Language");
		if( l != null )
			for( l in l.split(",") ) {
				l = l.split(";")[0];
				l = l.split("-")[0];
				l = StringTools.trim(l);
				for( a in App.config.LANGS )
					if( a == l )
						return a;
			}
			
		return App.config.LANG;
	}
	
	
	/**
	 * Setup current app language
	 */
	function setupLang() {
		
		//this app is monolingual and doesn't manage i18n
		if (App.config.LANG == "master") return;
		
		//lang is taken from user object or from HTTP headers
		if ( session.lang == null || !Lambda.has(App.config.LANGS, session.lang) ){			
			session.lang = (user == null) ? detectLang() : user.lang;
		}
		
		//override if param is given
		var lang = params.get("lang");
		if ( lang != null && Lambda.has(App.config.LANGS, lang) ){
			session.lang = lang;
			
		}
			
		//init lang			
		initLang(session.lang);
	}
	
	/**
	 * Get current application langage (2 letters lowercase)
	 */
	public function getLang(){
		return (session != null && session.lang != null && session.lang != "") ? session.lang : App.config.LANG;
	}

	public function rollback() {
		if( cnx != null ) cnx.rollback();
		sys.db.Manager.cleanup();
		if( user != null && session != null )
			user = session.user;
		// does not reset session
	}

	public function setCookie( oldCookie : String ){
		if( session != null && session.sid != null && session.sid != oldCookie ) {
			Web.setHeader("Set-Cookie", cookieName+"=" + session.sid + "; path=/;" + " domain=" + cookieDomain + ";" + "Max-Age=2629746;");
		}
	}

	function mainLoop() {
		params = Web.getParams();
		
		//Get session
		var sids = [];
		var cookieSid = Web.getCookies().get(cookieName);
		if( params.exists("sid") ) sids.push(params.get("sid"));
		if( cookieSid != null ) sids.push(cookieSid);
		session = sugoi.db.Session.init(sids);
		
		//Check for maintenance
		maintain = sugoi.db.Variable.getInt("maintain") != 0;
		user = session.user;
		
		//setup langage
		setupLang();
		
		//bypass maintenance for admins		
		if( maintain && (user != null && user.isAdmin()) ){
			maintain = false;
		}

		#if neko
		//allow to call admin actions thru CLI to perform migrations
		if( maintain && !sugoi.Web.isModNeko && !sugoi.Web.isTora ){
			maintain = false;
		}
		#end			
		
		setCookie(cookieSid);
		
		if( maintain ) {
			setTemplate("maintain.mtt");
			executeTemplate();
			return;
		}
		
		//dispatching
		try {
			
			uri = Web.getURI();
			if ( StringTools.endsWith(uri, "/index.n") ) uri = uri.substr(0, -8);
			
			//"before dispatch" callback
			beforeDispatch();
			
			var d = new haxe.web.Dispatch(uri, params);
			d.onMeta = onMeta;
			d.dispatch(new controller.Main());
			
		} catch ( e : haxe.web.Dispatch.DispatchError ) {
			
			//dispatch / routing error
			if ( App.config.DEBUG )	{
				#if neko
				neko.Lib.rethrow(e);
				#else
				php.Lib.rethrow(e);
				#end
			}
			cnx.rollback();
			Web.redirect("/");
			return;
			
		} catch ( e : sugoi.ControllerAction) {
			
			switch( e ) {
			case RedirectAction(url):
				Web.redirect(url);
				template = null;
			case ErrorAction(url, text), OkAction(url,text):
				if( text == null ) {
					text = url;
					url = Web.getURI();
				}
				Web.redirect(url);
				var error = switch(e) { case ErrorAction(_): true; default: false; };
				if( error ) rollback();
				if ( error ) {					
					session.addMessage(text,true);
				}else {					
					session.addMessage(text);
				}
				template = null;
			}
		}
		
		//Render template
		if ( template == null ) {			
			saveAndClose();
		} else {			
			executeTemplate(true); // will saveAndClose
		}
	}
	
	/**
	 * Override this function if you want 
	 * to insert some actions 
	 */
	public function beforeDispatch() {
		
	}

	public function logError( e : Dynamic, ?stack : String ) {
		var stack = if( stack != null ) stack else haxe.CallStack.toString(haxe.CallStack.exceptionStack());
		var message = new StringBuf();
		message.add(Std.string(e));
		message.add("\n");
		message.add(stack);
		message.add("\n");
		var e = new sugoi.db.Error();
		e.url = Web.getURI();
		e.ip = Web.getClientIP();
		e.user = if( user != null ) user else null;
		e.date = Date.now();
		e.userAgent = Web.getClientHeader("User-Agent");
		e.error = message.toString();
		e.insert();
	}

	function errorHandler( e:Dynamic ) {
		try {
			var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
			// ROLLBACK and LOG
			if ( cnx != null ) {
				cnx.rollback();
				logError(e,stack);
			}
			
			//log also in a file, in case we don't have a valid connexion to DB
			Web.logMessage(e+"\n" + stack);
			
			maintain = true;
			view = new View();

			//Exception can be a string, Enum, Array or tink.core.Error
			if(Std.is(e,tink.core.Error)){
				view.exception = e; 
			}else{
				view.message = Std.string(e);
			}
			
			if ( App.config.DEBUG || (user != null && user.isAdmin()) ) {				
				view.stack = stack;
			}
				
			setTemplate("error.mtt");
			executeTemplate(false);
			
		} catch( e : Dynamic ) {
			Sys.print("<pre>");
			Sys.println("Error : "+try Std.string(e) catch( e : Dynamic ) "???");
			Sys.println(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			try {
				if( cnx != null )
					sugoi.db.Error.manager.get(0,false);
			} catch( e : Dynamic ) {
				Sys.println("Initializing Database...");
				sys.db.admin.Admin.initializeDatabase();
				Sys.println("Done");
			}
			Sys.print("</pre>");
		}
	}

	/**
	 * init template engine
	 * and db connexion
	 */
	function init() {
		maintain = App.config.getBool("maintain");
		if( maintain ) {
			view = new View();
			setTemplate("maintain.mtt");
			executeTemplate(false);
			return false;
		}
		try {
			var dbstr = App.config.get("database");
			var dbreg = ~/([^:]+):\/\/([^:]+):([^@]*?)@([^:]+)(:[0-9]+)?\/(.*?)$/;
			if( !dbreg.match(dbstr) )
				throw "Configuration requires a valid database attribute, format is : mysql://user:password@host:port/dbname";
			var port = dbreg.matched(5);
			var dbparams = {
				user:dbreg.matched(2),
				pass:dbreg.matched(3),
				host:dbreg.matched(4),
				port:port == null ? 3306 : Std.parseInt(port.substr(1)),
				database:dbreg.matched(6),
				socket:null
			};
			cnx = sys.db.Mysql.connect(dbparams);
		} catch( e : Dynamic ) {
			errorHandler(e);
			return false;
		}
		if( App.config.SQL_LOG )
			cnx = new sugoi.tools.DebugConnection(cnx);
		return true;
	}

	function cloneApp() {
		// ensure that we have no variable initialized in app loop
		var app = new App();
		var bapp : BaseApp = app;
		bapp.cnx = cnx;
		bapp.view = new View();
		App.current = app;
		bapp.mainLoop();
	}

	function run() {

		// Will close the connection
		sys.db.Transaction.main(cnx, cloneApp, function(e) { var b : BaseApp = App.current; b.errorHandler(e); });
		App.current = null;
	}

	/**
		Send HTTP headers defined in this.headers
	**/
	function sendHeaders(){
		for(k in headers.keys() ) {
			Web.setHeader(k,headers.get(k));
		}
	}

	static function main() {
		
		/**
		 * this macro will parse the code and generate the allTexts.pot file
		 * which will be used as a template for translation files (*.po and *.mo)
		 */
		#if i18n_parsing
		if( false ) sugoi.i18n.GetText.parse(["../src", "../lang/master","../js","../common"], "../www/lang/allTexts.pot");
		#end
		
		App.current = new App();
		var a : BaseApp = App.current;
		
		a.sendHeaders();

		if( !a.init() ) {
			a = null;
			return;
		}
		a.run();
		a = null;
		#if neko
		if ( App.config.getInt("cache", 0) == 1 ) {			
			neko.Web.cacheModule(App.main);
		}
		#end
	}
}
