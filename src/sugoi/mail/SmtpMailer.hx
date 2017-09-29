package sugoi.mail;
import tink.core.Future;
import tink.core.Noise;
import sugoi.mail.IMailer;
import smtpmailer.Address;

/**
 * Send emails thru SMTP by using ben merckx's library 
 * @ref https://github.com/benmerckx/smtpmailer
 */
class SmtpMailer implements IMailer
{
	var m : smtpmailer.SmtpMailer;
	
	public function new(){}
	
	public function init(conf:Dynamic) :IMailer
	{
		m = new smtpmailer.SmtpMailer({
			host: conf.smtp_host,
			port: conf.smtp_port,
			auth: {
				username: conf.smtp_user,
				password: conf.smtp_pass
			}
		});
		
		return this;
	}
	
	public function send(e:sugoi.mail.IMail,?callback:MailerResult->Void) 
	{
		var surprise = m.send({
			subject: e.getSubject(),
			from: new Address({address:e.getSender().email}),
			to: Lambda.array(Lambda.map(e.getRecipients(), function(x) return new Address({address:x.email}) )),
			headers : e.getHeaders(),
			content: {
				text: e.getTextBody(),
				html: e.getHtmlBody()
			},
			attachments: []
		});
		
		if (callback != null){
			
			surprise.handle(function(s){
				
				var map = new MailerResult();
				
				switch(s){
					case Success(_):
						map.set("*",Success(Sent));
						
					case Failure(e):
						map.set("*",Failure(GenericError(e)));
				}
				
				callback(map);
			});
		}
	}
	
}