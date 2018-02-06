package sugoi.plugin;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
/**
 * Base plugin class
 * @author fbarbut<francois.barbut@gmail.com>
 */
class PlugIn
{

	public var name :String;
	public var file :String;
	
	public function new() 
	{
		name = "Base Plugin";
		
	}
	
	/**
	 * create a simlink on windows/linux
	 * @param	link
	 * @param	target
	 */
	public function createSimLink(link:String, target:String) {
		
		if (Sys.systemName() == "Windows") {
			
			link = StringTools.replace(link,"/","\\");
			target = StringTools.replace(target,"/","\\");
			
			trace("mklink /D " +link+" "+target+"<br/>");
			//var p = new sys.io.Process("mklink /D", [link, target]);	
			//var p = new sys.io.Process("dir",[]);	
		}else {
			//linux
			new sys.io.Process("ln -s", [target, link]);
		}
	}
	
	/**
	 * copy plugins templates in lang/master/tpl/plugin at compilation time
	 */
	macro public static function copyTpl(){
		
		for (p in Context.getClassPath()){
			
			if (FileSystem.exists(p + "../haxelib.json")){
				
				// load sugoi.tpl param in haxelib json
				var hl = File.getContent(p + "../haxelib.json");
				var hl = haxe.Json.parse(hl);
				if (hl.sugoi != null){
					var from = FileSystem.fullPath(p + "../" + hl.sugoi.tpl + "/");
					var to = FileSystem.fullPath(Sys.getCwd() + "/lang/master/tpl/plugin/" + hl.sugoi.plugin + "/");
					copyDir( from , to );
				}
			}
		}
		return macro {};
	}
	
	/**
	 * recursive file copy
	 * @param	src
	 * @param	dest
	 */
	static function copyDir(src:String, dest:String){
		
		if (!FileSystem.exists(dest)) FileSystem.createDirectory(dest);
		
		for ( r in FileSystem.readDirectory(src)){
			
			if (FileSystem.isDirectory(src + r)) {
				copyDir(FileSystem.fullPath(src + r +"/"), FileSystem.fullPath(dest + r + "/"));					
			}else{
				
				var srcStat = FileSystem.stat(src + r);
				var destStat = FileSystem.stat(dest + r);
				//Context.warning(destStat.mtime.toString()+" == "+srcStat.mtime.toString(), Context.currentPos());
				if (srcStat.mtime.getTime() > destStat.mtime.getTime()){
					File.copy(src + r, dest + r);
					Context.warning("Bundle plugin tpl :" + r, Context.currentPos());
				}
				
			}
		}
		
	}
	
}