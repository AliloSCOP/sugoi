package sugoi.form;

class FieldSet
{
	public var name:String;
	public var form:Form;
	public var label:String;
	public var visible:Bool;
	public var elements:Array<FormElement<Dynamic>>;

	public function new(?name:String = "", ?label:String = "", ?visible:Bool = true)
	{
		this.name = name;
		this.label = label;
		this.visible = visible;

		elements = [];
	}

	public function getOpenTag()
	{
		return "<fieldset id=\""+form.name+"_"+name+"\" name=\""+form.name+"_"+name+"\" class=\""+(visible?"":"fieldsetNoDisplay")+"\" ><legend>" + label + "</legend>";
	}

	public function getCloseTag()
	{
		return "</fieldset>";
	}
}
