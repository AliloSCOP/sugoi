package mt.net.helper;
import mt.Compat;
/**
 * BreadCrumb (fil d'ariane)
 *
 * For breadcrumb translation, 
 * create "breadcrumb_*" entries in the translation file for each section.
 *
 * @author fbarbut
 **/
class BreadCrumb{
	
	public var lang : String;
	public var sections : Array<String>;		/* raw sections like "game/tetris/highscores" */
	public var translation : Hash<String>;		/* translated sections */
	
	public function new(uri:String,?translator:String->String) {
		sections = [];
		translation = new Hash<String>();
		
		//remove GET params
		uri = uri.split('?')[0];

		if( uri.substr(0,1) == "/" )
			uri = uri.substr(1);
		var uri = uri.split('/');
	
		/*modify*/
		for (i in 0...uri.length) {
			var u = uri[i];
			if(u == null)
				continue;

			if(Std.parseInt(u) != null) {
				uri[i] = null;
				continue;
			}

			if(u == 'index.n' || u == '') {
				u = uri[i] = "home";
				continue;
			}
		}
		
		/*remove nulls*/
		uri = Lambda.array(Lambda.filter(uri,function(e) return e!=null));
		
		sections = uri;
		
		/*translation*/
		if(translator != null) {
			for(s in sections) {
				var name = translator("breadcrumb_" + s);
				if(name != "#breadcrumb_" + s + "#") {
					translation.set(s, name);
				}else {
					//no translation
					translation.set(s, s);
				}
			}
		}
		
		
	}
	

	public function toString(?mode=1, ?format:String):Dynamic {
		switch(mode) {
			case 1 :
				/* raw sections */
				return sections;
			case 2 :
				/* translated sections */
				return getTranslatedSections();
				
		}
		return null;
		
		//if(format != null) {
			//format = StringTools.replace(format, "::rank::", Std.string(rank));
			//format = StringTools.replace(format, "::suffix::", Std.string(suffix));
			//return format;
		//}else {
			//return rank + suffix;
		//}
		

		
	}
	
	public function getTranslatedSections() {
		var out = [];
		for(s in sections) {
			out.push(translation.get(s));
		}
		return out;
	}
	
	
	
}

