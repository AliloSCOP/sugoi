package sugoi.mail;

interface IMail
{
	public function setSender(email:String, ?name:String):Void;
	public function setRecipient(email:String, ?name:String, ?userId:Int):Void;
	public function addRecipient(email:String, ?name:String, ?userId:Int):Void;
	public function getRecipients():Array<String>;
	public function setSubject(subject:String):Void;
	public function setHeader(key:String, value:String):Void;
	public function send():Void;
}