package sugoi.form.elements;

/**
 * ...
 * @author fbarbut
 */
class IntSelect extends Selectbox<Int>
{

	override function getTypedValue(str:String):Int{
		str = StringTools.trim(str);
		if (str == "" || str==null) {
			return null;
		}else{
			return Std.parseInt(str);
		}
	}
	
}