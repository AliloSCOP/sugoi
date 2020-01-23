package sugoi.apis.google;

/**
 * Geocoding via Google maps API
 *
 * @doc https://developers.google.com/maps/documentation/geocoding/
 * @author fbarbut
 */

 
 /**
  *  { "results" : [
  * 	{ "address_components" : [
  * 		{ "long_name" : "1", "short_name" : "1", "types" : [ "street_number" ] },
  * 		{ "long_name" : "Place Saint Bénigne", "short_name" : "Pl. Saint Bénigne", "types" : [ "route" ] },
  * 		{ "long_name" : "Dijon", "short_name" : "Dijon", 			"types" : [ "locality", "political" ] },
  * 		{ "long_name" : "Côte-d'Or", "short_name" : "Côte-d'Or",	"types" : [ "administrative_area_level_2", "political" ] },
  * 		{ "long_name" : "Bourgogne", "short_name" : "Bourgogne", 	"types" : [ "administrative_area_level_1", "political" ] },
  * 		{ "long_name" : "France", "short_name" : "FR", 				"types" : [ "country", "political" ] },
  * 		{ "long_name" : "21000", "short_name" : "21000", 			"types" : [ "postal_code" ] } ],
  * 		"formatted_address" : "1 Pl. Saint Bénigne, 21000 Dijon, France",
  * 		"geometry" : { "bounds" : { "northeast" : { "lat" : 47.32183939999999, "lng" : 5.0339407 }, "southwest" : { "lat" : 47.3218299, "lng" : 5.0339282 } }, "location" : { "lat" : 47.32183939999999, "lng" : 5.0339282 }, "location_type" : "RANGE_INTERPOLATED", "viewport" : { "northeast" : { "lat" : 47.3231836302915, "lng" : 5.035283430291502 }, "southwest" : { "lat" : 47.3204856697085, "lng" : 5.032585469708497 } } }, "partial_match" : true, "place_id" : "EikxIFBsLiBTYWludCBCw6luaWduZSwgMjEwMDAgRGlqb24sIEZyYW5jZQ", "types" : [ "street_address" ] } ], "status" : "OK" }
  */
 typedef GeoCodingData = Array<{
	address_components : Array<{long_name:String,short_name:String,types:Array<String>}>,
	formatted_address : String, //Marché de Lerme, Pl. de Lerme, 33000 Bordeaux, France
	geometry : {location:{lat:Float,lng:Float}}
 }>




class GeoCode
{

	//API KEY : https://developers.google.com/maps/documentation/geocoding/?hl=FR#api_key
	public static var KEY = "";
	public static var USE_CURL = true;

	public function new(api_key) {
		KEY = api_key;
	}
	
	/**
	 * address -> lat/lng
	 * 
	 * @doc components filtering : https://developers.google.com/maps/documentation/geocoding/intro#ComponentFiltering
	 */
	public function geocode(address:String,?components:String):GeoCodingData {
		var url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + StringTools.urlEncode(address) + "&key=" + KEY;
		if (components != null) url += "&components=" + StringTools.urlEncode(components);
		
		var d = curlRequest("GET", url, null, null);
		if (d == "" || d == null) throw "curl response is empty";
		return onData(d);
	}


	/**
	 * Reverse geocoding : latitude/longitude -> address
	 * @param	lat
	 * @param	lng
	 */
	public function reverse(lat:Float, lng:Float) {

		//clermont-ferrand : 45.783 3.083

		var url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + lat + "," + lng + "&key="+KEY;

		//if(USE_CURL) {
			//NEEDS CURL
			var d = curlRequest("GET", url, null, null);
			if(d == "" || d == null) throw "curl response is empty";
			return onReverseData(d);

		//}else {
			////NEEDS HXSSL
			//var req = new haxe.Http(url);
			//req.onError = function(err:String) trace("error : " + err);
			//req.onData = onData;
			//req.request(false);
		//}

	}

	public function onData(s:String) {
		//trace("<pre>"+s+"</pre>");
		var json  = cast haxe.Json.parse(s);
		if (json.status != "OK") throw "Google geocoding API Error : " + s;
		var r : GeoCodingData = cast json.results;
		return r;
	}
	
	
	
	public function onReverseData(s:String) {

		//var out : GeoCodingData = [{address_components:[],formatted_address:null,}];
//
		//var json = haxe.Json.parse(s);
		//if(json.status != "OK") throw "Google geocoding API Error : " + s;
		//var arr : Array<Dynamic> = cast json.results;
		//var addrs : Array<Dynamic> = cast arr[0].address_components;
//
		//for ( a in addrs) {
			//var types : Array<String> = cast a.types ;
			//var o = { long_name:Std.string(a.long_name), short_name:Std.string(a.short_name), types:types};
			//out[0].address_components.push(o);
		//}
//
		//return out;
	}

	public function curlRequest( method: String, url : String, ?headers : Dynamic, postData : String ) : Dynamic {
		var cParams = ["-X"+method,"--max-time","5"];
		for( k in Reflect.fields(headers) ){
			cParams.push("-H");
			cParams.push(k+": "+Reflect.field(headers,k));
		}
		cParams.push(url);
		if( postData != null ){
			cParams.push("-d");
			cParams.push(postData);
		}

		var p = new sys.io.Process("curl",cParams);
		var str = neko.Lib.stringReference(p.stdout.readAll());
		p.exitCode();

		return str;
	}


}