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
	public var postData : Map<String,String>; //POST params
	public var params : Array<String>; //curl CLI params
	public var debugCommand : String; //store here the generated command
	
	public function new() 
	{
		postData = new Map<String,String>();
		params = [];
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
	 * @param	method		POST, GET or PUT
	 * @param	url
	 * @param	headers
	 * @param	post		A string sent as raw POST i.e a json request object
	 */
	public function call( method:String, url : String, ?headers : Map<String,String>,?post:String) : String {
		
		//method GET or POST
		if (post != null || Lambda.count(postData) > 0)
			params.push("-X" + method);
		
		//time out
		params.push("--max-time");
		params.push("20");
		
		//headers
		if (headers != null){
			for( k in headers.keys() ){
				params.push("-H");
				//params.push("\""+haxe.Utf8.encode(k+": "+headers.get(k))+"\"");
				params.push( k+": "+headers.get(k) );
			}
			
		}
		
		params.push(url);
		
		//POST params (key-values)
		if( postData!=null && Lambda.count(postData) > 0 ){
			params.push("-d");
			var d = [];			
			for (k in postData.keys()) {
				d.push( k + "=" + StringTools.urlEncode(postData.get(k)) );
				//d.push( k + "=" + postData.get(k) );
			}
			params.push("\""+d.join("&")+"\"");
		}
		
		//POST payload ( i.e a JSON formatted request )
		if (post != null) {			
			params.push("-d");
			params.push(post);
			//params.push("\""+StringTools.urlEncode(post)+"\"");
		}
		
		//params = params.map(function(s) return haxe.Utf8.encode(s));
		
		debugCommand = "curl " + params.join(" ");
		var p = new sys.io.Process("curl", params);
		
		#if neko
		var str = neko.Lib.stringReference(p.stdout.readAll());
		#else
		var str = p.stdout.readAll().toString();
		#end
		
		//error ?
		if (str == null) {
			#if neko
			str = "Error : " + neko.Lib.stringReference(p.stderr.readAll());
			#else
			str = "Error : " + p.stderr.readAll().toString();
			#end
		}
		
		p.exitCode();
		return str;
	}
	
}