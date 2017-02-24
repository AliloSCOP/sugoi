package sugoi.form.elements;

/**
 * ...
 * @author fbarbut
 */
class IntSelect extends Selectbox<Int>
{

	override function getTypedValue(str:String):Int{
		
		if (str != null) str = StringTools.trim(str);
		
		if (str==null || str=="") {
			return null;
		}else{
			return Std.parseInt(str);
		}
	}
	
}