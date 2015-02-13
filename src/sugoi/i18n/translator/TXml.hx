package mt.text.translate;

/**
 * Translation class fed by XML like
 * <texts>
	<t id="achtype_score">Atteindre un score de ::score::</t>
	<t id="achtype_level">Atteindre le level ::level::</t>
	<t id="achtype_time">Faire un temps de moins de  ::time::</t>
	<t id="achtype_custom">Faire un truc spécial dans ce jeu</t>
   </texts>
 */

class TXml implements ITranslate{

	static var TEXTS = new Hash<String>();
	
	public function new() {
		
	}
	
	public function init (raw:String, ?seed:Int) {
		
		var xml = Xml.parse( raw ).firstChild();
		
		//trace ( xml.elements() );
		
		var h = new Hash();
		for( x in xml.elements() ) {
			var id = x.get("id");
			if( id == null )
				throw "Missing 'id' in data.xml";
			if( h.exists(id) )
				throw "Duplicate id '"+id+"' in data.xml";
			var buf = new StringBuf();
			for( c in x )
				buf.add(c.toString());
			var s = mt.deepnight.Lib.replaceTag(buf.toString(), "*", "<strong>", "</strong>");
			s = mt.deepnight.Lib.replaceTag(s, "||", "<em>", "</em>");
			//trace("text : "+id+", "+s);
			h.set(id,s);
		}
		
		TEXTS = h;
	}

	public function format(key:String, ?data:Dynamic):String {
		var str = TEXTS.get(key);
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
