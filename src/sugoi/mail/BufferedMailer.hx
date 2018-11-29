package sugoi.mail;
import sugoi.mail.IMail;
import sugoi.mail.IMailer;

/**
 * Manage an email buffer in a table before sending them
 * @author fbarbut
 */
class BufferedMailer implements IMailer
{
	var conf : Dynamic;
	var type : String;

	public function new() {}
	
	public function init(?c:Dynamic):IMailer{
		return this;
	}

	public function defineFinalMailer(type:String){
		this.type = type;
	}
	
	public function send(m:sugoi.mail.IMail,?params:Dynamic,?callback:MailerResult->Void):Void{

		var bm = new sugoi.db.BufferedMail();
		bm.headers = m.getHeaders();
		bm.title = m.getTitle();
		bm.htmlBody = m.getHtmlBody();
		bm.textBody = m.getTextBody();
		bm.recipients = m.getRecipients();
		bm.sender = m.getSender();		
		bm.mailerType = this.type;

		//custom params
		if(params!=null){
			bm.data = params;
			if(Reflect.hasField(params,"remoteId")){
				bm.remoteId = Reflect.getProperty(params,"remoteId");
			}
		} 

		//set sending status as "queued"
		var map = new MailerResult();
		for( r in m.getRecipients() ){
			map.set( r.email , Success(Queued) );
		}

		bm.status = map;
		bm.insert();

		if(callback!=null) callback(map);

	}

	

}

	