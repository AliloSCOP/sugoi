package sugoi.apis.google;
import sugoi.apis.linux.Curl;


/**
 * Google ReCaptcha
 * @doc https://www.google.com/recaptcha/
 * @author fbarbut<francois.barbut@gmail.com>
 */
class Recaptcha
{

	/**
	 * Calls the service and returns a JSON response (not parsed)
	 */
	public static function call(secret:String, token:String, ip:String):String {
		
		var c = new Curl();			
		c.setPostData("secret", secret);			
		c.setPostData("response", token);			
		c.setPostData("remoteip", ip );
		return c.call("POST", "https://www.google.com/recaptcha/api/siteverify", { } );
		
	}
	
}