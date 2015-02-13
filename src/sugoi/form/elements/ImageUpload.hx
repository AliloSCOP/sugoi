/*
 * Copyright (c) 2008, TouchMyPixel & contributors
 * Original author : Tony Polinelli <tonyp@touchmypixel.com> 
 * Contributers: Tarwin Stroh-Spijer 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE TOUCH MY PIXEL & CONTRIBUTERS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE TOUCH MY PIXEL & CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */


package sugoi.form.elements;
import haxe.Md5;
import haxe.Timer;
import php.FileSystem;
import poko.Poko;
import sugoi.form.Form;
import sugoi.form.FormElement;
import poko.utils.PhpTools;

class ImageUpload extends FileUpload
{
	public var imageServiceUrl:String;
	public var imageServicePreset:String;
	
	public function new(name:String, label:String, ?value:String, ?required:Bool=false, ?imageServiceUrl:String=null, ?imageServicePreset=null, ?toFolder:String=null, ?keepFullFileName:Bool=true ) 
	{
		super(name, label, value, required, toFolder, keepFullFileName);
		
		this.imageServiceUrl = imageServiceUrl != null ? imageServiceUrl : "?request=services.Image";
		this.imageServicePreset = imageServicePreset != null ? imageServicePreset : "thumb";
	}
	
	override public function render():String
	{
		var n = form.name + "_" +name;
		var path = toFolder.substr((Poko.instance.App.config.applicationPath + "res/").length);
		
		var str:String = "";
		str += '<img src="'+imageServiceUrl+'&preset='+imageServicePreset+'&src='+getFileName()+'" id="' + n + '__image" /><br/>';
		str += '<input type="file" name="' + n + '" id="' + n + '" ' + attributes + ' />';
		if (!required && value != '' && value != null) str += '[ <a href="#" onclick="document.getElementById(\'' + n + '__delete\').value = \'1\'; document.getElementById(\'' + n + '__image\').style.visibility = \'hidden\'; return false;">remove</a> ]';
		str += '<input type="hidden" name="' + n + '__previous" id="' + n + '__previous" value="'+value+'"/>';
		str += '<input type="hidden" name="' + n + '__delete" id="' + n + '__delete" value="0"/>';
		
		return str;
	}
	
	override public function toString() :String
	{
		return render();
	}
	
}