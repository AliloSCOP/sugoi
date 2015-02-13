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
								if( !sys.FileSystem.exists("lang/fr/tpl/"+s) )
									Context.error("File not found '"+s+"'", m.params[0].pos);
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
	
}
