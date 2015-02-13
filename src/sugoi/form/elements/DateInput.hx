package sugoi.form.elements;
import sugoi.form.FormElement;
import sugoi.form.Validator;
import sugoi.form.ListData;

/**
 * date selectBox : day month year hour minutes
 */
class DateInput extends DateDropdowns
{
	private var hourSelector:Selectbox;
	private var minuteSelector:Selectbox;
	
	public function new(name:String, label:String, ?value:Date, ?required:Bool=false, yearMin:Int=1950, yearMax:Int=null, ?validators:Array<Validator>, ?attibutes:String="")
	{
		super(name, label, value, required, yearMin, yearMax, validators, attibutes);
		var t = sugoi.form.Form.translator;
		hourSelector 	= new Selectbox(name+"_hour", t._("hour"),ListData.getDateElement(0,23), Std.string(date.getHours()),true,"-",'title="Hour"');
		minuteSelector 	= new Selectbox(name+"_minute", t._("minute"), ListData.getDateElement(0, 59), Std.string(date.getMinutes()), true, "-", 'title="Minute"');		
		
		if (Form.USE_TWITTER_BOOTSTRAP) {
			hourSelector.cssClass = "input-mini";
			minuteSelector.cssClass = "input-mini";
		}
		
	}

	override public function isValid() {
		return true;	
	}
	
	
	override public function render():String
	{
		hourSelector.parentForm = this.parentForm;
		minuteSelector.parentForm = this.parentForm;
		
		var s = super.render() + " : ";
		
		if (value != "" && value != null && value != "null"){
			var v:Date = cast value;
			hourSelector.value = v.getHours();
			minuteSelector.value = v.getMinutes();
		}
		s += hourSelector.render() + " h ";
		s += minuteSelector.render() + " m ";
		return s;
	}
	
	override public function populate()
	{		
		//super.populate();
		var n = parentForm.name + "_" + hourSelector.name;
		var v = App.current.params.get(n);
		var params = App.current.params;
		
		if (v != null)
		{			
			var minute = 	Std.parseInt(params.get(parentForm.name + "_" + minuteSelector.name));
			var hour = 		Std.parseInt(params.get(parentForm.name + "_" + hourSelector.name));
			var day = 		Std.parseInt(params.get(parentForm.name + "_" + daySelector.name));
			var month = 	Std.parseInt(params.get(parentForm.name + "_" + monthSelector.name));
			var year = 		Std.parseInt(params.get(parentForm.name + "_" + yearSelector.name));			
			
			value = new Date(year, month - 1, day, hour, minute, 0);
			
		}
		
		
		
	}
}
