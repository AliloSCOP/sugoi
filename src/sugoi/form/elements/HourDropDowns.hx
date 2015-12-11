package sugoi.form.elements;
#if neko
import neko.Web;
#else
import php.Web;
#end
import sugoi.form.FormElement;
import sugoi.form.Validator;
import sugoi.form.ListData;

class HourDropDowns extends FormElement
{
	var hourSelector:Selectbox;
	var minuteSelector:Selectbox;
	var date : Date;

	public function new(name:String, label:String, ?_value:Date, ?required:Bool=false,?attributes="")
	{
		super();
		this.name = name;
		this.label = label;

		if (_value == null) {
			value = Date.now();
			date = Date.now();
		}else {
			value = _value;
			date = _value;
		}

		this.required = required;
		this.attributes = attributes;

		var hours = "";
		var minutes = "";

		if (date != null)
		{
			hours = 	""+date.getHours();
			minutes = ""+(date.getMinutes());
		}

		var t = sugoi.form.Form.translator;

		hourSelector 	= new Selectbox(name+"_hour", t._("hour"), ListData.getDateElement(0, 23), Std.string(date.getHours()), true, "-", 'title="Hour"');		
		minuteSelector 	= new Selectbox(name+"_minute", t._("minute"), ListData.getMinutes(), Std.string(date.getMinutes()), true, "-", 'title="Minute"');

		hourSelector.internal = minuteSelector.internal = true;

		if (Form.USE_TWITTER_BOOTSTRAP) {
			minuteSelector.cssClass = "form-control";
			hourSelector.cssClass = "form-control";
		}

	}
	//public function shortLabels()
	//{
		//daySelector.nullMessage = "-D-";
		//monthSelector.nullMessage = "-M-";
		//yearSelector.nullMessage = "-Y-";
		//monthSelector.data = ListData.getMonths(true);
	//}

	override public function init()
	{
		super.init();

		parentForm.addElement(hourSelector);
		parentForm.addElement(minuteSelector);
	}

	override public function populate()
	{
		var hour = Std.parseInt(App.current.params.get(parentForm.name + "_" + hourSelector.name));
		var minute = Std.parseInt(App.current.params.get(parentForm.name + "_" + minuteSelector.name));
		var now = Date.now();
		value = (hour!= null && minute != null) ? new Date(now.getFullYear(),now.getMonth(), now.getDay(), hour, minute, 0) : null;
	}

	override public function isValid():Bool
	{
		return super.isValid();
	}

	override public function render():String{
		super.render();
		var s = "<span class='form-inline'>";
		if (value != "" && value != null && value != "null"){
			try{
				var v:Date = cast value;
				hourSelector.value = v.getHours();
				minuteSelector.value = v.getMinutes();
			}catch(e:Dynamic){}
		}

		s += hourSelector.render();
		s += " : ";
		s += minuteSelector.render();

		return s+"</span>";
	}


}