package sugoi.i18n;

import sugoi.Web;

/**
  * @author tpfeiffer<thomas.pfeiffer@gmail.com> 
  */
class Locale
{	
	static public var texts	: GetText;
	
    public static function init(lang:String)
	{
		#if macro
		var file = sys.io.File.getBytes(Web.getCwd()+fileName(lang));
		#else
		App.log("loading "+fileName(lang));
		var file = sys.io.File.getBytes(Web.getCwd()+"../"+fileName(lang));
		//var file = sys.io.File.getBytes(Sys.programPath()+"/../../"+fileName(lang));
		#end
        texts = new GetText();
		texts.readMo(file);
	}
	
	inline static function fileName(lang:String)
	{
		return "lang/texts_" +lang+ ".mo";
	}
}
