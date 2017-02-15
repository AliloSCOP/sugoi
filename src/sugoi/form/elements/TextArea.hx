
package sugoi.form.elements;

import sugoi.form.elements.Input;
import sugoi.form.Form;
import sugoi.form.validators.*;

class TextArea extends StringInput
{
	public var height:Int;

	public function new(name:String, label:String, ?value:String, ?required:Bool=false, ?validators:Array<Validator<String>>, ?attributes:String) 
	{		
		super(name, label, value, required, validators, attributes);
		
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		
		//if (showLabelAsDefaultValue && value == label){
			//addValidator(new BoolValidator(false, "Not valid"));
		//}
		
		if ((value == null || value == "") && showLabelAsDefaultValue) {
			value = label;
		}		
		
		var s = "";
		if (required && parentForm.isSubmitted() && printRequired) s += "required<br />";
		
		s += "<textarea class=\""+ getClasses() +"\" name=\"" + n + "\" id=\"" + n + "\" " + attributes + " >" + safeString(value) + "</textarea>";
		
		return s;
	}
		
	
}