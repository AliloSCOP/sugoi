package sugoi.form.elements;

import sugoi.form.FormElement;

enum NativeDatePickerType {
  date;
  datetime;
  time;
}

class NativeDatePicker extends FormElement<Date> {
  private var type: NativeDatePickerType;

  public function new (name:String, label:String, ?_value:Date, ?type: NativeDatePickerType = NativeDatePickerType.date, ?required:Bool=false, ?attibutes:String="") {
    super();

    this.name = name;
    this.label = label;
    this.type = type;
    this.value =  _value;
    this.required = required;
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

		return switch(type){
			case date : value.toString().substr(0,10);
			default : 	value.toString().split(" ").join("T");
		}
		
	}

  	override public function getTypedValue(str:String):Date {

		if(str=="") return null;

		switch (type){
			case date:
			str = str.substr(0,10);

			case time :

			case datetime:
			//tranform 2000-01-01T00:00 to 2000-01-01 00:00:00
			str = str.split("T").join(" ");
			str = str + ":00";
		}
		
    	return Date.fromString(str);
  	}

  private function renderInputType() {
    return switch (type) {
      case NativeDatePickerType.datetime: "datetime-local";
      case NativeDatePickerType.time: "time";
      default: "date";
    }
  }
}