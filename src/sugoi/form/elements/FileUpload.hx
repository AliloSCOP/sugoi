package form.elements;
import haxe.crypto.Md5;
import haxe.Timer;
import form.Form;
import form.FormElement;
import sys.io.File;

class FileUpload extends FormElement
{
	public var toFolder:String;
	public var keepFullFileName:Bool;

	public function new(name:String, label:String, ?value:String, ?required:Bool=false,  toFolder:String=null, ?keepFullFileName:Bool=true )
	{
		super();
		this.name = name;
		this.label = label;
		this.value = value;
		this.required = required;
		//this.toFolder = toFolder != null ? toFolder : Poko.instance.config.applicationPath + "/tmp/";
		this.toFolder = toFolder;
		this.keepFullFileName = keepFullFileName;
	}

	override public function populate()
	{
		super.populate();


		//var n = form.name + "_" + name;
		//var previous = App.current.params.get(n+"__previous");
		//var delete = Std.string(App.current.params.get(n + "__delete"));
		//var file:Hash<Dynamic> = PhpTools.getFilesInfo().get(n);

		//var oldfile = keepFullFileName ? previous : toFolder + previous;


		var request = tools.Utils.getMultipart(1024 * 1024 * 4);

		if (request.get(parentForm.name + "_" + name) == null) throw parentForm.name + "_" + name+" is empty";

		throw {r:request.toString(),value:value,name:parentForm.name + "_" + name};

		var f = File.write(toFolder + "/" + value, false);
		f.writeString(request.get(parentForm.name + "_" + name));





		//if (delete == '1' && FileSystem.exists(oldfile)) {
			//FileSystem.deleteFile(oldfile);
			//value = '';
		//}
		//
		//if (file != null && file.get("error") == 0)
		//{
			//if (FileSystem.exists(file.get("tmp_name")))
			//{
				// delete previous uploaded file
				//if (previous != null && previous != "" && FileSystem.exists(oldfile))
				//{
					//FileSystem.deleteFile(oldfile);
				//}
				//
				// move upladed file to toFolder
				//var newname = Md5.encode(Timer.stamp() + file.get("name")) + file.get("name");
				//
				//PhpTools.moveFile(file.get("tmp_name"), toFolder+newname);
				//
				//value = keepFullFileName ? toFolder+newname : newname;
			//}
		//}
		//else if (previous != null && delete != '1')
		//{
			// no upload- remember previous value
			//value = previous;
		//}
	}

	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		//var path = toFolder.substr((Sys.getCwd() + "tmp/").length);
		var path = toFolder;

		var str:String = "";

		str += '<span class="fileName">'+getOriginalFileName()+'</span><br/>';
		str += '<input type="file" name="' + n + '" id="' + n + '" ' + attributes + ' />';
		if (!required && value != '' && value != null) str += '[ <a href="#" onclick="document.getElementById(\'' + n + '__delete\').value = \'1\'; return false;">remove</a> ]';
		//str += '<input type="hidden" name="' + n + '__previous" id="' + n + '__previous" value="'+value+'"/>';
		//str += '<input type="hidden" name="' + n + '__delete" id="' + n + '__delete" value="0"/>';

		return str;
	}

	/**
	 * Contains MD5 and original filename.
	 */
	public function getFileName()
	{
		if (keepFullFileName)
		{
			var s = Std.string(value);
			return s.substr(s.lastIndexOf("/") + 1);
		} else {
			return value;
		}
	}

	/**
	 * Orginal filename.
	 */
	public function getOriginalFileName()
	{
		if (keepFullFileName)
		{
			var s = Std.string(value);
			return s.substr(s.lastIndexOf("/") + 33);
		} else {
			return Std.string(value).substr(33);
		}
	}

	public function toString() :String
	{
		return render();
	}

}