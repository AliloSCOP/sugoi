/*
 * Copyright (c) 2008, TouchMyPixel & contributors
 * Original author : Matt Benton <matt@touchmypixel.com> 
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


package form.elements;

import form.Form;
import form.FormElement;
import poko.Poko;

enum EmbeddedVideoService
{
	youtube;
	vimeo;
}

typedef EmbeddedVideoConfig =
{
	var videoID:String;
	var width:Int;
	var height:Int;
}

typedef VimeoConfig = 
{ > EmbeddedVideoConfig,
	var color:String;
	var showPortrait:Bool;
	var showTitle:Bool;
	var showByline:Bool;
}

class EmbeddedVideoOptions extends FormElement
{
	// Type of video service
	public var service:EmbeddedVideoService;
	/**
	 * Common options
	 */
	//public var videoID:String;
	//public var width:Int;
	//public var height:Int;
	/**
	 * Vimeo options
	 */
	// Can be Blue, Orange, Lime, Fuschia, White or #RRGGBB
	//public var color:String;
	//public var showPortrait:Bool;
	//public var showTitle:Bool;
	//public var showByline:Bool;
	
	public var vimeo (default, null) : VimeoConfig;
	
	public function new(name:String, label:String, service:EmbeddedVideoService) 
	{
		super();
		
		this.name = name;
		this.label = label;
		this.service = service;
	}
	
	override public function render():String
	{
		var n = form.name + "_" + name;
		if ( service == EmbeddedVideoService.vimeo )
		{
			var color = new Input(n + "Color", "Color", "Blue");
			
		}
		return null;
	}
	
	public function toString() :String
	{
		return render();
	}
	
	override public function populate():Void
	{
	}
}



/*var date:Date = cast value;
		var year = date.getFullYear();
		var month = date.getMonth();
		var day = date.getDate();
		
		var l = new List();
		var s = "";
		
		var elYear = new Selectbox(form, "1", ListData.getYears(1990, 2000, true), Std.string(year), false, "");
		var elMonth = new Selectbox(form, "2", ListData.getMonths(), Std.string(year), false);
		var elDay = new Selectbox(form, "3", ListData.getDays() , Std.string(year), false);
		
		form.addElement(name + "[]", elYear);
		form.addElement(name + "[]", elMonth);
		form.addElement(name + "[]", elDay);
		
		s += elYear.toString(); 
		s += elMonth.toString(); 
		s += elDay.toString(); 
		
		form.initElements();
		*/