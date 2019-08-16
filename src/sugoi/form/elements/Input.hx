package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;
import sugoi.form.validators.*;
import sugoi.form.Formatter;

using StringTools;

enum InputType{
	ITText;
	ITPassword;
	ITHidden;
	ITColor; //http://caniuse.com/#feat=input-color
}

class Input<T> extends FormElement<T>
{
	public var password(get,set):Bool;
	public var disabled:Bool;
	public var showLabelAsDefaultValue:Bool;
	public var printRequired:Bool;
	
	public var formatter:Formatter;
	public var inputType : InputType;
	
	public function new(name:String, label:String, ?value:T, ?required=false, ?validators:Array<Validator<T>>, ?attributes="")
	{
		super();
		this.name = name;
		this.label = label;
		this.value = value;
		this.required = required;
		this.attributes = attributes;

		if (validators != null){
			for (i in validators)
			{
				this.validators.add(i);
			}
		}

		this.password = false;
		this.disabled = false;
		inputType = ITText;
		
		printRequired = false;
		if(Form.USE_TWITTER_BOOTSTRAP) cssClass = "form-control";
	}
	
	public function get_password(){
		return inputType == ITPassword;
	}
	
	public function set_password(v:Bool){
		if (v){
			inputType = ITPassword;
		}else{
			inputType = ITText;
		}
		return v;
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		var tType = switch(inputType){
			case ITHidden: "hidden";
			case ITPassword : "password" ;
			case ITText : "text" ;
			case ITColor : "color";
		}
		
		return "<input class=\""+ getClasses() +"\" type=\""+tType+"\" name=\""+n+"\" id=\""+n+"\" value=\"" +safeString(value)+ "\"  "+attributes+" "+ (disabled?"disabled":"")+"/>" + ((required && parentForm.isSubmitted() && printRequired)?" required":"") ;
	}
	
	override public function getTypedValue(str:String):T{
		
		if (str == "" || str==null) {
			return null;
		}
		return cast StringTools.trim(str);
		
	}
	
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