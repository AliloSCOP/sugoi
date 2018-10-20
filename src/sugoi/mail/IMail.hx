package sugoi.mail;

/**
 * Interface that represents an email message.
 */
interface IMail
{
	public function setSender(email:String, ?name:String, ?userId:Int):IMail;
	public function setRecipient(email:String, ?name:String, ?userId:Int):IMail;
	public function addRecipient(email:String, ?name:String, ?userId:Int):IMail;	
	public function setSubject(subject:String):IMail;
	public function setHeader(key:String, value:String):IMail;
	public function setHtmlBody(body:String):IMail;
	public function setTextBody(body:String):IMail;
	
	public function getSender(): {?userId:Int,email:String,name:String};
	public function getRecipients():Array<{?userId:Int,email:String,name:String}>;
	public function getSubject():String;
	public function getTitle():String;
	public function getHtmlBody():String;
	public function getTextBody():String;
	public function getHeaders():Map<String,String>;
}