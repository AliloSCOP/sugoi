package sugoi.form.elements;



class IntInput extends Input<Int>
{
	
	public function new(name, label, value, ?required=false){
		super(name, label, value, required);
	}
	
	override public function getTypedValue(str:String):Int{
		if(str!=null) str = StringTools.trim(str);
		
		if (str == "" || str==null) {
			
			if (this.required){
				return 0;				
			}else{
				return null;
			}
			
			
		}else{
			var v = Std.parseInt(str);
			
			if (v == null){
				if (this.required){
					return 0;		
				}else{
					return null;
				}
			}else{
				return v;
			}
		}
	}
	
}