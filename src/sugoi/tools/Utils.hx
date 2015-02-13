package sugoi.tools;

class Utils {

	public static function getMultipart(maxSize) : Map<String,String> {
		var h = new Map();
		var buf : StringBuf = null;
		var curname = null;
		var curfname = null;
		neko.Web.parseMultipart(
		function(p,n) {
			if( curname != null ){
				h.set(curname,buf.toString());
				if( curfname != null )
					h.set(curname+"_filename",curfname);
				curfname = null;
			}
			curname = p;
			curfname = n;
			buf = new StringBuf();
			maxSize -= p.length;
			if( maxSize < 0 )
				throw "multipart_maximum_size_reached";
		},
		function(str,pos,len) {
			maxSize -= len;
			if( maxSize < 0 )
				throw "multipart_maximum_size_reached";
			buf.addSub(neko.Lib.stringReference(str), pos, len);
		}
		);
		if( curname != null )
			h.set(curname,buf.toString());
		return h;
	}


}
