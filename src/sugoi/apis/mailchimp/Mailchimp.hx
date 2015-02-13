package sugoi.apis.mailchimp;
import sugoi.apis.linux.Curl;


class Mailchimp 
{
	var lastError:String;
	var dataCenter:String;
	var apiKey:String;
	var listId:String;
	var serviceUrl : String;
	
	public function new(apiKey:String, listId:String, ?dataCenter:String = null) 
	{
		this.apiKey = apiKey;
		this.listId = listId;
		this.dataCenter = (dataCenter == null) ? apiKey.split("-")[1] : dataCenter;
		serviceUrl = "https://"+dataCenter+".api.mailchimp.com/2.0/";
	}
	
	/**
	 * Access up to the previous 180 days of daily detailed aggregated activity stats for a given list. 
	 * Does not include AutoResponder activity.
	 * 
	 * @return [
	 * 	{"user_id":13422379,"day":"2013-07-25","emails_sent":0,"unique_opens":0,"recipient_clicks":0,"hard_bounce":0,"soft_bounce":0,"abuse_reports":0,"subs":1,"unsubs":0,"other_adds":0,"other_removes":0},
	 *  {"user_id":13422379,"day":"2013-10-24","emails_sent":0,"unique_opens":0,"recipient_clicks":0,"hard_bounce":0,"soft_bounce":0,"abuse_reports":0,"subs":1,"unsubs":0,"other_adds":0,"other_removes":0},
	 *  {"user_id":13422379,"day":"2013-11-24","emails_sent":0,"unique_opens":0,"recipient_clicks":0,"hard_bounce":0,"soft_bounce":0,"abuse_reports":0,"subs":1,"unsubs":0,"other_adds":0,"other_removes":0}
	 * ]
	 */
	public function getActivity() {
		
		var curl = Curl.get();
		return haxe.Json.parse( curl.call("POST", serviceUrl + "lists/activity/", { }, haxe.Json.stringify( { apikey:apiKey, id:listId } ) ) );
		
	}
	
	/**
	 * Subscribe (or update) a member to a list
	 * 
	 * @see https://apidocs.mailchimp.com/api/2.0/lists/subscribe.php
	 * @return { euid => a519e7b675, leid => 59171769, email => francois.barbut@gmail.com }
	 */
	public function subscribe(listId:String, email: { email:String }, merge_vars: { FNAME:String, LNAME:String, mc_language:String},custom_tags:Dynamic, double_option:Bool, update_existing:Bool, send_welcome:Bool ) {
		//merge custom tags with merge_vars
		if (custom_tags != null) {
			for (f in Reflect.fields(custom_tags)) {
				Reflect.setField(merge_vars, f, Reflect.getProperty(custom_tags, f));
			}	
		}
		
		var data = { 
			apikey:this.apiKey,
			id:listId,
			email:email,
			merge_vars:merge_vars,
			double_option:double_option,
			update_existing:update_existing,
			send_welcome:send_welcome
		};
		
		var curl = Curl.get();
		var res = curl.call("POST", serviceUrl + "lists/subscribe/", { }, haxe.Json.stringify(data));
		//Sys.println(curl.params);
		return haxe.Json.parse(res);
	}
	
	
	//public function batchSuscribe(listId:String,
	
	
}