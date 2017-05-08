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
		
		App.current.logError( t.toString() );
	}
	
}
