package sugoi.i18n;


/**
  * @author tpfeiffer<thomas.pfeiffer@gmail.com> 
  */
class Locale
{	
	static public var texts	: GetText;
	
	/**
	 * Cache gettext objects in case of many language switches
	 * (like in a cron action which lead to send many emails in various languages)
	 */
	static public var cache = new Map<String,GetText>();
	
	public static function init(lang:String,?callback:GetText->Void):GetText
	{
		
		//Load mo file in various runtimes : macro, js and serverside
		#if macro
		var filePath = sugoi.Web.getCwd() + "../www/" + fileName(lang);
		if( !sys.FileSystem.exists(filePath) ){
			//Create MO file from PO file. "Gettext" package should be installed.
			var cmd = 'msgfmt -o $filePath '+filePath.substr(0,filePath.length-3)+'.po';
			Sys.println(cmd);
			var p = new sys.io.Process(cmd);
			p.exitCode();			
		}
		var file = sys.io.File.getBytes( filePath );
		texts = new GetText();
		texts.readMo(file);
		return texts;
		#elseif js
		var file : haxe.io.Bytes = null;
		var r = new js.html.XMLHttpRequest();
		r.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
		r.onreadystatechange = function(e:js.html.Event){
			if (r.readyState == js.html.XMLHttpRequest.DONE){
				file = haxe.io.Bytes.ofData(r.response);
				texts = new GetText();
				texts.readMo(file);
				callback(texts);
			}			
		}
		r.open('GET', '/'+fileName(lang), true);
		r.send();
		return null;
		#else
		/*var texts = cache.get(lang);
		trace(texts);
		if (texts == null){*/
			var file = null;
			try{
				file = sys.io.File.getBytes(sugoi.Web.getCwd() + "/" + fileName(lang));
			}catch(e:Dynamic){
				//fail safely
				App.current.session.addMessage("Cannot read translation file : "+Std.string(e));
			}
			texts = new GetText();
			if(file!=null) texts.readMo(file);
			/*cache.set(lang,texts);
		}*/
		return texts;
		#end
		
		
	}
	
	
	inline static function fileName(lang:String)
	{
		return "lang/texts_" +lang+ ".mo";
	}
}
