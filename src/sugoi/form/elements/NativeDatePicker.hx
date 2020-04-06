package sugoi.form.elements;

import sugoi.form.FormElement;
#if php
import php.Web;
#else
import neko.Web;
#end

enum NativeDatePickerType {
  date;
  datetime;
  time;
}

class NativeDatePicker extends FormElement<Date> {
  private var type: NativeDatePickerType;

  public function new (
    name:String,
    label:String,
    ?_value:Date,
    ?type: NativeDatePickerType = NativeDatePickerType.date,
    ?required:Bool=false,
    ?attibutes:String=""
  ) {
    super();

    this.name = name;
    this.label = label;
    this.type = type;
    this.required = required;
    this.value =  (this.required == true && _value == null) ? Date.now() : _value;
	  this.attributes = attibutes;
  }

  override public function render():String {
    var inputName = parentForm.name + "_" + name;
    return '
      <input
          name="$inputName"
          type="${renderInputType()}" 
          value="${renderDate()}"
          '+ (required == true ? 'required' : '') +'
          '+ attributes +'
      />
    ';
  }

  	/**
		  format date for input
	  **/
	function renderDate():String{
		if(value==null) return "";

		return switch(type) {
      case time: value.toString().split(" ")[1];
      case datetime: value.toString().split(" ").join("T");
			default : value.toString().substr(0,10);
		}
	}

  override public function getTypedValue(str:String):Date {
		if(str=="" || str==null) return null;

		switch (type){
			case time :
        var strSplited = str.split(":");
        var now = Date.now();
        return new Date(now.getFullYear(), now.getMonth(), now.getDay(), Std.parseInt(strSplited[0]), Std.parseInt(strSplited[1]), 0);
			case datetime:
      //tranform 2000-01-01T00:00 to 2000-01-01 00:00:00
        var strSplited = str.split("T");
        str = strSplited.join(" ");
        if (strSplited[1].split(":").length == 2) {
          str += ":00";
        }
        return Date.fromString(str);
      default:
        str = str.substr(0,10);
        return Date.fromString(str);
		}
  }

  private function renderInputType() {
    return switch (type) {
      case NativeDatePickerType.datetime: "datetime-local";
      case NativeDatePickerType.time: "time";
      default: "date";
    }
  }
}