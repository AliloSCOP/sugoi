

package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;
//import poko.Poko;

class Checkbox extends FormElement
{
	//public var checked : Bool;
	
	public function new(name:String, label:String, ?checked:Bool=false, ?required:Bool=false, ?attibutes:String="")
	{
		super();
		
		this.name = name;
		this.label = label;
		this.value = checked ? "1" : "0";
		//this.value = value;
		//this.checked = checked;
		this.required = required;
		this.attributes = attibutes;
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		
		//var checkedStr = ( this.checked ) ? "checked" : "";
		var checkedStr = ( value == "1" ) ? "checked" : "";
		
		return "<input type=\"checkbox\" id=\"" + n + "\" name=\"" + n + "\" class=\"" + getClasses() + "\" value=\"" + value + "\" " + checkedStr + " />";
		//return "<input type=\"checkbox\" id=\"" + n + "\" name=\"" + n + "\" class=\"" + getClasses() + "\" value=\"" + value + "\" " + checkedStr + " />";
	}
	
	public function toString() :String
	{
		return render();
	}
	
	override public function populate():Void
	{
		var n = parentForm.name + "_" + name;
		var v = App.current.params.exists( n ) ? "1" : "0";
		
		if (parentForm.isSubmitted()) {
			if (v != null) {
				value = v;
			}
		}
	}
	
	override public function isValid():Bool
	{
		errors.clear();
		if ( required && value == "0" )
		{
			errors.add("Please check '" + ((label != null && label != "") ? label : name) + "'");
			return false;
		}
		return true;
	}
}