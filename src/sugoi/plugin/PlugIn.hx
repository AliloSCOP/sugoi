package sugoi.plugin;
import haxe.macro.Context;
import haxe.macro.Expr;
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
	
	
	
	
}