package sugoi.form.elements;
import sugoi.form.FormElement;
import sugoi.form.elements.Input;
#if neko
import neko.Web;
#else
import php.Web;
#end

/**
 * creates a hidden token in forms to avoid CSRF
 */
class CSRFProtection extends StringInput
{

	public function new()
	{
		
		value = haxe.crypto.Md5.encode(App.current.session.sid + App.config.KEY.substr(0, 5));
		super("token","", value, true);
		inputType = ITHidden;
	}

	override public function isValid() {
		if (value == null) throw "empty token";
		var valid = Web.getParams().get(parentForm.name + "_" + name) == value;

		if (!valid) {
			errors.add("Bad token");
		}
		return valid;
	}


	override public function getFullRow() {
		return render();
	}

	override public function render() {

		return "<input type=\"hidden\" value=\"" + value + "\" " + attributes + " name=\"" +parentForm.name + "_" +name + "\" id=\"" +parentForm.name + "_" +name + "\" />";

	}
}