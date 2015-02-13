package sugoi.form.validators;
import sugoi.form.Validator;

class EmailValidator extends Validator
{
	public var errorNotValid:String;
	public static var emailRegex = ~/^[^()<>@,;:\\"\[\]\s[:cntrl:]]+@[A-Z0-9][A-Z0-9-]*(\.[A-Z0-9][A-Z0-9-]*)*\.(xn--[A-Z0-9]+|[A-Z]{2,8})$/i;
	
	public function new()
	{
		super();
		errorNotValid = "Not a valid email address";
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