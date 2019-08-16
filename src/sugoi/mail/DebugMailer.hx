package sugoi.mail;
import sugoi.mail.IMail;
import sugoi.mail.IMailer;

/**
 * A Debug Mailer to use in dev environment : 
 * logs the emails in the Error table + write html files in tmp folder
 * 
 * @author fbarbut
 */
class DebugMailer implements IMailer
{
	public function new() {}
	
	public function init(?c:Dynamic):IMailer{		
		return this;
	}
	
	public function send(m:sugoi.mail.IMail,?params:Dynamic,?callback:MailerResult->Void):Void{
		
		//log in the Error table
		var t = new StringBuf();
		t.add("to:" + m.getRecipients()+"\n");
		t.add("subject:" + m.getSubject()+"\n");
		t.add("body:" + m.getHtmlBody()+"\n");
		
		//App.current.logError( "[DEBUG] Email sent to " + m.getRecipients(), t.toString() );
		
		//write th mail into a html file
		var tmpDir = sugoi.Web.getCwd() + "../tmp/emails/"+Date.now().toString().substr(0,10)+"/";
		if ( !sys.FileSystem.exists(tmpDir) ) {
			sys.FileSystem.createDirectory(tmpDir);
			var chmod = new sys.io.Process("chmod",["777",tmpDir]);
			chmod.exitCode(true);

		}

		for (r in m.getRecipients()){
			sys.io.File.saveContent( tmpDir + r.email + "-" + m.getSubject() + ".html" ,  m.getHtmlBody() );
		}
		
		
		//callback
		if (callback != null){
			
			var map = new MailerResult();
			for ( u in m.getRecipients() ){
				map.set( u.email , Success(Sent) );
			}
			callback(map);
		}
	}
	
}
