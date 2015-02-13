
package sugoi.form.elements;
import sugoi.form.Form;
import sugoi.form.FormElement;
import sugoi.form.Validator;
import sugoi.form.ListData;
enum DateTimeMode
{
	date;
	time;
	dateTime;
}

class DateSelector extends FormElement
{
	public var maxOffset:Int;
	public var minOffset:Int;
	
	public var datetime : String;
	public var mode : DateTimeMode;
	
	public function new(name:String, label:String, ?value:Date, ?required:Bool=false, ?validators:Array<Validator>, ?attibutes:String="")
	{
		super();
		this.name = name;
		this.label = label;

		//trace("DS init v: " + value);
		if ( value != null )
		{
			this.datetime = Std.string(value);
			
			//this.value = datetime.substr(0, 10);
			this.value = datetime;
		}
		else
		{
			this.datetime = null;
			this.value = null;
		}
		//trace("DS init this.v: " + this.value);
		
		mode = DateTimeMode.date;
		
		this.required = required;
		this.attributes = attibutes;
		
		maxOffset = null;
		minOffset = null;
	}
	
	override public function render():String
	{
		if (this.datetime == null && this.value != null) this.datetime = Std.string(value);
		
		var n = parentForm.name + "_" +name;
		var sb = new StringBuf();
		
		var s:StringBuf = new StringBuf();
		
		var n_time = n + "__time";
		var n_date = n + "__date";
		
		var dtDate = datetime.substr(0, 10);
		var dtHour = datetime.substr(11, 2);
		var dtMin = datetime.substr(14, 2);
		var dtSec = datetime.substr(17, 2);
		
		if ( mode == DateTimeMode.date || mode == DateTimeMode.dateTime )
			s.add("<input class=\""+ getClasses() +"\" type=\"text\" name=\"" + n_date + "\" id=\"" + n_date + "\" value=\"" + dtDate + "\" /> \n");

		if ( mode == DateTimeMode.time || mode == DateTimeMode.dateTime )
		{
			s.add(' H: <select class="' + getClasses() + '" name="' + n_time + '_hour" id="' + n_time + '_hour"> \n');
			for ( i in 0 ... 24  )
			{
				var hour = i < 10 ? '0' + Std.string(i) : Std.string(i);
				if ( hour == dtHour )
					s.add('		<option value="' + hour + '" selected="selected">' + hour + '</option> \n');
				else
					s.add('		<option value="' + hour + '">' + hour + '</option> \n');
			}
			s.add("</select> \n");
			s.add(' M: <select class="' + getClasses() + '" name="' + n_time + '_min" id="' + n_time + '_min"> \n');
			for ( i in 0 ... 60  )
			{
				var minute = i < 10 ? '0' + Std.string(i) : Std.string(i);
				if ( minute == dtMin )
					s.add('		<option value="' + minute + '" selected="selected">' + minute + '</option> \n');
				else
					s.add('		<option value="' + minute + '">' + minute + '</option> \n');
			}
			s.add("</select> \n");
			s.add(' S: <select class="' + getClasses() + '" name="' + n_time + '_sec" id="' + n_time + '_sec"> \n');
			for ( i in 0 ... 60  )
			{
				var second = i < 10 ? '0' + Std.string(i) : Std.string(i);
				if ( second == dtSec )
					s.add('		<option value="' + second + '" selected="selected">' + second + '</option> \n');
				else
					s.add('		<option value="' + second + '">' + second + '</option> \n');
			}
			s.add("</select> \n");
		}
		
		s.add("<input type=\"hidden\" name=\"" + n + "\" id=\"" + n + "\" value=\"" + value + "\" /> \n");
		
		s.add("<script type=\"text/javascript\">			\n");
		s.add("		$(function() {							\n");
		
		var maxOffsetStr = minOffset != null ? ", minDate: '-" + minOffset + "m'" : "";
		var minOffsetStr = maxOffset != null ? ", maxDate: '+" + maxOffset + "m'" : "";
		
		s.add('			$("#'+n_date+'").datepicker({ clickInput:true, dateFormat: "yy-mm-dd" '+minOffsetStr+maxOffsetStr+' });		\n');
		
		if ( mode == DateTimeMode.date || mode == DateTimeMode.dateTime )
			s.add("			$(\"#" + n_date + "\").change( updateDateTime ); \n");
		
		if ( mode == DateTimeMode.time || mode == DateTimeMode.dateTime )
		{
			s.add('			$("#' + n_time + '_hour").change( updateDateTime ); \n');
			s.add('			$("#' + n_time + '_min").change( updateDateTime ); \n');
			s.add('			$("#' + n_time + '_sec").change( updateDateTime ); \n');
		}
		
		//s.add('$("#' + n_date + '").bind("click", clickDatePicker)');
		
		s.add("		}); 									\n");
		
		s.add("		function updateDateTime() {\n");
			if ( mode == DateTimeMode.time )
				s.add("			$('#" + n + "').val( $('#" + n_time + "_hour').val() + ':' + $('#" + n_time + "_min').val() + ':' + $('#" + n_time + "_sec').val() ); \n");
			else if ( mode == DateTimeMode.date )
				s.add("			$('#" + n + "').val( $('#" + n_date + "').val() ); \n");
			else
				s.add("			$('#"+n+"').val( $('#"+n_date+"').val() + ' ' + $('#"+n_time+"_hour').val() + ':' + $('#"+n_time+"_min').val() + ':' + $('#"+n_time+"_sec').val() ); \n");
		s.add("		}\n");
		
		s.add("</script> 									\n");
		
		return s.toString();
	}
	
	public function toString() :String
	{
		return render();
	}
	
	override public function populate():Void
	{
		var n = parentForm.name + "_" + name;
		var v = App.current.params.get(n);

		if (v != null)
		{
			datetime = Std.string(v);
			//value = datetime.substr(0, 10);
			value = v;
		}
		
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