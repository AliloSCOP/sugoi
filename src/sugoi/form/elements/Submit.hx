package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;


class Submit extends FormElement
{
	public function new(name:String, value:String)
	{
		super();
		this.name = name;
		this.value = value;
		
	}
	
	override public function isValid():Bool
	{
		return true;
	}
	
	override public function render() :String
	{
		if (Form.USE_TWITTER_BOOTSTRAP) cssClass = "btn btn-primary";
		
		var s = "<input type=\"submit\" class=\"" + getClasses() +"\" value=\"" + value + "\" " + attributes + " name=\"" +parentForm.name + "_" +name + "\" id=\"" +parentForm.name + "_" +name + "\" />";
		return s;
	}
	
	public function toString() :String
	{
		return render();
	}
	
	override public function getPreview():String
	{
		return "<tr><td></td><td>" + this.render() + "<td></tr>";
	}
	
	override public function populate():Void
	{
		super.populate();
		var n = parentForm.name + "_" + name;
		//if ( Poko.instance.params.exists(n) ) form.submittedButtonName = name;
	}
}