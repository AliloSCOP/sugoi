package sugoi.form.elements;
import sugoi.form.FormElement;
#if neko
import neko.Web;
#else
import php.Web;
#end

/**
 * creates a token in forms , against CSRF
 */
class CSRFProtection extends FormElement
{

	public function new()
	{
		super();
		value = haxe.crypto.Md5.encode(App.current.session.sid + App.App.config.get("database")).substr(0, 5);
		name = "token";
	}

	override public function isValid() {

		var valid = Web.getParams().get(parentForm.name + "_" + name) == value;

		if (!valid) {
			errors.add("Bad CSRFProtection token");
		}
		return valid;
	}


	override public function getPreview() {
		return "<tr><td></td><td>"+render()+"</td></tr>";
	}

	override public function render() {

		return "<input type=\"hidden\" value=\"" + value + "\" " + attributes + " name=\"" +parentForm.name + "_" +name + "\" id=\"" +parentForm.name + "_" +name + "\" />";

	}
}