package sugoi.apis.morning;

/**
 * Morning Up Payment Service Connector
 * 
 * @author fbarbut
 * @date 2016-10-05
 * @doc https://up.morning.com
 */
class MorningUp
{
	
	var token : String; 

	public function new(token:String) 
	{
		this.token = token;
	}
	
	
	public function createPayment(amount:Float,title:String,?type=null,order_id:String,back_url:String) {
		
		var amount = Std.string(amount);
		title = title.substr(0, 255);
		
		var args = [
		'-X',
		'POST',
		'-d',
		'token=$token',
		'-d',
		'amount=$amount',
		'-d',
		'title=$title',
		'-d',
		'order_id=$order_id',
		'-d',
		'back_url=$back_url',
		'https://up.morning.com/api/creer-un-paiement'
		];
		
		return call("curl", args);		
	}
	
	public function paymentInfo(hash:String){
		
		var args = [
		/*'-X',
		'GET',
		'-d',
		'token=$token',
		'-d',
		'hash=$hash',		*/
		'https://up.morning.com/api/paiement-information?hash=$hash&token=$token'
		];
		
		return call("curl", args);	
	}
	
	/**
	 * call via cURL
	 */
	function call(cmd:String,args:Array<String>,?isJson=true):Dynamic {
		var p = new sys.io.Process(cmd, args);
		var r:String = null;
		#if neko
		r = neko.Lib.stringReference(p.stdout.readAll());
		#else
		r = p.stdout.readAll().toString();
		#end
		//error ?
		if (r == null || r == "") {
			#if neko
			r = neko.Lib.stringReference(p.stderr.readAll());
			#else
			r = p.stderr.readAll().toString();
			#end
		}
		p.exitCode();
		
		if (r == null) throw "cUrl answer is null";
		if (r == "") throw "cUrl answer is an empty string";
		
		if (!isJson) return r;
		
		var json:Dynamic = null;
		try{
			json = haxe.Json.parse(r);
		}catch (e:Dynamic){
			throw 'Error while parsing JSON "$r" : "$e"';
		}
		if ( json == null ) throw "JSON result is null";
		
		if (json.error==1 || json.error || json.error=="1") {
			throw r;
		}
		
		return json;
	}
	
}