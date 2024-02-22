package sugoi;

import haxe.Json;
import haxe.crypto.Base64;
import haxe.crypto.Hmac;
import haxe.io.Bytes;

using StringTools;

typedef JWTHeader = {
  var alg:String;
  var typ:String;
};

typedef Payload = {
  var id:Int;
}
class JWT {
    private function new(){}

    private static function base64Decode(s:String):Bytes {
        var s64 = s.replace('-', '+').replace('_', '/');
        s64 += switch(s64.length % 4) {
            case 0: '';
            case 1: '===';
            case 2: '==';
            case 3: '=';
            case _: throw 'Illegal base64url string!';
        }
        return Base64.decode(s64);
    }

    private static function signature(body:String, secret:String):Bytes {
        var hmac:Hmac = new Hmac(HashMethod.SHA256);
        var sb:Bytes = hmac.make(Bytes.ofString(secret), Bytes.ofString(body));
        return sb;
    }

    /**
      Verifies a JWT and returns the payload if successful
      @param jwt - the token to examine
      @param secret - the secret to compare it with
      @return the decoded Payload or null if the signature is incorrect
     */
    public static function verify(jwt:String, secret:String):Payload {
        var parts:Array<String> = jwt.split(".");
        if(parts.length == 3) {
          // Check that the signature matches
          var sb:Bytes = base64Decode(parts[2]);
          var testSig:Bytes = signature(parts[0] + "." + parts[1], secret);
          if(sb.compare(testSig) == 0) {
          return Json.parse(base64Decode(parts[1]).toString());
          }
        }
        
        return null;
    }

    /**
      Extracts the payload from a JWT, throwing an exception if it is malformed
      @param jwt - The token to extract from
      @return T
     */
    public static function extract<T:Dynamic>(jwt:String):T {
        var parts:Array<String> = jwt.split(".");
        if(parts.length != 3) throw 'Malformed JWT!';
        return Json.parse(base64Decode(parts[1]).toString());
    }
}