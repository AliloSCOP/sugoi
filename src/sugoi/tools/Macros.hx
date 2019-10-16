package sugoi.tools;
import haxe.macro.Context;
import haxe.macro.Expr;

class Macros {

	/**
	 * handles @tpl metas
	 */
	public static function buildController() {
		var fields = Context.getBuildFields();
		var changed = false;
		for( f in fields )
			for( m in f.meta )
				switch( m.name ) {
				case "tpl":
					if( m.params.length == 1 ){
						switch( m.params[0].expr ) {
						case EConst(c):
							switch(c) {
							case CString(s):
								// look for the template in the filesystem in all the paths
								/*var found = false;
								var cp = Context.getClassPath();
								cp.reverse();
								Context.warning(cp.join(" , "),m.pos);
								for ( path in cp) {
									//Context.warning(path + s+" "+sys.FileSystem.exists(path + s),m.pos);
									if ( sys.FileSystem.exists(path + s) ) {
										found = true;	
										break;
									}
								}

								if( !found ) Context.error("File not found '"+s+"'", m.params[0].pos);*/
								//Context.error("cwd "+, m.pos);
								var path = Sys.getCwd()+'../lang/master/tpl/';
								if( !sys.FileSystem.exists('$path$s') )
									Context.error('File not found "$path$s"', m.params[0].pos);
							default:
								Context.error("Invalid @tpl", m.pos);
							}
						default:
							Context.error("Invalid @tpl", m.pos);
						}
					}else{
						Context.error("Invalid @tpl", m.pos);
					}
				case "admin", "logged":
				
				default:
					if( m.name.charCodeAt(0) != "_".code )
						Context.error("Unknown metadata", m.pos);
				}
		return changed ? fields : null;
	}
	
	/**
	 * get compile date
	 */
	macro public static function getCompileDate() {
		return haxe.macro.Context.makeExpr(Date.now().toString(), haxe.macro.Context.currentPos());
	}
	
	macro public static function getFilePath(){
		var p = Context.getPosInfos(Context.currentPos());
		//voir Context.resolvePath()
		return haxe.macro.Context.makeExpr(p.file, Context.currentPos());
	}
	
	/**
	 * store classpathes at compilation time
	 */
	/*macro public static function getClassPathes() {
		return haxe.macro.Context.makeExpr(Context.getClassPath(), haxe.macro.Context.currentPos());
	}*/
	
}
