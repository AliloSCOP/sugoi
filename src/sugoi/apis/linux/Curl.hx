package sugoi.apis.linux;

/**
 * cURL
 * 
 * @doc https://en.wikipedia.org/wiki/CURL
 * 
 * Call cURL as an external process.
 * It's an easy way to call HTTPS services from neko and php.
 * Be sure to have cURL installed on your system
 * 
 * @author fbarbut<francois.barbut@gmail.com>
 */
class Curl
{
	var postData : Map<String,String>; //POST params
	
	public function new() 
	{
		postData = new Map();
	}
	
	public static function get() {
		return new Curl();
	}
	
	
	public function setPostData(key:String, value:String) {
		postData.set(key, value);
		
	}
	
	/**
	 * Execute CURL request
	 * 
	 * @param	method="POST"
	 * @param	url
	 * @param	headers
	 * @param	post			Datas send by POST i.e a json request object
	 */
	public function call( ?method="POST", url : String, ?headers : Dynamic,?post:String) : String {
		var params = ["-X"+method, "--max-time", "5"];		
		for( k in Reflect.fields(headers) ){
			params.push("-H");
			params.push(k+": "+Reflect.field(headers,k));
		}
		params.push(url);
		
		//if there is POST params (key-values)
		if( Lambda.count(postData) > 0 ){
			params.push("-d");
			var d = [];			
			for (k in postData.keys()) {
				d.push( k + "=" + StringTools.urlEncode(postData.get(k)) );
			}
			
			params.push("\""+d.join("&")+"\"");
		}
		
		//if there is a POST payload ( i.e a JSON formatted request )
		if (post != null) {
			
			params.push("-d");
			params.push("\""+post+"\"");
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