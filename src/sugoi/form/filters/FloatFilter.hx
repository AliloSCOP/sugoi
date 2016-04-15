package sugoi.form.filters;

class FloatFilter extends Filter implements IFilter
{

	public function new() 
	{
		super();
	}
	
	public function filter(n:String):Float {
		if (n == null || n=="") return 0;
		n = StringTools.replace(n, ",", ".");
		return Std.parseFloat(n);
	}
	
}