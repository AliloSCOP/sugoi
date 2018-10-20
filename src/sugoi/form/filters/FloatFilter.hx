package sugoi.form.filters;

/**
 * Converts a String to a Float
 */
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
		var f = Std.parseFloat(n);
		if( Math.isNaN(f) ) f = null;
		return f;
	}
	
}