
package sugoi.form.elements;

import sugoi.form.elements.Input;
import sugoi.form.Form;
import sugoi.form.Validator;
import sugoi.form.validators.BoolValidator;

class TextArea extends Input
{
	public var height:Int;

	public function new(name:String, label:String, ?value:String, ?required:Bool=false, ?validators:Array<Validator>, ?attributes:String) 
	{		
		super(name, label, value, required, validators, attributes);
		
		width = 300;
		height = 50;
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		
		if (showLabelAsDefaultValue && value == label){
			addValidator(new BoolValidator(false, "Not valid"));
		}
		
		if ((value == null || value == "") && showLabelAsDefaultValue) {
			value = label;
		}		
		
		var s = "";
		if (required && parentForm.isSubmitted() && printRequired) s += "required<br />";
		var style = useSizeValues ? "style=\"width:" + width + "px; height:" + height + "px;\"" : "";
		
		s += "<textarea " + style + " class=\""+ getClasses() +"\" name=\"" + n + "\" id=\"" + n + "\" " + attributes + " >" + safeString(value) + "</textarea>";
		
		return s;
	}
	
	override public function toString() :String
	{
		return render();
	}	
	
}