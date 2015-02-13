package sugoi.form.filters;

class FloatFilter extends Filter implements IFilter
{

	public function new() 
	{
		super();
	}
	
	public function filter(n:String):Float {
		n = StringTools.replace(n, ",", ".");
		var num = Std.parseFloat(n);
		return num;
	}
	
}