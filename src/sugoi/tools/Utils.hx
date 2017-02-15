package sugoi.tools;
import sugoi.Web;

class Utils {

	public static function getMultipart(maxSize) : Map<String,String> {
		var h = new Map();
		var buf : StringBuf = null;
		var curname = null; 	//form field name
		var curfname = null;	//file name
		Web.parseMultipart(
		function(p, n) {
			if( curname != null ){
				h.set(curname,buf.toString());
				if( curfname != null )
					h.set(curname+"_filename",curfname);
				curfname = null;
			}
			//trace("onPart");
			curname = p;
			curfname = n;
			
			buf = new StringBuf();
			maxSize -= p.length;
			if( maxSize < 0 )
				throw "multipart_maximum_size_reached";
		},
		function(str, pos, len) {
			//trace("onData "+str);
			maxSize -= len;
			if( maxSize < 0 )
				throw "multipart_maximum_size_reached";
			#if neko
			buf.addSub(neko.Lib.stringReference(str), pos, len);
			#else
			buf.addSub(str.toString(), pos, len);
			#end
		}		
		);
		
		if ( curname != null ) {		
			h.set(curname,buf.toString());
		}
		if ( curfname != null ) {
			h.set(curname+"_filename",curfname);
		}
		return h;
	}


}
