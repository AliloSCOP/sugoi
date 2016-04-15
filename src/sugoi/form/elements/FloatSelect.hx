package sugoi.form.elements;

/**
 * ...
 * @author fbarbut
 */
class FloatSelect extends Selectbox<Float>
{

	override function getTypedValue(str:String):Float{
		str = StringTools.trim(str);
		if (str == "" || str==null) {
			return null;
		}else{
			return Std.parseFloat(str);
		}
	}
	
}