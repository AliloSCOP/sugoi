package sugoi.i18n;


/**
  * @author tpfeiffer<thomas.pfeiffer@gmail.com> 
  */
class Locale
{	
	static public var texts	: GetText;
	
	public static function init(lang:String,?callback:GetText->Void)
	{
		//Load mo file in various runtimes : macro, js and serverside
		#if macro
		trace(sugoi.Web.getCwd() + "www" + fileName(lang));
		var file = sys.io.File.getBytes(sugoi.Web.getCwd() + "www/" + fileName(lang));
		
		texts = new GetText();
		texts.readMo(file);
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
		
		#else
		var file = sys.io.File.getBytes(sugoi.Web.getCwd() + "/" + fileName(lang));
		texts = new GetText();
		texts.readMo(file);
		#end
	}
	
	
	inline static function fileName(lang:String)
	{
		return "lang/texts_" +lang+ ".mo";
	}
}
