package sugoi.form.elements;
import sugoi.form.Form;
import sugoi.form.FormElement;
#if php
import php.Web;
#else
import neko.Web;
#end
import sugoi.form.Formatter;

class CheckboxGroup extends FormElement
{
	public var data:Array<Dynamic>;
	public var selectMessage:String;
	public var labelLeft:Bool;
	public var verticle:Bool;
	public var labelRight:Bool;
	
	public var formatter:Formatter;
	public var columns:Int;
	
	public function new(name:String, label:String,data:Array<{key:String,value:String}>, ?selected:Array<String>, ?verticle:Bool=true, ?labelRight:Bool=true)
	{
		super();
		this.name = name;
		this.label = label;
		this.data = data;
		this.value = selected != null ? selected : new Array();
		this.verticle = verticle;
		this.labelRight = labelRight;
		
		columns = 1;
	}
	
	override public function populate()
	{
		
		var v = Web.getParamValues(parentForm.name + "_" + name);
		
		if (parentForm.isSubmitted())
		{
			value = (v != null) ? v : new Array();
		} else {
			if (v != null)
				value = v;
		}
	}
	
	override public function render():String
	{
		var s = "";
		var n = parentForm.name + "_" +name;
		
		if (value != null)
		{
			value = Lambda.map(value, function(item) {
				return item+"";
			});
		}
		
		var tagCss = getClasses();
		var labelCss = getLabelClasses();
			
		var c = 0;
		var array = Lambda.array(data);
		if (array != null)
		{
			//trace("L" + array.length);
			var rowsPerColumn = Math.ceil(array.length / columns);
			s = "<table><tr>";
			for (i in 0...columns)
			{
				s += "<td valign=\"top\">\n";
				s += "<table>\n";
				
				for (j in 0...rowsPerColumn)
				{
					if (c >= array.length) break;
					
					s += "<tr>";
					
					var row:Dynamic = array[c];
					
					var checkbox = "<input type=\"checkbox\" class=\"" + tagCss + "\" name=\""+n+"[]\" id=\""+n+c+"\" value=\"" + row.key + "\" " + (value != null ? Lambda.has(value, row.key+"") ? "checked":"":"") +" ></input>\n";
					var label;
					
					if (formatter != null)
					{
						label = "<label for=\"" + n + c + "\" class=\""+labelCss+"\" >" + formatter.format(row.value)  +"</label>\n";
					} else {
						label = "<label for=\"" + n + c + "\" class=\""+labelCss+"\" >" + Form.translator._(row.value)  +"</label>\n";
					}
					
					if (labelRight)
					{
						s += "<td>" + checkbox + "</td>\n";
						s += "<td>" + label + "</td>\n";
					} else {
						s += "<td>" + label + "</td>\n";
						s += "<td>" + checkbox + "</td>\n";
					}
					s += "</tr>";
					
					c++;
				}
				s += "</table>";
				s += "</td>";
			}
			s += "</tr></table>\n";
			
		}
		
		return s;
	}
	
	public function toString() :String
	{
		return render();
	}
}