package sugoi.apis.google;

/**
 * Geocoding via Google maps API
 *
 * @doc https://developers.google.com/maps/documentation/geocoding/
 * @author fbarbut
 */

 typedef GeoCodingData = Array<{
	address_components : Array<{long_name:String,short_name:String,types:Array<String>}>,
	/*{
               "long_name" : "Marché de Lerme",
               "short_name" : "Marché de Lerme",
               "types" : [ "point_of_interest", "establishment" ]
            },
            {
               "long_name" : "Place de Lerme",
               "short_name" : "Pl. de Lerme",
               "types" : [ "route" ]
            },
            {
               "long_name" : "Bordeaux",
               "short_name" : "Bordeaux",
               "types" : [ "locality", "political" ]
            },*/
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
	 */
	public function geocode(address:String) {
		var url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + StringTools.urlEncode(address) + "&key=" + KEY;
		var d = curlRequest("GET", url, null, null);
		if (d == "" || d == null) throw "curl response is empty";
		//throw d;
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
		
		var json  = cast haxe.Json.parse(s);
		if (json.status != "OK") throw "Google geocoding API Error : " + s;
		var r : GeoCodingData = cast json.results;
		return r[0].geometry.location;
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