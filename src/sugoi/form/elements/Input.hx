package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;
import sugoi.form.Validator;
import sugoi.form.validators.BoolValidator;
import sugoi.form.Formatter;

using StringTools;

enum InputType{
	ITText;
	ITPassword;
	ITHidden;
}

class Input<T> extends FormElement<T>
{
	public var password:Bool;
	public var disabled:Bool;
	public var showLabelAsDefaultValue:Bool;
	public var printRequired:Bool;
	
	public var formatter:Formatter;
	public var inputType : InputType;
	
	public function new(name:String, label:String, ?value:T, ?required=false, ?validators:Array<Validator>, ?attributes="")
	{
		super();
		this.name = name;
		this.label = label;
		this.value = value;
		this.required = required;
		this.attributes = attributes;
		this.password = false;
		this.disabled = false;
		inputType = ITText;
		
		printRequired = false;
		if(Form.USE_TWITTER_BOOTSTRAP) cssClass = "form-control";
		
		//trace("value of " + name+" is " + value+" of type " + Type.typeof(value) + "<br/>");
		//trace("disabled " + disabled);
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		var tType = switch(inputType){
			case ITHidden: "hidden";
			case ITPassword : "password" ;
			case ITText : "text" ;
		}
		
		return "<input class=\""+ getClasses() +"\" type=\""+tType+"\" name=\""+n+"\" id=\""+n+"\" value=\"" +safeString(value)+ "\"  "+attributes+" "+ (disabled?"disabled":"")+"/>" + ((required && parentForm.isSubmitted() && printRequired)?" required":"") ;
	}
	
	//override public function getTypedValue(str:String):T{
		
		//if (str == "" || str==null) {
			//trace("value is null<br/>");
			//return null;
		//}
		//
		//str = StringTools.trim(str);
		//
		//trace(Type.typeof(value)+"<br/>");
		//switch(Type.typeof(value)){
			//case Type.ValueType.TBool :
				//var r : Bool = (str == "1");
				//return cast r;
			//case Type.ValueType.TFloat :
				//var r:Float = Std.parseFloat(str);
				//return cast r;
			//case Type.ValueType.TInt :
				//var r : Int = Std.parseInt(str);
				//return cast r;
			//case Type.ValueType.TClass(c):
				//
				//switch(Type.getClass(value)){
					//case String :
						//return cast str;
					//default : 
						//throw "unknown class type for " + name;
				//}
			//case Type.ValueType.TNull :
				//return null;
			//default :
				//throw "unknown value type for " + name +" : "+Type.typeof(value);
				//return null;
		//}
	//}
	
	/**
	 * render label + field
	 */
	override public function getFullRow():String {
		if (this.inputType == ITHidden){
			return this.render();
		}else{
			return super.getFullRow();
		}
		
	}
	
}