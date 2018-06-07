package sugoi.mail;
import tink.core.Future;
import tink.core.Outcome;

/**
 * Errors that occurs after sending an email thru a mailer
 */
enum MailerError{
	GenericError(e:tink.core.Error);
	HardBounce;	//bad mailbox
	SoftBounce; //mailbox exists but is full or not reachable
	Spam;		//email is considered spam
	Unsub;		//this user unsubscribed from this service/list
	Unsigned; 	//the sender is invalid ( i.e does not match the SPF records )
}

enum MailerSuccess{
	Sent;
	Queued;
}

typedef MailerResult = Map<String,Outcome<MailerSuccess,MailerError>>

/**
 * Interface for "Mailers" 
 * 
 * @author fbarbut
 */
interface IMailer 
{
	/**
	 * init with a configuration object
	 */
	public function init(?conf:{smtp_host:String,smtp_port:Int,smtp_user:String,smtp_pass:String}):IMailer;
	
	/**
	 * Sends an email. A callback can be defined to handle the result
	 */
	public function send(email:IMail,?params:Dynamic,?callback:MailerResult->Void):Void;
	
}