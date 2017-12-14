package sugoi.mail;
import sugoi.mail.IMail;
import sugoi.mail.IMailer;


/**
 * Used in dev environment : logs the emails in the error table
 * 
 * @author fbarbut
 */
class DebugMailer implements IMailer
{

	public function new() {}
	
	public function init(c:Dynamic):IMailer{		
		return this;
	}
	
	public function send(m:sugoi.mail.IMail,?callback:MailerResult->Void):Void{
		
		var t = new StringBuf();
		t.add("to:" + m.getRecipients()+"\n");
		t.add("subject:" + m.getSubject()+"\n");
		t.add("body:" + m.getHtmlBody()+"\n");

		App.current.logError( "[DEBUG] Email sent to " + m.getRecipients(), t.toString() );
		
		if (callback != null){
			
			var map = new MailerResult();
			for ( u in m.getRecipients() ){
				map.set( u.email , Success(Sent) );
			}
			
			callback(map);
		}
	}
	
}
