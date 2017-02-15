package sugoi.form.validators;

class Validator<T> 
{
	public var errors:List<String>;
	
	public function new() 
	{
		errors = new List();
	}
	
	public function isValid(value:T):Bool
	{
		errors.clear();
		
		return true;
	}
	
	public function reset()
	{
		errors.clear();
	}
}