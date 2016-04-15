package sugoi.form.elements;

/**
 * ...
 * @author fbarbut
 */
class StringSelect extends Selectbox<String>
{

	override function getTypedValue(str:String){
		str = StringTools.trim(str);
		if (str == "" || str==null) {
			return null;
		}else{
			return str;
		}
	}
	
}