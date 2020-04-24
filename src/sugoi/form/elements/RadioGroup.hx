package sugoi.form.elements;
import sugoi.form.ListData.FormData;
import sugoi.form.Form;
import sugoi.form.FormElement;

class RadioGroup extends FormElement<String> 
{
	public var data:ListData.FormData<String>;
	public var selectMessage:String;
	public var labelLeft:Bool;
	public var labelRight:Bool;
	public var vertical:Bool;
	
	public function new(name:String, label:String, ?data:FormData<String>, ?selected:String, ?defaultValue:String, ?vertical:Bool=true, ?labelRight:Bool=true,?required=false) 
	{
		super();
		this.name = name;
		this.label = label;
		this.data = data != null ? data : [];
		this.value = selected != null ? selected : defaultValue;
		this.vertical = vertical;
		this.labelRight = labelRight;
		this.required = required;
	}
	
	public function addOption(label:String, value:String)
	{
		data.push( { label:label, value:value } );
	}
	
	override public function render():String
	{
		var s = "";
		var n = parentForm.name + "_" +name;
		
		var c = 0;
		if (data != null)
		{
			for (row in data)
			{
				var vClass = vertical ? " radioItemVertical" : " radioItemHorizontal";
				s += '<div class="radioItem'+vClass+'">';
				var radio = "<input type=\"radio\" name=\""+n+"\" id=\""+n+c+"\" value=\"" + row.value + "\" " + (row.value == Std.string(value) ? "checked":"") +" />\n";
				var label = "<label for=\"" + n+c + "\" >" + row.label  +"</label>";
				
				s += labelRight ? radio + " "+label+" ": label+" "+radio+" ";
				s += '</div>';
				//if (verticle) s += "<br />";
				c++;
			}	
		}
		
		return s;
	}
	
	override function getTypedValue(str:String){
		if(str==null) return null;
		str = StringTools.trim(str);
		return (str == "") ? return null : str;
		
		
	}
	
}