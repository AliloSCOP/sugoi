package sugoi.i18n;


/**
  * @author tpfeiffer<thomas.pfeiffer@gmail.com> 
  */
class Locale
{	
	static public var texts	: GetText;
	
	public static function init(lang:String,?callback:GetText->Void)
	{
		#if macro
		var file = sys.io.File.getBytes(sugoi.Web.getCwd() + fileName(lang));
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
		r.open('GET', '/js/texts_$lang.mo', true);
		r.send();
		
		#else
		var file = sys.io.File.getBytes(sugoi.Web.getCwd() + "../" + fileName(lang));
		texts = new GetText();
		texts.readMo(file);
		#end
		
		
       
	}
	
	
	inline static function fileName(lang:String)
	{
		return "lang/texts_" +lang+ ".mo";
	}
}
