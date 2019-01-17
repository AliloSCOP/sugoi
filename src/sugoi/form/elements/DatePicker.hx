package sugoi.form.elements;

import sugoi.Web;
import sugoi.form.FormElement;
import sugoi.form.validators.Validator;
import sugoi.form.ListData;

/**
 * DatePicker for Bootstrap 3
 * 
 * You'll need to install some additionnal js librairies (moment.js, jquery)
 * more info at : http://eonasdan.github.io/bootstrap-datetimepicker/
 */
class DatePicker extends FormElement<Date>
{
	public var maxOffset:Int;
	public var minOffset:Int;

	public var yearMin:Int;
	public var yearMax:Int;

	private var daySelector:Selectbox<Int>;
	private var monthSelector:Selectbox<Int>;
	private var yearSelector:Selectbox<Int>;
	
	public var format : String; //moment.js format

	public function new(name:String, label:String, ?v:Date, ?required:Bool=false, yearMin:Int=1950, yearMax:Int=null, ?validators:Array<Validator<Date>>, ?attibutes:String="")
	{
		
		super();
		this.name = name;
		this.label = label;
		format = 'LLLL';

		if (v == null) {
			this.value = Date.now();
		}else {
			this.value = v;
		}
		
		//trace(value);

		this.required = required;
		this.attributes = attibutes;
		this.yearMin = yearMin;
		this.yearMax = yearMax;

		maxOffset = null;
		minOffset = null;

		var day = "";
		var month = "";
		var year = "";

		if (value != null)
		{
			day = 	""+value.getDate();
			month = ""+(value.getMonth()+1);
			year = 	""+value.getFullYear();
		}

	}

	override public function populate()
	{
		//data is stored as float in the html form element
		var d = App.current.params.get(parentForm.name + "_" + name);
		//trace(parentForm.name + "_" + name+"="+d);
		//value = Date.fromTime(Std.parseFloat(d));
		value = Date.fromString(d);
	}

	override public function isValid():Bool
	{
		return true;
	}

	override public function render():String
	{

		//component init date
		//var d = value.getFullYear() +"-" + (value.getMonth() + 1) + "-" + value.getDate() + " " + value.getHours() + ":" + value.getMinutes()+":00";
		var d = value.toString();
		var defaultDate = 'moment("' + d + '", "YYYY-MM-DD HH:mm:ss")';
		
		return "
				<div class='input-group date' id='datetimepicker-"+name+"'>       
					<span class='input-group-addon'>
						<!--<i class='icon icon-calendar'></i>-->
						<span class='glyphicon glyphicon-calendar'></span>
					</span>
					<input type='text' class='form-control' />
				</div>
			
			<input type='hidden' name='"+parentForm.name+"_"+name+"' id='datetimepickerdata-"+name+"' value='"+d+"'/>
			<script type='text/javascript'>
				$(function () {
					$('#datetimepicker-"+name+"').datetimepicker(
						{
							locale:'fr',
							format:'"+this.format+"',
							defaultDate:"+defaultDate+"
						}
					);
					//stores the date in mysql format in a hidden input element	
					$('#datetimepicker-"+name+"').on('dp.change',function(e){
						var d = $('#datetimepicker-"+name+"').data('DateTimePicker').date();//moment.js obj
						//fix 2038 date overflow bug https://en.wikipedia.org/wiki/Year_2038_problem
						if(d.year()>2037) d.year(2037);
						console.log(d.toString());
						$('#datetimepickerdata-"+name+"').val( d.format('YYYY-MM-DD HH:mm:ss'));
					});
				});
			</script>";
		
	}

}