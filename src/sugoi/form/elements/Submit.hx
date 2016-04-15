package sugoi.form.elements;
import sugoi.form.Form;
import sugoi.form.FormElement;


class Submit extends FormElement<String>
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
	

	override public function getFullRow():String
	{
		return "<div class='col-sm-4'></div><div class='col-sm-8'>" + this.render() + "</div>";
	}
	
	
}