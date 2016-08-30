package sugoi.tools;
import sugoi.Web;

/**
 * Manage images uploaded by users
 * @author fbarbut<francois.barbut@gmail.com>
 */
class UploadedImage
{
	/**
	 * Resize an uploaded image with imagemagick then store it in db.File
	 */
	public static function resizeAndStore(imgData:String,fileName:String,maxWidth:Int,maxHeight:Int):sugoi.db.File {
		
		var name = haxe.crypto.Md5.encode(Std.string(Std.random(100000)));
		var path = Web.getCwd() + "../tmp/" + name;
		var path2 = Web.getCwd() + "../tmp/" + name + "_r";
		
		//store file in a tmp folder
		var ch = sys.io.File.write(path,true);
		ch.write( new haxe.io.StringInput(imgData).readAll());
		ch.close();
		
		//resize via imagemagick
		var p = new sys.io.Process("convert" , [path, "-resize", maxWidth+"x"+maxHeight, path2 ]);
		
		//if we dont wait it seems the image is not ready (file open error)... 
		Sys.sleep(5);
		
		var data = sys.io.File.read(path2).readAll();
		
		try{ sys.FileSystem.deleteFile(path2); }catch(e:Dynamic){}
		
		//record in a db.File
		return sugoi.db.File.createFromBytes(data,fileName);	
	}
	
}