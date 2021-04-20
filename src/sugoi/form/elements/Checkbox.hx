package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;

class Checkbox extends FormElement<Bool>
{
	
	public function new(name:String, label:String, ?checked:Bool=false, ?required:Bool=false, ?attributes:String="")
	{
		super();
		
		this.name = name;
		this.label = label;
		this.value = checked;
		this.required = required;
		this.attributes = attributes;
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		var checkedStr = value ? "checked" : "";
		var render =  "<input type=\"checkbox\" id=\"" + n + "\" name=\"" + n + "\" class=\"" + getClasses() + "\" value=\"true\" " + checkedStr + " />";

		render += (description==null?"":"<p class='desc'>"+description+'</p>');

		return render;

	}
	
	
	override public function getTypedValue(str:String):Bool
	{
		return str == "1" || str == "true";
	}
	
	override public function isValid():Bool
	{
		errors.clear();
		if ( required && value == null )
		{
			errors.add("Please check '" + ((label != null && label != "") ? label : name) + "'");
			return false;
		}
		return true;
	}
}