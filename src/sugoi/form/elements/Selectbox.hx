package sugoi.form.elements;
import sugoi.form.Form;
import sugoi.form.FormElement;

class Selectbox<T> extends FormElement<T> 
{
	public var data:Array<{label:String,value:T}>;
	public var nullMessage:String;
	public var onChange:String;
	public var size:Int;
	public var multiple:Bool;
	
	public function new(name:String, label:String, ?data:Array<{label:String,value:T}>, ?selected:T, required:Bool=false, ?nullMessage="-", ?attributes="") 
	{
		super();
		this.name = name;
		this.label = label;
		this.data = data != null ? data: new Array();
		this.value = selected;
		this.required = required;
		this.nullMessage = nullMessage;
		this.attributes = attributes;		
		size = 1;
		multiple = false;
		onChange = "";
		if(Form.USE_TWITTER_BOOTSTRAP) cssClass = "form-control";
	}
	
	override public function render():String
	{
		var s = "";
		var n = parentForm.name;
		n += "_" +name;

		s += '\n<select name="' + n + '" id="' + n + '" '+attributes+' class="'+ getClasses() +'" onChange="'+onChange+'" size="'+size+'" '+(multiple ? "multiple" : "")+'/>';
		
		if (nullMessage != "")
			s += "<option value=\"\" " + (Std.string(value) == "" ? "selected":"") + ">" + nullMessage + "</option>";
			
		if (data != null){	
			for (row in data) {
				s += "<option value=\"" + Std.string(row.value) + "\" " + (Std.string(row.value) == Std.string(value) ? "selected":"") + ">" + Std.string(row.label) + "</option>";
			}
		}
		s += "</select>";
	 
		return s;
	}
	
}