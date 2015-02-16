package sugoi;

import sugoi.db.File;

enum ControllerAction {
	RedirectAction( url : String );
	ErrorAction( url : String, ?text : String );
	OkAction( url : String, ?text : String );
}

@:autoBuild(sugoi.tools.Macros.buildController())
class BaseController {

	var app : App;
	var view : View;
	
	public function new() {
		app = App.current;
		view = app.view;
	}
	
	function getParam( v : String ) {
		return app.params.get(v);
	}

	
	function checkToken():Bool {
		var token = haxe.crypto.Md5.encode(app.session.sid + App.config.KEY.substr(0,6));
		view.token = token;
		return app.params.get("token") == token;
	}

	function isAdmin() {
		return app.user != null && app.user.isAdmin();
	}
	
	public function Redirect( url : String ) {
		return RedirectAction(url);
	}
	
	public function Error( url : String, ?text : String ) {
		return ErrorAction(url, text);
	}

	public function Ok( url : String, ?text : String ) {
		return OkAction(url, text);
	}
	
	
	
	/**
	 * Generate files from db.File
	 * @param	fname
	 */
	function doFile( fname : String ) {
 		var fid = Std.parseInt(fname);
		
		var f = File.manager.get(fid, false);
		var ext = fname.substr(fname.length - 4);//.png
		if( f == null || fname != File.makeSign(fid)+ext ) {
			neko.Lib.print("404 - File not found '"+StringTools.htmlEscape(fname)+"'");
			return;
		}
		var path;
		var ch;
		try {
			path = neko.Web.getCwd()+"/file/"+File.makeSign(f.id)+ext;
			ch = sys.io.File.write(path,true);
		} catch( e : Dynamic ) {
			Sys.sleep(0.1); // wait for another process to write ?
			neko.Web.redirect(neko.Web.getURI()+"?retry=1");
			return;
		}
		ch.write(f.data);
		ch.close();

		try {
			// get mtime of current index.n
			var s = sys.FileSystem.stat(neko.Web.getCwd()+"index.n");
			var mtime = s.mtime.toString();

			// set mtime of new file
			var p = new sys.io.Process("touch",["-m","-d",mtime,path]);
			p.exitCode();
		}catch( e : Dynamic ){
		}

		neko.Web.redirect(neko.Web.getURI()+"?reload=1");
	}

}