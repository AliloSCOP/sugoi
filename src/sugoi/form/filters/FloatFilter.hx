package sugoi.form.filters;

class FloatFilter extends Filter implements IFilter<Float>
{

	public function new() 
	{
		super();
	}
	
	public function filter(f:Float):Float{
		return f;
	}
	
	public function filterString(n:String):Float {
		
		if (n == null || n=="") return null;
		n = StringTools.trim(n);		
		n = StringTools.replace(n, ",", ".");
		return Std.parseFloat(n);
	}
	
}