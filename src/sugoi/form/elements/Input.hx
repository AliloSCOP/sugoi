package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;
import sugoi.form.Validator;
import sugoi.form.validators.BoolValidator;
import sugoi.form.Formatter;

using StringTools;

class Input extends FormElement
{
	public var password:Bool;
	public var width:Int;
	public var disabled:Bool;
	public var showLabelAsDefaultValue:Bool;
	public var useSizeValues:Bool;
	public var printRequired:Bool;
	
	public var formatter:Formatter;
	
	public function new(name:String, label:String, ?value:String, ?required:Bool=false, ?validators=null, ?attributes:String="", ?disabled=false)
	{
		super();
		this.name = name;
		this.label = label;
		this.value = value;
		this.required = required;
		this.attributes = attributes;
		this.password = false;
		this.disabled = disabled;
		
		showLabelAsDefaultValue = false;
		useSizeValues = false;
		printRequired = false;
		if(Form.USE_TWITTER_BOOTSTRAP) cssClass = "form-control";
		width = 180;
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		var tType:String = password ? "password" : "text";
		
		if (showLabelAsDefaultValue && value == label){
			addValidator(new BoolValidator(false, "Not valid"));
		}
		
		if ((value == null || value == "") && showLabelAsDefaultValue) {
			value = label;
		}
		
		var style = useSizeValues ? "style=\"width:" + width + "px\"" : "";
		return "<input "+style+" class=\""+ getClasses() +"\" type=\""+tType+"\" name=\""+n+"\" id=\""+n+"\" value=\"" +safeString(value)+ "\"  "+attributes+" "+ (disabled?"disabled":"")+"/>" + ((required && parentForm.isSubmitted() && printRequired)?" required":"") ;
	}
	
	public function toString() :String
	{
		return render();
	}
}