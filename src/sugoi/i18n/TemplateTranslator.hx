package sugoi.i18n;

import haxe.macro.Expr;
import haxe.macro.Context;

 /**
  * Computes translated templates from master templates
  * 
  * @author tpfeiffer<thomas.pfeiffer@gmail.com> 
  */
class TemplateTranslator
{
    macro public static function parse(path:ExprOf<String>)
    {
        Sys.println("TemplateTranslator::parse");
		var langs = new sugoi.Config(neko.Web.getCwd()).LANGS;
        
        for( lang in langs ) {
            Sys.println("Generating the "+lang+" template files");
			Locale.init(lang);
			translateTemplates(lang, "lang/master");
		}

		return macro {}
	}

    #if macro
    static public function translateTemplates(lang:String, folder:String)
    {
        var strReg = ~/(::_\("([^"]*)"\)::)+/ig;

		for( f in sys.FileSystem.readDirectory(folder) ) {
			// Parse sub folders
			if(sys.FileSystem.isDirectory(folder+"/"+f) ) {
                //create target directory
                var langPath = StringTools.replace(folder+"/"+f, "master", lang);
                sys.FileSystem.createDirectory(langPath);
				translateTemplates(lang, folder+"/"+f);
				continue;
			}
			
			var isTemplateFile = f.substr(f.length - 4) == ".mtt";
			if( !isTemplateFile )
				continue;

			var c = sys.io.File.getContent(folder+"/"+f);
			var out = strReg.map(c, function(e) {
                var str = e.matched(2);
                Sys.println("str matched:"+str);
                // Ignore commented strings
                var i = str.indexOf("//");
                if( i >= 0 && i < strReg.matchedPos().pos )
                    return "";
                
                var cleanedStr = str;
                // Translator comment
                var comment : String = null;
                if( cleanedStr.indexOf("||") >= 0 ) {
                    var parts = cleanedStr.split("||");
                    if( parts.length!=2 ) {
                        throw "Malformed translator comment";
                        return "";
                    }
                    comment = StringTools.trim(parts[1]);
                    cleanedStr = cleanedStr.substr(0,cleanedStr.indexOf("||"));
                    cleanedStr = StringTools.rtrim(cleanedStr);
                }

                return Locale.texts.get(cleanedStr);
            });

            //copy the file to the correct new folder
            var filePath = StringTools.replace(folder+"/"+f, "master", lang);
            var langFile = sys.io.File.write(filePath, false);
            langFile.writeString(out);
            langFile.flush();
            langFile.close();
		}
    }
    #end
}