package sugoi.form.elements;
import sugoi.form.Form;
import sugoi.form.FormElement;
import sugoi.form.Formatter;
import sugoi.form.elements.Flags;

class Enum extends FormElement
{
	public var enumName:String;
	public var selectMessage:String;
	public var labelLeft:Bool;
	public var verticle:Bool;
	public var labelRight:Bool;
	var checked : Array<Bool>;
	

	public var columns:Int;

	/**
	 *
	 * @param	name
	 * @param	label
	 * @param	data			list of enums
	 * @param	value			int (enum index)
	 * @param	?verticle
	 * @param	?labelRight
	 */
	public function new(name:String, label:String, enumName:String, value:Int, ?verticle:Bool=false, ?labelRight:Bool=true)
	{
		super();
		this.name = name;
		this.label = label;
		this.enumName = enumName;
		this.value = value;
		
		this.verticle = verticle;
		this.labelRight = labelRight;


		columns = 1;
	}

	override public function populate()
	{
		//at runtime, enum is an int
		var index = Std.parseInt(App.current.params.get(parentForm.name + "_" + name));
		value = Type.resolveEnum(enumName).createByIndex(index);
		
		//App.log(form.name + "_" + name+" : "+value);

	}
	
	//override function getTypedValue():Dynamic {
		//return Type.resolveEnum(enumName).createByIndex(value);
	//}

	override public function render():String
	{
		var s = "";
		var n = parentForm.name + "_" +name;

		var tagCss = getClasses();
		var labelCss = getLabelClasses();

		var c = 0;

		var array = Type.allEnums(Type.resolveEnum(enumName));

		var rowsPerColumn = Math.ceil(array.length / columns);
		s = "<table style='margin-bottom:8px;'><tr>";
		for (i in 0...columns)
		{
			s += "<td valign=\"top\">\n";
			s += "<table>\n";

			for (j in 0...rowsPerColumn)
			{
				if (c >= array.length) break;

				s += "<tr>";

				var row:Dynamic = array[c];
				var checkbox = "<input type=\"radio\" class=\"" + tagCss + "\" name=\""+n+"\" id=\""+n+row+"\" value=\""+Type.enumIndex(row)+"\" " + ((value==Type.enumIndex(row))? "checked":"") +" ></input>\n";
				var label;

				var t = Form.translator;

				label = "<label for=\"" + n + c + "\" class=\"" + labelCss + "\" >" + t._(Std.string(row))  +"</label>\n";

				if (labelRight)
				{
					s += "<td style='vertical-align:middle;'>" + checkbox + "</td>\n";
					s += "<td style='vertical-align:middle;'>" + label + "</td>\n";
				} else {
					s += "<td style='vertical-align:middle;'>" + label + "</td>\n";
					s += "<td style='vertical-align:middle;'>" + checkbox + "</td>\n";
				}

				s += "</tr>";
				c++;
			}
			s += "</table>";
			s += "</td>";
		}
		s += "</tr></table>\n";



		return s;
	}

	
}