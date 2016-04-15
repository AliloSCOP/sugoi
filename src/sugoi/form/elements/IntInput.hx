package sugoi.form.elements;



class IntInput extends Input<Int>
{
	
	public function new(name, label, value, ?required=false){
		super(name, label, value, required);
	}
	
	override public function getTypedValue(str:String):Int{
		str = StringTools.trim(str);
		if (str == "" || str==null) {
			return null;
		}else{
			return Std.parseInt(str);
		}
	}
	
}