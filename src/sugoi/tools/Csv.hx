package sugoi.tools;

/**
 * CSV Import / Export
 * @author fbarbut<francois.barbut@gmail.com>
 */
class Csv
{

	public var separator :String;
	public var datas : Array<Array<String>>;
	public var headers : Array<String>;
	
	public function new() 
	{
		separator = ",";
		datas = [];
		headers = [];
	}
	
	public function addDatas(d:Array<Dynamic>) {
		datas.push( Lambda.array(Lambda.map(d, function(x) return StringTools.trim(Std.string(x)) )) );
	}
	
	/**
	 * Export Datas in CSV
	 */
	public function export():String {
		return "";
	}
	
	/**
	 * Import CSV Datas
	 * @param	d
	 * @return
	 */
	public function importDatas(d:String):Array<Array<String>> {
		var data = d.split("\n");
		var out = [];
		
		//fix quoted fields with comas inside : "23 allée des Taupes, 46100 Camboulis"
		for (d in data) {				
			var x = d.split('"');
			for (i in 0...x.length) {
			if (i % 2 == 1) x[i] = StringTools.replace(x[i], separator, "|");
			}
			d = x.join("");
			
			out.push(d.split(separator));
			
			for (u in out) {
				for (i in 0...u.length) {
			u[i] = StringTools.replace(u[i], "|", separator);
				}
			}
		}
			
		//cleaning
		for ( o in out.copy() ) {
			//remove empty lines
			if (o == null || o.length <= 1) {
				out.remove(o);
				continue;
			}
			
			//nullify empty fields
			for (i in 0...o.length) {
				
				if (o[i] == "") {
					o[i] = null;
					continue;
				}
				
				//clean spaces and useless chars
				o[i] = StringTools.trim(o[i]);
				o[i] = StringTools.replace(o[i], "\n", "");
				o[i] = StringTools.replace(o[i], "\t", "");
				o[i] = StringTools.replace(o[i], "\r", "");
			}

		}
		
		//remove headers
		out.shift(); 
			
		//utf-8 check
		for ( row in out.copy()) {
			
			for ( i in 0...row.length) {
				var t = row[i];
				if (t != "" && t != null) {
					try{
						if (!haxe.Utf8.validate(t)) {
							t = haxe.Utf8.encode(t);	
						}
					}catch (e:Dynamic) {}
					row[i] = t;
				}
			}
		}
		
		return out;
	}
	
}