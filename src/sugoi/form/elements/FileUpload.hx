package sugoi.form.elements;
import haxe.crypto.Md5;
import haxe.Timer;
import sugoi.form.Form;
import sys.io.File;

/**
 * Manage an <input type="file" /> element.
 */
class FileUpload extends FormElement<haxe.io.Bytes>
{
	public var fileName: String;
	public var maxSize : Int; //Max file size in Mb

	public function new(name:String, label:String, ?value:haxe.io.Bytes, ?required:Bool=false,  toFolder:String=null, ?keepFullFileName:Bool=true )
	{
		super();
		this.name = name;
		this.label = label;
		this.value = value;
		this.required = required;
		fileName = null;
		maxSize = 6;
	}

	override public function getTypedValue(s:String):haxe.io.Bytes
	{
		var request = sugoi.tools.Utils.getMultipart(1024 * 1024 * maxSize);

		//trace(request.toString());

		var strData = request.get(parentForm.name + "_" + name);
		fileName = request.get(parentForm.name + "_" + name+"_filename");
		
		return new haxe.io.StringInput(strData).readAll();


	}

	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		//var path = toFolder.substr((Sys.getCwd() + "tmp/").length);
		//var path = toFolder;

		var str:String = "";

		//str += '<span class="fileName">'+getOriginalFileName()+'</span><br/>';
		str += '<input type="file" name="' + n + '" id="' + n + '" ' + attributes + ' />';
		//if (!required && value != '' && value != null) str += '[ <a href="#" onclick="document.getElementById(\'' + n + '__delete\').value = \'1\'; return false;">remove</a> ]';
		//str += '<input type="hidden" name="' + n + '__previous" id="' + n + '__previous" value="'+value+'"/>';
		//str += '<input type="hidden" name="' + n + '__delete" id="' + n + '__delete" value="0"/>';

		return str;
	}

	/**
	 * Contains MD5 and original filename.
	 */
	//public function getFileName()
	//{
		//if (keepFullFileName)
		//{
			//var s = Std.string(value);
			//return s.substr(s.lastIndexOf("/") + 1);
		//} else {
			//return value;
		//}
	//}

	/**
	 * Orginal filename.
	 */
	//public function getOriginalFileName()
	//{
		//if (keepFullFileName)
		//{
			//var s = Std.string(value);
			//return s.substr(s.lastIndexOf("/") + 33);
		//} else {
			//return Std.string(value).substr(33);
		//}
	//}



}