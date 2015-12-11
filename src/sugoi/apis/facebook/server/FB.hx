package sugoi.apis.facebook.server;

/**
 * 
 * Call Facebook services thru the graph API
 * 
 * @author fbarbut<francois.barbut@gmail.com>
 */
class FB
{

	var token : String;
	
	public function new(fbToken:String) {
		token = fbToken;
	}
	
	public static function init(fbToken) {
		return new FB(fbToken);
	}
	
	/**
	 * Publish a photo in the current user galery
	 * @param	imgUrl
	 * @param	text
	 * @return	a json object
	 */
	public function publishPhoto(imgUrl:String,text:String):Dynamic {

		//var c = new sugoi.apis.linux.Curl();
		//c.setPostData("access_token", token);
		//c.setPostData("url", imgUrl );
		//var r = c.call("POST", "https://graph.facebook.com/v2.5/me/photos");
		
		//var c = new sys.io.Process("curl", [
			//"-X POST",
			//"-d url="+imgUrl,
			//"-d access_token=" + token,
			//"https://graph.facebook.com/v2.5/me/photos"
		//]);
		
		
		var text = StringTools.urlEncode(text);
		return call('curl -X POST -d url=$imgUrl -d access_token=$token -d caption="$text" https://graph.facebook.com/v2.5/me/photos');		
		
	}
	
	/**
	 * Publish a story
	 * @doc https://developers.facebook.com/docs/sharing/opengraph
	 * 
	 * @param action 		Like 'game.achieves', see https://developers.facebook.com/docs/reference/opengraph/action-type/games.achieves/
	 * @param ogObjectUrl 	An opengraph object representing the subject the action in done to
	 */
	public function publishStory(action:String, objectType:String,ogObjectUrl:String,?message:String) {
		
		ogObjectUrl = StringTools.urlEncode(ogObjectUrl);
		
		return call('curl -X POST -d access_token=$token -d "$objectType=$ogObjectUrl" -d fb:explicitly_shared=true '+(message!=null ? ' -d message="'+StringTools.urlDecode(message)+'"' : "") +' https://graph.facebook.com/v2.5/me/$action');
		
	}
	
	/**
	 * Get a long lived facebook token from a short lived one
	 * @doc https://developers.facebook.com/docs/facebook-login/access-tokens/expiration-and-extension
	 * @return	token
	 */
	public function getLongLivedToken():String {
		
		var r = call("curl -X GET https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&amp;client_id=" + App.config.get("fb_app_id") + "&amp;client_secret=" + App.config.get("fb_app_secret") + "&amp;fb_exchange_token = " + this.token);
		return r.access_token;
		
	}
	
	
	/**
	 * call via cURL
	 */
	function call(cmd:String):Dynamic {
		var c = new sys.io.Process(cmd,[]);
		#if neko
		var r = neko.Lib.stringReference(p.stdout.readAll());
		#else
		var r = c.stdout.readAll().toString();
		#end
		//error ?
		if (r == null) {
			#if neko
			var r = neko.Lib.stringReference(c.stderr.readAll());
			#else
			var r = c.stderr.readAll().toString();
			#end
		}
		c.exitCode();
		
		if (r == null) {
			throw "cUrl answer is null";
		}
		
		var json:Dynamic = haxe.Json.parse(r);
		
		if (json.error==1 || json.error || json.error=="1") {
			throw r;
		}
		
		return json;
	}
	
	
	
}