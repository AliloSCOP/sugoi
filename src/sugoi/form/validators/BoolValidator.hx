
package sugoi.form.validators;
import sugoi.form.validators.Validator;

class BoolValidator extends Validator<Bool>
{
	public var errorNotValid:String;
	public var valid:Bool;
	
	public function new(valid:Bool, ?error:String) 
	{
		super();
		
		this.valid = valid;
		
		if (error != null) {
			errorNotValid = error;
		}else {
			errorNotValid = "Not valid.";
		}
	}
	
	override public function isValid(value):Bool
	{
		if (!valid)
			errors.push(errorNotValid);
		return valid;
	}
}