package sugoi.mail;
import haxe.Http;


typedef SendResult = Array <{
	email:String,
	status:String,
	_id:String,
	reject_reason:String,
}>;

/**
 * Send an email via Mandrill.com API
 * @author fbarbut
 * @doc https://mandrillapp.com/api/docs/messages.JSON.html
 */
class MandrillApiMail extends BaseMail implements IMail
{
	public var pass :String;
	public var apiResult : Dynamic;
	public var curlRq : String;
	public var images : Array<{type:String,name:String,content:String}>;

	public function new() {
		super();
		pass = App.config.get('smtp_pass');
		images = [];
	}

	override public function send():Dynamic {
		var headersObj = { };
		for(k in headers.keys()) {
			Reflect.setField(headersObj, k, headers.get(k));
		}

		var data = {
			key: pass,
			message: {
				html : this.htmlBody,
				text : this.textBody,
				subject : this.title,
				from_email : this.senderEmail,
				from_name : this.senderName,
				to : [],
				headers : /*{ Reply-To : this.senderEmail }*/ headersObj,
				images : images,
			}
		};
		for (r in recipients) {
			data.message.to.push( { email:r.email, name:r.name, type:"to" } );
		}

		var res = curlRequest("POST", "https://mandrillapp.com/api/1.0/messages/send.json", {}, haxe.Json.stringify(data));
		onData(res);
		return apiResult;
		
	}

	function onData(s:String) {
		
		if (s == null) throw "return is null";
		if (s == "") throw "return is empty";
		
		try{
			apiResult = haxe.Json.parse(s);
		}catch (e:Dynamic){
			
			throw "unable to decode : " + s + ", error is "+Std.string(e);
		}
		
		/*result should be like this:  [
			{
				"email":"francois.barbut@gmail.com",
				"status":"sent",
				"_id":"419808d760134e3ab51bb65a482c3dbd",
				"reject_reason":null
			}
		]
		*/

		#if neko
		//if(!neko.Web.isModNeko && App.App.config.DEBUG) neko.Lib.println("api res : " + apiResult + "\n" + s);
		#end
	}


	/**
	 * status HTTP
	 * @param	s
	 */
	function onStatus(s:Int) {
		if(s != 200) {
			throw "HTTP status " + s + " from Mandrill API";
		}
	}

	public function curlRequest( method: String, url : String, ?headers : Dynamic, postData : String ) : Dynamic {
		var cParams = ["-X"+method,"--max-time","5"];
		for( k in Reflect.fields(headers) ){
			cParams.push("-H");
			cParams.push(k+": "+Reflect.field(headers,k));
		}
		cParams.push(url);
		if( postData != null ){
			cParams.push("-d");
			cParams.push(postData);
		}

		var p = new sys.io.Process("curl", cParams);
		curlRq = "curl " + cParams.join(" ");
		#if neko
		var str = neko.Lib.stringReference(p.stdout.readAll());
		#else
		var str = p.stdout.readAll().toString();
		#end
		
		if (str == null || str == "") {
			str = neko.Lib.stringReference(p.stderr.readAll());
		}
		
		
		p.exitCode();

		return str;
	}

}