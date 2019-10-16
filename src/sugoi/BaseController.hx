package sugoi;
import sugoi.db.File;
import sugoi.Web;
import sugoi.ControllerAction;

@:autoBuild(sugoi.tools.Macros.buildController())
class BaseController {

	var app : App;
	var view : Dynamic;
	
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
	 * User uploaded images are stored in the db.File table.
	 * When there is an attempt to display an image like /file/***.jpg
	 * the .htaccess in /file/ redirects to this handler to generate the file from the DB
	 * @param	fname
	 */
	function doFile( fname : String ) {
		
		//get the file from DB
 		var fid = Std.parseInt(fname); 
		var f = File.manager.get(fid, false);
		var ext = fname.substr( fname.lastIndexOf(".") );//.png
		if( f == null ) {
			Sys.print("404 - File not found '"+StringTools.htmlEscape(fname)+"' id #"+fid);
			return;
		}
		if ( fname != File.makeSign(fid) + ext ){
			Sys.print("404 - File signature do not match '"+fname+"' != '"+File.makeSign(fid)+ ext+"'");
			return;
		}
		var path;
		var ch;
		try {
			path = Web.getCwd()+"/file/"+File.makeSign(f.id)+ext;
			ch = sys.io.File.write(path,true);
		} catch( e : Dynamic ) {
			Sys.sleep(0.1); // wait for another process to write ?
			Web.redirect(Web.getURI()+"?retry=1");
			return;
		}
		ch.write(f.data);
		ch.close();

		try {
			// get mtime of current index.n
			#if neko
			var s = sys.FileSystem.stat(Web.getCwd() + "index.n");
			#else
			var s = sys.FileSystem.stat(Web.getCwd() + "index.php");
			#end
			var mtime = s.mtime.toString();

			// set mtime of new file
			var p = new sys.io.Process("touch",["-m","-d",mtime,path]);
			p.exitCode();
		}catch( e : Dynamic ){
		}

		Web.redirect(Web.getURI()+"?reload=1");
	}
	

}