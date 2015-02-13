package sugoi.apis.linux;

/**
 * ...
 * @author fbarbut
 */
class Curl
{

	public var params : Array<String>;
	
	public function new() 
	{
		
	}
	
	public static function get() {
		return new Curl();
	}
	
	public function call( method: String, url : String, ?headers : Dynamic, postData : String ) : Dynamic {
		params = ["-X"+method,"--max-time","5"];
		for( k in Reflect.fields(headers) ){
			params.push("-H");
			params.push(k+": "+Reflect.field(headers,k));
		}
		params.push(url);
		if( postData != null ){
			params.push("-d");
			params.push(postData);
		}

		var p = new sys.io.Process("curl", params);
		#if neko
		var str = neko.Lib.stringReference(p.stdout.readAll());
		#else
		var str = p.stdout.readAll().toString();
		#end
		p.exitCode();

		return str;
	}
	
}