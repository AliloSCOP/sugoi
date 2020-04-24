package sugoi.form;

typedef FormData<T> = Array<{label:String,value:T,?desc:String,?docLink:String}>;

class ListData
{
	public static function getDateElement( low : Int, high : Int, ?labels : Array<String> ) : FormData<Int>
	{
		var data = [];
		if ( labels != null ){
			for ( i in low ... high + 1 )
				data.push( { label:labels[i-1], value:i } );
		}else{
			for ( i in low ... high + 1 ){
				var n = Std.string(i);
				data.push( { label:((i < 10) ? "0" + n : n), value: i } );
			}
		}
		return data;
	}
	
	public static function getMinutes():FormData<Int> {
		var data = [];
		for ( i in 0...12) {			
			var x = i * 5;
			data.push( {label: (x<10) ? "0"+Std.string(x) : Std.string(x) ,value: x } );
		}
		return data;
	}
	
	public static function fromArray(arr:Array<Dynamic>) {
		var data = [];
		for (a in arr) {
			data.push( {key:Std.string(a),value:Std.string(a) } );
		}
		return data;
	}
	
	public static function getDays(?reverse = true):Array<{label:String,value:Int}>
	{
		var data= [];
		for (i in 1...31+1) {
			data.push( { label:Std.string(i), value:i } );
		}
		return(data);
	}
	
	//public static var months_short = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
	public static var months_short = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
	//public static var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
	public static var months = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Aout", "Septembre", "Octobre", "Novembre", "Décembre"];
	
	/**
	 * Get months list
	 */
	public inline static function getMonths(?short = false):Array<{label:String,value:Int}>
	{
		var input = short ? months_short : months;
		var out = [];
		var c = 1;
		for ( i in input) {
			out.push( { label:i, value:c } );
			c++;
		}
		return out;
	}
	
	/**
	 * get years list
	 */
	public static function getYears(from:Int, to:Int, ?reverse = true):Array<{label:String,value:Int}>
	{
		var data = [];
		
		if (reverse){
			for (i in 0...(to-from+1)) {
				var n = to - i;
				data.push( { label:Std.string(n), value:n } );
			}
		}else {
			for (i in 0...(to-from+1)) {
				var n = from + i;
				data.push( { label:Std.string(n), value:n } );
			}
		}
		return(data);
	}
	
	/*public static function getLetters(uppercase=false){
		if (uppercase) return(array(a=>"A", b=>"B", c=>"C", d=>"D", e=>"E", f=>"F", g=>"G", h=>"H", i=>"I", j=>"J", k=>"K", l=>"L", m=>"M", n=>"N", o=>"O", p=>"P", q=>"Q", r=>"R", s=>"S", t=>"T", u=>"U", v=>"V", w=>"W", x=>"X", y=>"Y", z=>"Z"));
		return(array(a=>"a", b=>"b", c=>"c", d=>"d", e=>"e", f=>"f", g=>"g", h=>"h", i=>"i", j=>"j", k=>"k", l=>"l", m=>"m", n=>"n", o=>"o", p=>"p", q=>"q", r=>"r", s=>"s", t=>"t", u=>"u", v=>"v", w=>"w", x=>"x", y=>"y", z=>"z"));
	}*/
	
	public static function hashToList(hash:Map<String,String>, ?startCounter:Int=0):List<Dynamic>
	{
		var data:List<Dynamic> = new List();
		
		for (key in hash.keys())
		{
			data.add( { key:key, value:hash.get(key) } );
		}
		return data;
	}
	
	/*public static function fromArray<T>(array:Array<T>, ?startCounter:Int=0):FormData<T>{
		var data = new FormData<T>();		
		for (v in array){
			data.push( { label:v, value:startCounter } );
			startCounter++;
		}
		return data;
	}*/
	
	public static function fromFlatArray<T>(array:Array<T>):FormData<T>{
		var data = new FormData<T>();
		for (i in array) data.push( { label:Std.string(i), value:i } );
		return data;
	}

	public static function fromSpod(array:Iterable<Dynamic>):FormData<Int>{
		var data = new FormData<Int>();
		for (i in array) data.push( { label:untyped i.name , value:untyped i.id } );
		return data;
	}
	
}