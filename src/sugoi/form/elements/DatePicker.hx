package sugoi.form.elements;

#if neko
import neko.Web;
#else
import php.Web;
#end
import sugoi.form.FormElement;
import sugoi.form.Validator;
import sugoi.form.ListData;

/**
 * DatePicker for Bootstrap
 * 
 * You'll need to install some additionnal js librairies (moment.js, jquery)
 * more info at : http://eonasdan.github.io/bootstrap-datetimepicker/
 */
class DatePicker extends FormElement
{
	public var maxOffset:Int;
	public var minOffset:Int;

	public var date : Date; //typed value, not like $value

	public var yearMin:Int;
	public var yearMax:Int;

	private var daySelector:Selectbox;
	private var monthSelector:Selectbox;
	private var yearSelector:Selectbox;
	
	public var format : String; //moment.js format

	public function new(name:String, label:String, ?_value:Date, ?required:Bool=false, yearMin:Int=1950, yearMax:Int=null, ?validators:Array<Validator>, ?attibutes:String="")
	{
		super();
		this.name = name;
		this.label = label;
		format = 'LLLL';

		if (_value == null) {
			value = Date.now();
			date = Date.now();
		}else {
			value = _value;
			date = _value;
		}

		this.required = required;
		this.attributes = attibutes;
		this.yearMin = yearMin;
		this.yearMax = yearMax;

		maxOffset = null;
		minOffset = null;

		var day = "";
		var month = "";
		var year = "";

		if (date != null)
		{
			day = 	""+date.getDate();
			month = ""+(date.getMonth()+1);
			year = 	""+date.getFullYear();
		}

	}

	override public function populate()
	{
		var d = App.current.params.get(parentForm.name + "_" + name);
		value = date = Date.fromTime(Std.parseFloat(d));

		//value = (day != null && month != null && year != null ) ? new Date(year, month - 1, day, 0, 0, 0) : null;
	}

	override public function isValid():Bool
	{
		return true;
	}

	override public function render():String
	{
		super.render();
		
		/*if (value != "" && value != null && value != "null")
		{
			try{
			var v:Date = cast value;
			daySelector.value = v.getDate();
			monthSelector.value = v.getMonth()+1;
			yearSelector.value = v.getFullYear();
			}catch(e:Dynamic){}
		}*/
		var defaultDate = (date.getMonth() + 1) + "/" + date.getDate() + "/" + date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
		return "<!--<div class='form-group'>-->
				<div class='input-group date' id='datetimepicker-"+name+"'>       
					<span class='input-group-addon'>
						<span class='glyphicon glyphicon-calendar'></span>
					</span>
					<input type='text' class='form-control' />
				</div>
			<!--</div>-->
			<input type='hidden' name='"+parentForm.name+"_"+name+"' id='datetimepickerdata-"+name+"' value='"+this.date.getTime()+"'/>
			<script type='text/javascript'>
				$(function () {
					$('#datetimepicker-"+name+"').datetimepicker(
						{
							locale:'fr',
							format:'"+this.format+"',
							defaultDate:'"+defaultDate+"'
						}
					);
					//stores the date as timestamp in a hidden input element	
					$('#datetimepicker-"+name+"').on('dp.change',function(e){
						var d = $('#datetimepicker-"+name+"').data('DateTimePicker').date()._d;
						$('#datetimepickerdata-"+name+"').val( d.getTime());
					});
				});
			</script>";
		
	}

}