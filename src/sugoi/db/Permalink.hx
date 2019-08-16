package sugoi.db;
import sys.db.Types;

/**
 *  Permalink utility :
    Manage a bunch of unique links linked to entities
 */
@:id(link)
class Permalink extends sys.db.Object
{
	public var link : SString<128>;
	public var entityType : SString<64>;
    public var entityId : SInt;
	
	public function new(){
		super();
	}
	
	/**
		Get from link
	**/
	public static function get(link:String):Permalink {
		var p = manager.select($link==link, false);
		if(p!=null) p.link = p.link.toLowerCase();
		return p;
	}

	/**
		Get from entity
	**/
	public static function getByEntity(id:Int,type:String){
		return manager.select($entityId==id && $entityType==type, false);
	}


	/**
		Filter a string to propose a potential link
	**/
	public static function filter(str:String):String{

		str = str.toLowerCase();

		//replace some chars
		for(x in ["à","â","ä"]){
			str = StringTools.replace(str,x,"a");
		}
		for(x in ["é","è","ë","ê"]){
			str = StringTools.replace(str,x,"e");
		}
		for(x in ["î","ï"]){
			str = StringTools.replace(str,x,"i");
		}
		for(x in ["ö","ô"]){
			str = StringTools.replace(str,x,"o");
		}

		str = StringTools.replace(str,"ç","c");
		str = StringTools.replace(str,"œ","oe");
		str = StringTools.replace(str,"ù","u");
		str = StringTools.replace(str," ","-");

		//filtering
		var out = new StringBuf();
		for( i in 0...str.length){

			var code = str.charCodeAt(i);
			if(code >= 65 && code <= 90){
				//A-Z
				out.addChar(code);
			}else if ( code >= 97 && code <= 122 ){
				//a-z
				out.addChar(code);
			}else if ( code== 45 ){
				//-
				out.addChar(code);
			}else if ( code >= 48 && code <= 57 ){
				//0-9
				out.addChar(code);
			}
		}

		return out.toString();
	}

	/**
		Propose a list a available links
	**/
	public static function propose(str:String,infos:Array<String>):Array<String>{

		var out = [];
		str = StringTools.trim(str.toLowerCase());
		infos = infos.map(filter);

		var withSpaces = filter(str);
		if(!exists(withSpaces)) out.push(withSpaces);

		//use additionnal infos to make more propositions
		for( i in infos){
			if(!exists(withSpaces+"-"+i)) out.push(withSpaces+"-"+i);			
		}

		var noSpaces = filter(StringTools.replace(str," ",""));
		infos = infos.map(function(s) return StringTools.replace(s,"-","") );
		if(!exists(noSpaces)) out.push(noSpaces);

		//use additionnal infos to make more propositions
		for( i in infos){
			if(!exists(noSpaces+i)) out.push(noSpaces+i);			
		}

		return out;
	}

	public static function exists(link:String):Bool{
		return get(link)!=null;
	}
	
}