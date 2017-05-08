package sugoi.form.elements;

import sugoi.form.Form;
import sugoi.form.FormElement;

class Readonly<T> extends FormElement<T>
{
	public var display:Bool;

	public function new(name:String, label:String, ?value:T, ?required:Bool = false, ?display:Bool = false,  ?attributes:String = "")
	{
		super();
		this.name = name;
		this.label = label;
		this.value = value;
		this.required = required;
		this.display = display;
		this.attributes = attributes;
	}

	override public function render():String
	{
		var n = parentForm.name + "_" + name;

		var str:StringBuf = new StringBuf();

		str.add("<input type=\"hidden\" name=\"" + n + "\" id=\"" + n + "\" value=\"" +value + "\"/>");
		if (display) {
			str.add(value);
		}

		return str.toString();
	}

	override public function getTypedValue(str:String):T
	{
		if (str == "" || str==null) {
			return null;
		}

		return cast StringTools.trim(str);
	}
}
