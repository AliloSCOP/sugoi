package sugoi.db;
import sys.db.Types;
import sugoi.mail.IMail;
import sugoi.mail.IMailer;

/**
 * DB Buffer for emails
 */
@:index(remoteId,sdate,cdate)
class BufferedMail extends sys.db.Object
{
	public var id : SId;

	//email content
	public var title : SString<256>;
	public var htmlBody : SNull<SText>;
	public var textBody : SNull<SText>;
	public var headers : SData<Map<String,String>>;
	public var sender : SData<{name:String,email:String,?userId:Int}>;
	public var recipients : SData<Array<{name:String,email:String,?userId:Int}>>;
	
	//utility fields
	public var mailerType : SString<32>;	//mailer used when sending for real
	public var tries : SInt;				//number of times we tried to send the mail	
	public var cdate : SDateTime;		 	//creation date
	public var sdate : SNull<SDateTime>; 	//sent date
	public var rawStatus : SNull<SText>;			//raw return from the smtp server or mandrill API
	public var status : SNull<SData<MailerResult>>; //map of emails with api/smtp results	

	//custom datas
	public var data : SNull<SData<Dynamic>>;//custom datas
	public var remoteId : SNull<Int>;		//custom remote Id (userId, groupId ...) 	

	
	public function getMailerResultMessage(k:String):{failure:String, success:String}{
		var t = sugoi.i18n.Locale.texts;
		var out = {failure:null, success:null};
		switch(status.get(k)){
			case tink.core.Outcome.Failure(f):
				out.failure = switch(f){
					case GenericError(e): 	t._("Generic error: ") + e.toString();
					case HardBounce : 		t._("Mailbox does not exist");
					case SoftBounce : 		t._("Mailbox full or blocked");
					case Spam:				t._("Message considered as spam");
					case Unsub:				t._("This user unsubscribed");
					case Unsigned:			t._("Sender incorrect (Unsigned)");
					
				};
			case tink.core.Outcome.Success(s):
				out.success = switch(s){
					case Sent : 	t._("Sent");
					case Queued : 	t._("Queued");
				};
		}
		return out;
		
	}	

	
	public function new(){
		super();
		cdate = Date.now();
		tries = 0;
	}

	public function isSent(){
		return sdate!=null;
	}

	/**
	 *  Finally really send the message
	 */
	public function finallySend():Void{

		if(isSent()) throw "already sent";
		
		var conf = {
			smtp_host:sugoi.db.Variable.get("smtp_host"),
			smtp_port:sugoi.db.Variable.getInt("smtp_port"),
			smtp_user:sugoi.db.Variable.get("smtp_user"),
			smtp_pass:sugoi.db.Variable.get("smtp_pass")			
		};

		var mailer : sugoi.mail.IMailer = switch(this.mailerType){
			case "mandrill":
				new sugoi.mail.MandrillMailer().init(conf);
			case "smtp":
				new sugoi.mail.SmtpMailer().init(conf);
			case "debug":
				new sugoi.mail.DebugMailer();
			default : 
				throw "Unknown mailer type : "+this.mailerType;
		};
		

		var m = new sugoi.mail.Mail();
		for( k in this.headers.keys() ) m.setHeader( k,headers[k] );
		m.setSubject(this.title);
		for( r in recipients) m.setRecipient(r.email,r.name,r.userId);
		m.setSender(sender.email,sender.name,sender.userId);
		m.setHtmlBody(this.htmlBody);
		m.setTextBody(this.textBody);


		this.lock();
		this.tries++;

		try{
			mailer.send(m,null,afterSendCb);
			this.sdate = Date.now();
			this.rawStatus = null;
		}catch(e:Dynamic){
			this.sdate = null;
			this.rawStatus = Std.string(e);
		}
		
		this.update();

	}


	function afterSendCb(status:MailerResult){
		this.status = status;
		this.update();
	}
	
	
	
	
}