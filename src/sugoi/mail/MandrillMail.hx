package mt.net.mail;
import mtwin.mail.Part;

/**
 * send an email via Mandrill.com SMTP service
 * 
 * needs mtwin haxelib for SMTP
 */
class MandrillMail extends BaseMail, implements IMail
{
	public static var USER = App.config.get('mt.net.mail.MandrillMail.USER');
	public static var PASS = App.config.get('mt.net.mail.MandrillMail.PASS');
	public static var HOST = App.config.get('mt.net.mail.MandrillMail.HOST');
	public static var PORT = App.config.getInt('mt.net.mail.MandrillMail.PORT');
	
	public var multipleRecipients : Array<String>;
	
	public function new() {
		super();
		multipleRecipients = [];
	}
	
	override public function send() {
		var p = new mtwin.mail.Part("multipart/alternative",false,'utf-8');
		
		p.setHeader("From", senderName + "<" + senderEmail + ">");
		
		if (multipleRecipients.length > 0) {
			p.setHeader("To", "<" + multipleRecipients.join(">,<") + ">");
			recipientEmail = multipleRecipients.join(">,<");
		}else {
			p.setHeader("To", recipientName + "<"+recipientEmail + ">");	
		}
		
		p.setDate();
		p.setHeader("Subject", title);
		
	  
		if(htmlBody!=null){
			var h = p.newPart("text/html");
			h.setContent(htmlBody);
		}
		if(textBody!=null){
			var t = p.newPart("text/plain");
			t.setContent(textBody);
		}
		
		if (textBody == null && htmlBody == null) throw "no body to send";
		
		var dest = [];
		if (multipleRecipients.length > 0) {
			dest = multipleRecipients;
		}else {
			dest = [recipientEmail];
		}
		mtwin.mail.Smtp.send( HOST, senderEmail, dest, p.get(),PORT,USER,PASS );
	}
	
}