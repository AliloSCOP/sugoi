package sugoi.form;

class Validator 
{
	public var errors:List<String>;
	
	public function new() 
	{
		errors = new List();
	}
	
	public function isValid(value:Dynamic):Bool
	{
		errors.clear();
		
		return true;
	}
	
	public function reset()
	{
		errors.clear();
	}
}