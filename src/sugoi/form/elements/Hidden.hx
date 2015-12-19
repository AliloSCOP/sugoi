package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;

class Hidden extends FormElement
{
	public var display:Bool;
	
	public function new(name:String, ?value:Dynamic, ?required:Bool = false, ?display:Bool = false,  ?attributes:String = "") 
	{
		super();
		this.name = name;
		this.value = value;
		this.required = required;
		this.display = display;
		this.attributes = attributes;
	}
	
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		var type = display ? "text" : "hidden";
		return '<input type="' + type + '" name="' + n + '" id="' + n + '" value="' +value + '"/>';
	}
	
	override public function getFullRow():String
	{
		return this.render();
	}	
	

}