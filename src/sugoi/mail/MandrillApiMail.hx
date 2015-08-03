package sugoi.mail;
import haxe.Http;

/**
 * Send an email via Mandrill.com API
 * @author fbarbut
 * @doc https://mandrillapp.com/api/docs/messages.JSON.html
 */
class MandrillApiMail extends BaseMail implements IMail
{

	public var pass :String;
	public var apiResult : Dynamic;

	public function new() {
		super();
		pass = App.config.get('mt.net.mail.MandrillMail.PASS');
	}

	override public function send() {
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
			}
		};
		for (r in recipients) {
			data.message.to.push( { email:r.email, name:r.name, type:"to" } );
		}

		//var r = new haxe.Http("https://mandrillapp.com/api/1.0//messages/send.json");
		//r.setPostData();
		//r.onData = onData;
		//r.onError = function(s) throw s;
		//r.onStatus = onStatus;
		//r.request(true);

		var res = curlRequest("POST", "https://mandrillapp.com/api/1.0/messages/send.json", {}, haxe.Json.stringify(data));
		onData(res);
	}

	function onData(s:String) {
		
		if (s == null) throw "return is null";
		if (s == "") throw "return is empty";
		
		apiResult = haxe.Json.parse(s);
		
		//result should be like this:  [{"email":"francois.barbut@gmail.com","status":"sent","_id":"419808d760134e3ab51bb65a482c3dbd","reject_reason":null},{"email":"elodie.heritier@laposte.net","status":"sent","_id":"483ab840c8ef40779ec8815720a06961","reject_reason":null}]
		//trace(s);
		
		if (Reflect.hasField(apiResult, "status")) throw "Mailchimp Api sendmail error : "+s;
		
		#if neko
		if(!neko.Web.isModNeko && App.App.config.DEBUG) neko.Lib.println("api res : " + apiResult + "\n" + s);
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

	public static function curlRequest( method: String, url : String, ?headers : Dynamic, postData : String ) : Dynamic {
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
		#if neko
		var str = neko.Lib.stringReference(p.stdout.readAll());
		#else
		var str = p.stdout.readAll().toString();
		#end
		p.exitCode();

		return str;
	}

}