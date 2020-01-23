package sugoi.tools;

/**
 * CSV Import-Export Tool
 * Based on thx.csv
 * 
 * @author fbarbut<francois.barbut@gmail.com>
 */
class Csv
{
	public var separator :String;
	var headers : Array<String>;	//datas accessible in both forms
	public var datas : Array<Array<String>>;
	public var datasAsMap : Array<Map<String,String>>;
	public var step:Int;//@deprecated
	
	public function new() 
	{
		separator = ",";
		datas = [];
		headers = [];
	}
	
	public function setHeaders(_headers){
		headers = _headers;
	}
	
	public function addDatas(d:Array<Dynamic>) {
		datas.push( Lambda.array(Lambda.map(d, function(x) return StringTools.trim(Std.string(x)) )) );
	}
	
	public function getHeaders(){
		return headers;
	}
	
	public function getDatas():Array<Array<String>>{
		return datas;
	}
	
	public function isEmpty(){
		return datasAsMap == null || datasAsMap.length == 0;
	}
	
	
	/**
	 * Import CSV / DCSV datas as Maps
	 */
	public function importDatasAsMap(d:String):Array<Map<String,String>>{
		
		if (headers.length == 0) throw "CSV headers should be defined";
		
		//separator detection
		try{
			var x = d.split("\n");
			if (x[0].split(";").length > x[0].split(",").length) separator = ";";
			
		}catch (e:Dynamic){}

		//trace(separator);
	
		var _datas = new Array<Array<String>>();
		if (separator == ","){
			_datas = thx.csv.Csv.decode(d);
		}else{
			_datas = thx.csv.DCsv.decode(d);
		}
		/*for(line in d.split("\n")){
			_datas.push(line.split(separator));
		}*/


		//removes headers
		_datas.shift(); 
		
		//cleaning
		for ( o in _datas.copy() ) {

			//remove empty lines
			if (o == null || o.length <= 1) {
				_datas.remove(o);
				continue;
			}

			//remove remaining quotes 
			for (i in 0...o.length) {
				var s = o[i];
				if(s.substr(0,1)=="\""){
					s = s.substr(1);
				}
				if(s.substr(s.length-1,1)=="\""){
					s = s.substr(0,s.length-1);
				}
				o[i] = s;

			}
			
			//nullify empty fields
			for (i in 0...o.length) {
				
				if (o[i] == "" || o[i] == "null" || o[i]=="NULL") {
					o[i] = null;
					continue;
				}
				
				//clean spaces and useless chars
				o[i] = StringTools.trim(o[i]);
				o[i] = StringTools.replace(o[i], "\n", "");
				o[i] = StringTools.replace(o[i], "\t", "");
				o[i] = StringTools.replace(o[i], "\r", "");
			}
			
			//remove empty lines
			if (isNullRow(o)) _datas.remove(o);

		}		
		
		//cut columns which are out of headers		
		for ( d in _datas){
			datas.push( d.copy().splice(0, headers.length) );
		}
		
		//maps
		datasAsMap = new Array<Map<String,String>>();
		
		for ( d in datas){
			
			var m = new Map();
			
			for ( h in 0...headers.length){
				
				//nullify
				var v = d[h];
				if ( v == "" || v == "null" || v=="NULL" ) v = null;				
				m[headers[h]] = v;
			}
			
			datasAsMap.push(m);
		}
		
		return datasAsMap;
		
	}
	
	/**
	 * Import CSV Datas
	 * 
	 * @deprecated Use importDatasAsMap instead
	 */
	public function importDatas(d:String):Array<Array<String>> {
		
		d = StringTools.replace(d, "\r", ""); //vire les \r
		
		var data = d.split("\n");
		
		//separator detection
		if (data[0].split(";").length > data[0].split(",").length) separator = ";";
		
		var out = new Array<Array<String>>();
		
		var rowLen = null;
		if (headers != null && headers.length > 0) rowLen = headers.length;
		
		//fix quoted fields with comas inside : "23 allée des Taupes, 46100 Camboulis"
		for (d in data) {				
			var x = d.split('"');
			for (i in 0...x.length) {
			if (i % 2 == 1) x[i] = StringTools.replace(x[i], separator, "|");
			}
			d = x.join("");
			var row = d.split(separator);
			if (rowLen != null) row = row.splice(0, rowLen); //no extra columns
			
			out.push(row);
		}
		
		for (u in out) {
			for (i in 0...u.length) {
				u[i] = StringTools.replace(u[i], "|", separator);
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
				
				if (o[i] == "" || o[i] == "null" || o[i]=="NULL") {
					o[i] = null;
					continue;
				}
				
				//clean spaces and useless chars
				o[i] = StringTools.trim(o[i]);
				o[i] = StringTools.replace(o[i], "\n", "");
				o[i] = StringTools.replace(o[i], "\t", "");
				o[i] = StringTools.replace(o[i], "\r", "");
			}
			
			//remove empty lines
			if (isNullRow(o)) out.remove(o);

		}
		
		//remove headers
		out.shift(); 
			
		//utf-8 check
		for ( row in out.copy()) {			
			for ( i in 0...row.length) {
				var t = row[i];
				if (t != "" && t != null) {
					// try{
					// 	if (!haxe.Utf8.validate(t)) {
					// 		t = haxe.Utf8.encode(t);	
					// 	}
					// }catch (e:Dynamic) {}
					row[i] = t;
				}
			}
		}
		
		return out;
	}
	
	
	private function isNullRow(row:Array<String>):Bool{
		for (c in row) if (c != null) return false;
		return true;
	}
	
	/**
	 * Print datas as a CSV file
	 * 
	 * @param	data
	 * @param	headers
	 * @param	fileName
	 */
	public static function printCsvDataFromObjects(data:Iterable<Dynamic>,headers:Array<String>,fileName:String) {
		
		App.current.setTemplate('empty.mtt');
		Web.setHeader("Content-type", "text/csv");
		Web.setHeader('Content-disposition', 'attachment;filename="$fileName.csv"');

		if(App.t==null)	{
			Sys.println(Lambda.map(headers,function(t) return t).join(";"));
		}else{
			Sys.println(Lambda.map(headers,function(t) return App.t._(t)).join(";"));
		}
		
		for (d in data) {
			var row = [];
			for ( f in headers){
				var v = Reflect.getProperty(d, f);
				row.push( "\""+(v==null?"":v)+"\"");	
			}
			Sys.println(row.join(";"));
		}
		return true;		
	}
	
	/**
	 * Separator is ";" for better compat with french excel users
	 */
	public static function printCsvDataFromStringArray(data:Array<Array<String>>,headers:Array<String>,fileName:String) {
		
		Web.setHeader("Content-type", "text/csv");
		Web.setHeader('Content-disposition', 'attachment;filename="$fileName.csv"');		
		Sys.println(Lambda.map(headers,function(t) return App.t._(t)).join(";"));
		
		for (r in data) {
			var row = [];
			for ( v in r ){	
				row.push( "\""+(v==null?"":v)+"\"");	
			}
			Sys.println(row.join(";"));
		}
		return true;		
	}

	public static function escape(str:String){
		if(str==null) return "";
		str = StringTools.replace(str,'"',"'");
		str.split("\n").join(" ");
		str.split("\r").join(" ");
		str.split("\t").join("    ");
		return str;


	}
	
	
	/**
	 * do a "array.shift()" on datas
	 */
	public function shift(){
		if (datasAsMap != null)	datasAsMap.shift();
		datas.shift();		
	}
	
	
}