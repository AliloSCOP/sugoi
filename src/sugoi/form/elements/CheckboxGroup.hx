package sugoi.form.elements;
import sugoi.form.Form;
import sugoi.form.FormElement;
import sugoi.form.Formatter;
import sugoi.form.ListData;

/**
 * Manage an array of string with a checkbox group
 */
class CheckboxGroup extends FormElement<Array<String>>
{
	public var data:Array<Dynamic>;
	public var selectMessage:String;
	public var labelLeft:Bool;
	public var verticle:Bool;
	public var labelRight:Bool;	
	public var formatter:Formatter;
	public var columns:Int;
	
	public function new(name:String, label:String,data:FormData<String>, ?selected:Array<String>, ?verticle:Bool=true, ?labelRight:Bool=true)
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
			value = (v != null) ? v : [];
		} else {
			if (v != null) value = v;
		}
	}
	
	override public function render():String
	{
		var s = "";
		var n = parentForm.name + "_" +name;
		
		var tagCss = getClasses();
		var labelCss = getLabelClasses();
			
		var c = 0;
		var datas : FormData<String> = Lambda.array(data);
		if (datas != null)
		{
			var rowsPerColumn = Math.ceil(datas.length / columns);
			s = "<table><tr>";
			for (i in 0...columns)
			{
				s += "<td valign=\"top\">\n";
				s += "<table>\n";
				
				for (j in 0...rowsPerColumn)
				{
					if (c >= datas.length) break;
					
					s += "<tr style='vertical-align: top;'>";
					
					var row = datas[c];
					
					var checkbox = "<input type=\"checkbox\" class=\"" + tagCss + "\" name=\""+n+"[]\" id=\""+n+c+"\" value=\"" + row.value + "\" " + (value != null ? Lambda.has(value, row.value) ? "checked":"":"") +" ></input>\n";
					var label;
					
					if (formatter != null){
						label = "<label for=\"" + n + c + "\" class=\""+''/*labelCss*/+"\" >" + formatter.format(row.label)  +"</label>\n";
					//}else if(Form.translator!=null){
						//label = "<label for=\"" + n + c + "\" class=\"" + ''/*labelCss*/+"\" >" + Form.translator._(row.label)  +"</label>\n";
					}else {
						label = "<label for=\"" + n + c + "\" class=\"" + ''/*labelCss*/+"\" >" + row.label +"</label>\n";
					}
					
					
					var helpLink = row.docLink==null?"":'<a href="${row.docLink}" target="_blank" class="help" data-toggle="tooltip" title="En savoir plus"><i class="icon icon-info"></i></a>';
					var desc = (row.desc==null?"":'<p class="desc">${row.desc} $helpLink</p>');
					if (labelRight){
						s += '<td>$checkbox&nbsp;</td>\n';
						s += '<td>$label $desc</td>\n';
					} else {
						s += '<td>$label $desc&nbsp;</td>\n';
						s += '<td>$checkbox</td>\n';
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
	
}