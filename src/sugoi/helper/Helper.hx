package mt.net.helper;

class Helper {

	/**
	 * Init all helpers in applicatio view.
	 */
	public static function init(context:Dynamic, viewHelpers:Array<Dynamic>) {
		/* gros paté (c) ncannasse */
		for(vh in viewHelpers) {
			var methodName = Type.getClassName(Type.getClass(vh)).split(".").pop().toLowerCase();
			var toString = Reflect.field(vh, "toString");
			var nargs : Int = untyped $nargs(toString);
			Reflect.setField(context, methodName , Reflect.makeVarArgs(function(p:Array<Dynamic>) {
				while( p.length < nargs ) p.push(null);
				return Reflect.callMethod(vh, toString, p);
			}));
		}
	}
	
}