package sugoi.i18n.translator;

/**
 * GetText (*.po/*.mo) translator
 * @doc https://www.gnu.org/software/gettext/manual/html_node/MO-Files.html
 * @author fbarbut
 */
class GetText implements sugoi.i18n.translator.ITranslator{

	public var texts : Map<String,String>;


	public function toString() {
		return "#GetText";
	}

	public function _(str:String, ?params : Dynamic):String {
		if(texts == null) throw "no data in dictionnary";
		if(texts.exists(str)) str = texts.get(str);

		var list = str.split("::");
		var n = 0;
		if(params!=null){
			for (k in Reflect.fields(params)){
				str = StringTools.replace(str, "::" + k.substr(1) + "::", Reflect.field(params, k));
			}
		}

		return str;
	}


	public function loadMoFile(d:haxe.io.Bytes) {
		var r =  new MoReader(d);
		texts = r.parse();
		r = null;
	}


	public function new()
	{


	}

	/**
	 * parse all the project source code and generate the *.pot file
	 */
	macro public static function parse(codePath:String, potFilePath:String) {
		Sys.println(codePath);

		var path = codePath;
		var data = new Map<String,{path:String}>();
		explore(path, data);
		writePotFile(data,potFilePath);
		return macro { }; //returns an empty expression
	}
	


	#if macro

	/**
	 * Generates the POT (PO template) file which contains all the keys to translate
	 */
	static function writePotFile(data:Map<String,{path:String}>, potFilePath:String ) {
		var pot = new StringBuf();
		var d = null;
		for(k in data.keys()) {
			d = data.get(k);
			pot.add( "#"+d.path+"\n" );
			pot.add( "msgid \""+k+"\"\n" );
			pot.add( "msgstr \"\"\n\n" );
		}
		sys.io.File.saveContent(potFilePath, pot.toString());
	}

	/**
	 * function recursive qui analyse les dossiers/fichiers
	 * @param	folder
	 * @param	pot
	 */
	static function explore(folder:String, data) {
		Sys.println("parsing "+folder);
		for(f in sys.FileSystem.readDirectory(folder) ) {

			 if(f.substr(f.length - 3) == ".hx") {
				 var c = sys.io.File.getContent(folder+"/"+f);
				var reg = ~/t\._\("([^"]+)"\)/i; // match t._("truc"). Le point et la parenthese sont escapés.
				for( line in c.split("\n")) {

					if(line == "") continue;
					var r = reg.match(line);
					if(r) {
						data.set(reg.matched(1),{path:folder+"/"+f});
					}
				}

			 }else if( sys.FileSystem.isDirectory(folder+"/"+f) ) {
				explore(folder+"/"+f,data);

			}

		}

	}
	#end

}

/**
 * GNU GetText MO file reader
 */
class MoReader
{
	private var original_table_offset:UInt;
	private var translated_table_offset:UInt;
	private var hash_num_entries:UInt;
	private var hash_offset:UInt;
	private var data:haxe.io.BytesInput;

	static var MAGIC:UInt = 0x950412DE;
	static var MAGIC2:UInt = 0xDE120495;

	public function new(data:haxe.io.Bytes):Void
	{
		this.data = new haxe.io.BytesInput(data);
	}

	public function parse():Map<String,String>
	{
		var d = data;
		var header : UInt = d.readInt32();

		if(header != MAGIC && header != MAGIC2) {
			throw "Bad MO file header : " + header;
		}

		var revision:UInt = d.readInt32();
		if (revision > 1){
			throw "Bad MO file format revision : "+revision;
		}

		var num_strings:UInt = d.readInt32();
		original_table_offset= d.readInt32();
		translated_table_offset = d.readInt32();
		hash_num_entries= d.readInt32();
		hash_offset= d.readInt32();

		var texts = new Map();
		for (i in 1...num_strings)
		{
			texts.set(getOriginalString(i), getTranslatedString(i));
		}

		return texts;

	}

	function getTranslatedString(index:Int):String
	{
		return getString(translated_table_offset + 8 * index );
	}

	function getOriginalString(index:Int):String
	{
		return getString(original_table_offset + 8 * index );
	}

	function getString(offset:UInt):String
	{
		data.position = offset;
		var length :UInt = data.readInt32();
		var pos :UInt = data.readInt32();
		data.position = pos;
		return data.readString(length);
	}
}