package mt.text.translate;

/**
 * Translate from "simple" text format.
 *
 * If many values are found for a key,
 * a random one is chosen.
 *
 * e.g :
 *
 * key1
 * 	value1
 * 	value2
 * key2
 * 	value2
 * 	value2
 *
 *
 */
class TSimple implements ITranslate{
	var texts	: Hash<Array<String>>;
	//var texts			: Hash<Array<String>>;
	var rseed			: mt.Rand;
	var used 			: Hash<Array<String>>; //stock already used sentences

	public var throwExceptionOnUnfoundKey:Bool;

	public function new() {
		used = new Hash<Array<String>>();
		throwExceptionOnUnfoundKey = true;

	}

	static function fatal(err:String) {
		throw "text.translate.TSimple : "+err;
	}

	public function init(raw:String,?seed:Int):Void {
		/*
		#if neko
		var raw = neko.io.File.getContent(App.config.TPL+"../../xml/"+App.config.LANG+"/texts.xml");
		#end
		#if flash
		var raw = haxe.Resource.getString(Game.LANG+".texts.xml");
		#end
		*/

		if ( raw==null || raw=="" )
			fatal("no data");

		if(seed == null) {
			seed = 777;
		}
		initSeed(seed);

		/*if (TEXTS==null) {*/
			// parsing
			texts = new Hash();

			var lines = raw.split("\n");
			var key : String = null;
			for (line in lines) {
				var trimmed = StringTools.trim(line);
				if ( trimmed.length==0 ) continue;
				if ( line.charAt(0)==" " )
					fatal("unexpected leading space around key "+key);
				if ( line.charAt(0)!="\t" )
					key = trimmed.toLowerCase();
				else {
					if ( key==null ) fatal("unexpected : "+line);
					if ( texts.get(key)==null ) texts.set(key,new Array());
					texts.get(key).push( trimmed );
				}
			}
		/*}*/
	}

	public inline function initSeed(s) {
		rseed = new mt.Rand(0);
		rseed.initSeed(s);
	}

	function isAlreadyUsed(key:String,sentence:String):Bool {
		if(used.get(key) != null) {
			return Lambda.has( used.get(key) , sentence );
		}else {
			return false;
		}

	}

	/**
	 * get the random value from a key
	 * @param	key
	 * @param	?rfunc 		Random function
	 * @param	?fl_firstRecurs=true
	 */
	public function get(key:String, ?rfunc:Int->Int, ?fl_firstRecurs=true):String {
		if (rfunc==null){
			rfunc = rseed.random;
		}
		key = key.toLowerCase();

		var list = texts.get(key);
		if ( key == null || list == null || list.length == 0 ) {
			if(throwExceptionOnUnfoundKey){
				fatal("Unknown key \"" + key + "\"");
			}else {
				return key;
			}
		}

		var str = "";

		/**
		 * avoid selecting an already selected random sentence
		 */
		if(used.get(key) != null && used.get(key).length >= list.length) { //if all have been already selected, reset
			//trace('reset stack');
			used.set(key,[]);
		}
		var i = 0;
		do {
			str = list[rfunc(list.length)];
			i++;
			//trace("str chosen : "+str+", already chosen :"+isAlreadyUsed(key, str));
		}while(isAlreadyUsed(key, str) && i<100 );

		//store the selected value
		var x = used.get(key);
		if(x == null) {
			x = new Array<String>();
		}
		x.push(str);
		used.set(key, x );

		/**
		 * can use keys in a string like "Hi %buddies%"
		 */
		var list = str.split("%");
		if (list.length>1) {
			str = "";
			var i = 1;
			for (v in list) {
				if (i%2==0)
					str += get(v,false);
				else
					str+=v;
				i++;
			}
		}

		return str;
	}

	/**
	 * Return a translated text with params like ::name:: in the text
	 * @param	key
	 * @param	?data
	 * @return
	 */
	public function format(key:String, ?data:Dynamic):String {
		var str = get(key);
		var list = str.split("::");
		var n = 0;
		if(data!=null){
			for (k in Reflect.fields(data)){
				str = StringTools.replace(str, "::" + k.substr(1) + "::", Reflect.field(data, k));
			}
		}
		return str;
	}

	public function _(key:String, ?data:Dynamic):String {
		return format(key, data);
	}

}
