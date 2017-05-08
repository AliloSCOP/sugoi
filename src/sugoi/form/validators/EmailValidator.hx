package sugoi.form.validators;
import sugoi.form.validators.Validator;

class EmailValidator extends Validator<String>
{
	public var errorNotValid:String;
	public static var emailRegex = ~/^[^()<>@,;:\\"\[\]\s[:cntrl:]]+@[A-Z0-9][A-Z0-9-]*(\.[A-Z0-9][A-Z0-9-]*)*\.(xn--[A-Z0-9]+|[A-Z]{2,8})$/i;
	
	public function new()
	{
		super();
		#if js
		errorNotValid = "Not a valid email address";
		#else
		errorNotValid = switch(App.current.getLang()){
			case "fr" : "Adresse email invalide";
			default : "Not a valid email address";
		};
		#end
	}
	
	override public function isValid(value:Dynamic):Bool
	{
		super.isValid(value);
		
		var valid = emailRegex.match(Std.string(value));
		if (!valid)
			errors.add(errorNotValid);
		
		return valid;
	}
	
	public inline static function check(value:String):Bool
	{
		var val = new EmailValidator();
		return val.isValid(value);
	}

	
}