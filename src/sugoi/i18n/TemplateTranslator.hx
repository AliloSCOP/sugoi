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
    macro public static function parse(path:String)
    {		
		var langs = new sugoi.Config().LANGS;
        
        for( lang in langs ) {
            Sys.println(lang + " : Generating template files");
			Locale.init(lang);
			translateTemplates(lang, path);
			//translationForJs(lang);			
		}

		return macro {}
	}

    #if macro
	/*static public function translationForJs(lang:String){
		
		var out = new StringBuf();
		var v = "";
		out.add("var texts = [];\n");		
		for ( k in Locale.texts.texts.keys()){
			v = Locale.texts.get(k);
			k = StringTools.replace(k, '\"', '\\"');
			v = StringTools.replace(v, '\"', '\\"');
			
			out.add('texts["$k"] = "$v";\n');
		}
		var path = sugoi.Web.getCwd() + "www/js/texts_" + lang + ".js";
		sys.io.File.saveContent(path, out.toString());
		Sys.println(lang +" : Save js translation file (" + path + ")");		
	}*/
	
    static public function translateTemplates(lang:String, folder:String)
    {
        //Sys.println('$lang : $folder');
		
		//var strReg = ~/(::_\("([^"]*)"\)::)+/ig;
        //var strReg = ~/(::_\([ ]*"([^"]+)+"[ ]*\)::)+/ig;
        var strReg = ~/_\([ ]*"((?:[^"\\]+|\\.)*)"[ ]*(?:,[ ]*{[.,:\w\s\(\)]*})?\)/igm;
		
		for ( f in sys.FileSystem.readDirectory(folder) ) {
			
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
				
			var filePath = StringTools.replace(folder+"/"+f, "master", lang);
            Sys.println(lang + " : " + filePath);	

			var c = sys.io.File.getContent(folder + "/" + f);
			var out = "";
			try{
				out = strReg.map(c, function(e) {
					var str = e.matched(1);
					//Sys.println("str matched:"+str);
					// Ignore commented strings
					//var i = str.indexOf("//");
					//if( i >= 0 && i < strReg.matchedPos().pos )
					//    return "";
				   
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

					//Sys.println(e.matched(0)+" replace "+str+" by "+Locale.texts.get(cleanedStr));
					var output = StringTools.replace( e.matched(0), str, Locale.texts.get(cleanedStr) );
					//Sys.println("output:"+output);
					return output;
					//return Locale.texts.get(cleanedStr);
				   
					/*
					function getVars(ereg:EReg, input:String, index:Int = 0):Array<String> {
						var matches = [];
						while (ereg.match(input)) {
							matches.push(ereg.matched(index)); 
							input = ereg.matchedRight();
						}
						return matches;
					}
					var eregVars = ~/(?:::([^:]+)::)/i;
					var aVars = getVars(eregVars, strTmp,1);
					var sVars = aVars.map(function(v) { return v+":"+v; });
					var variables = '{'+sVars.join(",")+'}';
					
					var contentWithVars = StringTools.replace(e.matched(1), str, strTmp+","+variables);
					return StringTools.replace(contentWithVars, "::_", "::__");
					*/
				});
			}catch (e:Dynamic){
				throw "Error in " + f + " : " + e;
			}

            //copy the file to the correct new folder
			var langFile = sys.io.File.write(filePath, false);
			out = StringTools.replace(out, "\r", "");//for an unknown reason, there was double newlines
            langFile.writeString(out);
            langFile.flush();
            langFile.close();
		}
    }
    #end
}
