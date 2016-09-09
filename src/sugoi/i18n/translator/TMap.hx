package sugoi.i18n.translator;

/**
 * Simple Map<String,String> based Translator
 *
 * @author fbarbut
 */
class TMap implements ITranslator{

	var texts : Map<String,String> = null;
	var lang : String;


	public function new(arr: Map<String,String>, lang:String) {
		this.lang = lang;
		texts = arr;
	}

	public function _(key:String, ?data:Dynamic):String {
		if (key == null) throw "key is null";

		var str = texts.get(key);

		if(str == null) {
			//App.log("key \""+key+"\" not found in "+texts);
			str = key;
		}


		if(data!=null){
			//var list = str.split("::");
			for (k in Reflect.fields(data)){
				str = StringTools.replace(str, "::" + k.substr(1) + "::", Reflect.field(data, k));
			}
		}
		return str;
	}
	
	public function getStrings(){
		return texts;
	}



}
