package sugoi.form.elements;
import sugoi.form.Form;
import sys.io.File;

/**
 * Manage an <input type="file" /> element for uploading images.
 */
class ImageUpload extends FormElement<haxe.io.Bytes>
{
	public var fileName: String;
	public var maxSize : Int; 			// Max file size in Mb
	public var previewMaxSize : Int; 	// Image preview max size in pixels
	public var url : String;
	public var text : String;

	/**
	 * @param	name
	 * @param	label
	 * @param	url			file URL for previewing the image
	 * @param	required
	 */
	public function new(name:String, label:String, ?url:String, ?required:Bool=false )
	{
		super();
		
		this.name = "upload_"+name;
		this.label = label;
		
		this.url = url;
		this.required = required;
		fileName = null;
		maxSize = 6;
		previewMaxSize = 200;
	}

	override public function getTypedValue(s:String):haxe.io.Bytes
	{
		var request = sugoi.tools.Utils.getMultipart(1024 * 1024 * maxSize);

		var strData = request.get(parentForm.name + "_" + name + "_data");
		if (strData != null && strData != ""){
			fileName = request.get(parentForm.name + "_" + name + "_data_filename");
			return new haxe.io.StringInput(strData).readAll();	
		}

		return null;
	}
	
	public function hasDeleteAction():Bool{
		var n = parentForm.name + "_" +name;
		return (App.current.params.get(n + "_delete") == "1");
	}

	/**
	 * Renders an input + image preview + delete btn
	 */
	override public function render():String
	{
		var n = parentForm.name + "_" +name;
		var str = new StringBuf();
		str.add('<div class="imageUpload" style="position: relative;">');
		if (url!= null)str.add('<img id="' + n + '_preview" src="$url" class="img-thumbnail" style="max-width:'+previewMaxSize+'px;max-height:'+previewMaxSize+'px;float:right;">');
		str.add('<input class="btn btn-default" type="file" name="' + n + '_data" id="' + n + '" ' + attributes + ' />');
		if (text != null) str.add('<p>$text</p>');
		if (!required && url!= null){
			str.add('<a style="position:absolute;right:3px;top:3px;" href="#" class="btn btn-default btn-xs" onclick="document.getElementById(\'' + n + '_delete\').value = \'1\';document.getElementById(\'' + n + '_preview\').style.display=\'none\';this.style.display=\'none\';return false;">');
			str.add('<span class="glyphicon glyphicon-remove" alt="Remove"></span>');
			str.add('</a>');
		}		
		str.add('<input type="hidden" name="' + n + '_delete" id="' + n + '_delete" value="0"/>');
		str.add('</div>');

		return str.toString();
	}

}