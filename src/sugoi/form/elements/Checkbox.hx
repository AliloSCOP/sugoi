package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;

class Checkbox extends FormElement<Bool>
{
	
	public function new(name:String, label:String, ?checked:Bool=false, ?required:Bool=false, ?attibutes:String="")
	{
		super();
		
		this.name = name;
		this.label = label;
		this.value = checked;
		this.required = required;
		this.attributes = attibutes;
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		
		var checkedStr = value ? "checked" : "";
		
		return "<input type=\"checkbox\" id=\"" + n + "\" name=\"" + n + "\" class=\"" + getClasses() + "\" value=\"" + value + "\" " + checkedStr + " />";
	}
	
	
	override public function populate():Void
	{
		
		
		if (parentForm.isSubmitted()) {
			var n = parentForm.name + "_" + name;
			value = App.current.params.exists( n ) && App.current.params.get( n ) == "1";
		}
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