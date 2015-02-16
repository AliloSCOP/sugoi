package sugoi.form.elements;

import form.Form;
import form.FormElement;


class Button extends FormElement
{
	public var type:ButtonType;
	
	//public function new(name:String, label:String, ?value:String = "Submit", ?type:ButtonType = null)
	public function new(name:String, label:String, ?value:String = null, ?type:ButtonType = null)
	{
		super();
		this.name = name;
		this.label = label;
		this.value = value;
		this.type = (type == null) ? ButtonType.SUBMIT : type;
	}
	
	override public function isValid():Bool
	{
		return true;
	}
	
	override public function render() :String
	{
		return "<button type=\"" + type + "\" class=\"" + getClasses() +"\" value=\"" + value + "\" " + attributes + " name=\"" +parentForm.name + "_" +name + "\" id=\"" +parentForm.name + "_" +name + "\" >" +label + "</button>";
		
	}
	
	public function toString() :String
	{
		return render();
	}
	
	override public function getLabel():String
	{
		var n = parentForm.name + "_" + name;
		
		return "<label for=\"" + n + "\" ></label>";
	}
	
	override public function getPreview():String
	{
		return "<tr><td></td><td>" + this.render() + "<td></tr>";
	}
	
	override public function populate():Void
	{
		super.populate();
		var n = parentForm.name + "_" + name;
		if ( App.current.params.exists(n) )
			parentForm.submittedButtonName = name;
	}
}

enum ButtonType
{
	SUBMIT;
	BUTTON;
	RESET;
}