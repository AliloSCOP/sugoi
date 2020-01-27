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
    this.value = _value == null ? Date.now() : _value;
    this.required = required;
		this.attributes = attibutes;
  }

  override public function render():String {
    var inputName = parentForm.name + "_" + name;
    var inputType = renderInputType();
    return '
      <input
          name=$inputName
          type=$inputType 
          value=$value
          '+ (required == true ? 'required' : '') +'
          '+ attributes +'
      />
    ';
  }

  override public function populate() {
    var n = parentForm.name + "_" + name;
    var v = App.current.params.get(n);
    value = Date.fromString(v);
  }

  private function renderInputType() {
    return switch (type) {
      case NativeDatePickerType.datetime: "datetime-local";
      case NativeDatePickerType.time: "time";
      default: "date";
    }
  }
}