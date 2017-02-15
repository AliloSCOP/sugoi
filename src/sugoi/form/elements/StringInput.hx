package sugoi.form.elements;



class StringInput extends Input<String>
{
	

	
	override public function getTypedValue(str:String):String{
		str = StringTools.trim(str);
		if (str == "" || str==null) {
			return null;
		}else{
			return str;
		}
	}
	
}