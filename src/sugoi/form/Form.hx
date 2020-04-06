package sugoi.form;

import haxe.crypto.Md5;
import sugoi.form.elements.Input;
import sugoi.i18n.translator.ITranslator;
import sugoi.form.elements.*;
import sugoi.form.elements.NativeDatePicker;
import sugoi.Web;
import sys.db.Types;
import sys.db.Object;
import sys.db.Manager;
import sys.db.admin.TableInfos;

enum FormMethod
{
	GET;
	POST;
}

class Form
{
	public var id:String;
	public var name:String;
	public var action:String;
	public var method:FormMethod;
	public var elements:Array<FormElement<Dynamic>>;
	public var fieldsets:Map<String,FieldSet>;
	public var forcePopulate:Bool;		//the form is populated by web params if isValid() is called
	public var submitButton:FormElement<String>;
	private var extraErrors:List<String>;
	public var requiredClass:String;
	public var requiredErrorClass:String;
	public var invalidErrorClass:String;
	public var labelRequiredIndicator:String;
	public var defaultClass : String;
	public var multipart:Bool;

	public static var translator : ITranslator;
	
	//submit button
	public var submitButtonLabel:String;
	public var autoGenSubmitButton:Bool;	//add a submit button automatically
	
	//conf	
	public static var USE_TWITTER_BOOTSTRAP = true;
	//public static var USE_DATEPICKER = true; //http://eonasdan.github.io/bootstrap-datetimepicker/

	public var toString : Void->String; //you can change the way the form is rendered

	public function new(name:String, ?action:String, ?method:FormMethod)
	{
		requiredClass = "formRequired";
		requiredErrorClass = "formRequiredError";
		invalidErrorClass = "formInvalidError";
		labelRequiredIndicator = " *";
		defaultClass = Form.USE_TWITTER_BOOTSTRAP ? "form-horizontal":"";

		forcePopulate = true;
		multipart = false;
		autoGenSubmitButton = true;

		this.id = name;
		this.name = name;
		
		if (action == null) {
			this.action = Web.getURI();
		}else {
			this.action = action;
		}

		this.method = (method == null) ? FormMethod.POST : method;

		elements = new Array();
		extraErrors = new List();
		fieldsets = new Map();
		addFieldset("__default", new FieldSet("__default", "Default", false));

		addElement(new CSRFProtection());

		toString = render;
	}

	/**
	 * Adds a form element to the form
	 * @param	element
	 * @param	?fieldSetKey	Add it to a specific fieldset
	 * @param 	?index			which index do u want to push it
	 * @return
	 */
	public function addElement(element:FormElement<Dynamic>,?index:Int, ?fieldSetKey:String = "__default"):FormElement<Dynamic>
	{
		element.parentForm = this;
		if (index != null) {
			var out = elements.slice(0, index);
			out = out.concat([element]);
			out = out.concat(elements.slice(index));
			elements = out;
		}else {
			elements.push(element);
		}

		// add it to a group if requested
		if (fieldSetKey != null){
			if (!fieldsets.exists(fieldSetKey)) throw "No fieldset '" + fieldSetKey + "' exists in '" + name + "' form.";
			fieldsets.get(fieldSetKey).elements.push(element);
		}

		//if ( Std.is(element, RichtextWym) )
			//wymEditorCount++;

		return element;
	}

	public function removeElement(element:FormElement<Dynamic>):Bool
	{
		if ( elements.remove(element) )
		{
			element.parentForm= null;
			for ( fs in fieldsets )
			{
				fs.elements.remove(element);
			}

			//if ( Std.is(element, RichtextWym) )
				//wymEditorCount--;
			return true;
		}
		return false;
	}

	public function setSubmitButton(el:FormElement<String>):FormElement<String>
	{
		submitButton = el;
		submitButton.parentForm = this;
		return el;
	}

	public function addFieldset(fieldSetKey:String, fieldSet:FieldSet)
	{
		fieldSet.form = this;
		fieldsets.set(fieldSetKey, fieldSet);
	}

	public function getFieldsets():Map<String,FieldSet>
	{
		return fieldsets;
	}

	public function getLabel( elementName : String ) : String
	{
		return getElement( elementName ).getLabel();
	}

	public function getElement(name:String):FormElement<Dynamic> {
		if (name == null || name=='') throw "Element name is null";
		for (element in elements){
			if (element.name == name) return element;
		}
		return null;
	}
	
	public function removeElementByName(name:String) {
		var e = getElement(name);
		if (e != null) removeElement(e);
	}

	/**
	 * Get the typed value of a form element. 
	 * The value can be of any type !
	 * 
	 * @param	elementName
	 * @return
	 */
	public function getValueOf(elementName:String):Dynamic {
		return getElement(elementName).value;
	}

	public function getElementTyped<T>(name:String, type:Class<T>):T{
		var o:T = cast(getElement(name));
		return o;
	}

	/**
	 * return datas contained in current form elements
	 * @return
	 */
	public function getData():Map<String,Dynamic>
	{
		var data = new Map<String,Dynamic>();
		for (element in getElements()){
			if (element.name == null) throw "Element has no name : "+element.toString();
			data.set( element.name,element.getValue() );	
		}
		return data;
	}
	
	/**
	 * return datas in an anonymous object
	 * @return
	 */
	public function getDatasAsObject():Dynamic {
	
		var data = { };
		for ( el in elements) {
			Reflect.setField(data, el.name, el.value);
		}
		return data;
		
	}

	/**
	 * populate Form from anonymous object or if null from web params.
	 * @param	custom
	 */
	public function populate(?custom:Dynamic){
		if (custom != null)	{
			//from object
			for (element in getElements()) {
				var n = element.name;
				var v = Reflect.field(custom, n);
				if (v != null)
					element.value = v;
			}
		} else {
			for (element in getElements()) {
				//populate from web params
				element.populate();
			}
		}
	}

	/**
	 * update a spod object from the content of the form
	 * @param	data
	 * @param	obj
	 */
	public function toSpod(obj:sys.db.Object) {
		if (!isValid()) throw "submitted form should be valid";
		var data = getData();

		//if not new object, lock it
		var id = Std.parseInt(data.get("id"));
		if (id == 0) id = null;
		if (id != null) {
			obj.lock();
		}

		for (f in data.keys()) {
			
			//check if field was in the original form
			if (this.getElement(f) == null) throw "field '"+f+"' was not in the original form";
			var v = data.get(f);
			if (f == "id") continue;
			
			//Values are already cleaned by each form elements when populated
			/*if (Std.is(v, String)) {
				v = StringTools.trim(v);
				if (v == "") v = null;
			}*/
			
			//Debug : trace(f + " -> " + v+"<br>");
			try{
				Reflect.setProperty(obj, f, v);
			}catch (e:Dynamic){
				throw "Error '" + e+"' while setting value " + v + " to " + f;
			}
		}
	}

	/**
	 * Generate a form from any object
	 * @param	obj
	 */
	public static function fromObject(obj:Dynamic) {
		var form = new Form('fromObj');
		for (f in Reflect.fields(obj)) {
			var val = Reflect.field(obj, f);
			if (val == "") val = null;
			form.addElement(new sugoi.form.elements.StringInput(f, f, val));
		}		
		return form;
	}
	
	/*
	 *  Generate a form from a spod object
	 */
	public static function fromSpod(
		obj:sys.db.Object,
		?fieldTypeToElementMap:Map<String , (name: String, label: String, value: Dynamic, ?required: Bool)->Dynamic>
	){

		//generate a form name
		var cl = Type.getClass(obj);
		var name = Type.getClassName(cl);

		var form = new Form("form"+Md5.encode(name));
		var ti = new TableInfos(Type.getClassName(Type.getClass(obj)));

		//translator
		//var t = Form.translator;
		var t = new Map<String,String>();
		if (Reflect.hasField(cl, "getLabels")){
			t = Reflect.callMethod(cl, Reflect.getProperty(cl,"getLabels"),[]); 
		}
		var label = function(s) return if (t.get(s) == null)  s else t.get(s);

		//get metas of this object
		var metas = haxe.rtti.Meta.getFields(Type.getClass(obj));
		
		//loop on db object fields to create form elements
		for (f in ti.fields) {
			
			var e : FormElement<Dynamic>;
			//field value
			var v :Dynamic = Reflect.field(obj, f.name);
			//trace( "field " + f.name+" of " + obj + " is " + v+"<br/>");

			//meta of this field						
			var meta :Dynamic = Reflect.field(metas, f.name);
			// if(meta==null) meta = Reflect.field(metas, StringTools.replace(f.name,"Id",""));
			//trace(f.name + "=>" + meta + "<br/>");
			
			//hide this field in forms
			if (meta!=null && Reflect.hasField(meta,'hideInForms')) {				
				continue;
			}
			
			//check if its a foreign key
			var rl = Lambda.filter(ti.relations, function(r) return r.key == f.name );
			var isNull = ti.nulls.get(f.name);
			
			//foreign keys
			if (rl.length > 0 ) {
				
				var r = rl.first();
				//trace(f.name + ' is a key for ' + r.key + "/"+r.prop);
				var objects = new List();
				
				meta = Reflect.field(metas, r.prop);
				if (meta != null) {
					//trace(r.prop+"=>" + meta + "<br/>");
					if (meta.formPopulate != null) {
						//If @formPopulate() meta is set, use this function to populate select box.
						objects = Reflect.callMethod(obj, Reflect.field(obj,Std.string(meta.formPopulate[0])) , []);	
					}
					
					//if @hideInForms meta is set, hide the fields in the form
					if (meta!=null && Reflect.hasField(meta,'hideInForms')) {
						continue;
					}
					
				}else {
					//get all available values
					objects = r.manager.all(false).map(function(d) {
						return {
							label : d.toString(),
							value : Reflect.field(d,r.manager.table_keys[0])
						};
					});
				}

				e = new IntSelect(f.name, label(r.prop), Lambda.array(objects),v, !isNull);

			}else {
				//not foreign key

				switch (f.type) {
				case DId, DUId:
					e = new IntInput(f.name, "id", v, false);
					untyped e.inputType = ITHidden;

				case DEncoded:
					e = new StringInput(f.name, label(f.name), v);
					
				case DFlags(fl, auto):
					e = new Flags(f.name,label(f.name), Lambda.array(fl), Std.parseInt(v));

				case DTinyInt, DUInt, DSingle, DInt:
					e = new IntInput(f.name, label(f.name) , v , !isNull);
				
				case DFloat:
					if(fieldTypeToElementMap!=null && fieldTypeToElementMap["DFloat"]!=null){
						e = fieldTypeToElementMap["DFloat"](f.name,label(f.name),v);
					}else{
						e = new FloatInput(f.name, label(f.name), v, !isNull );
					}
					
				case DBool :
					e = new Checkbox(f.name, label(f.name), Std.string(v) == 'true');
					
				case DString(n):
					e = new StringInput(f.name,label(f.name), v, !isNull ,null,"maxlength="+n);
		
				case DTinyText, DSmallText, DText, DSerialized:
					e = new TextArea(f.name, label(f.name), v,!isNull);

				case DTimeStamp, DDateTime:
					
					if(fieldTypeToElementMap!=null && fieldTypeToElementMap["DDateTime"]!=null){
						e = fieldTypeToElementMap["DDateTime"](f.name,label(f.name),v);
					}else{
						e = new NativeDatePicker(f.name, label(f.name), v, NativeDatePickerType.datetime);
					}
					
				case DDate :

					if(fieldTypeToElementMap!=null && fieldTypeToElementMap["DDate"]!=null){
						e = fieldTypeToElementMap["DDate"](f.name,label(f.name),v);
					}else{
						e = new NativeDatePicker(f.name, label(f.name), v, NativeDatePickerType.date);
					}

				case DEnum(name):
					e = new sugoi.form.elements.Enum(f.name, label(f.name), name, Std.parseInt(v), !isNull);

				default :
					e = new StringInput(f.name, label(f.name) , "unknown field type : "+f.type+", value : "+v);
				}
			}
			
			form.addElement(e);
		}
		return form;
	}


	public function clearData()
	{
		for (element in getElements()){
			element.value = null;
		}
	}

	/**
	 * Prints form open tag <form ...>
	 */
	public function getOpenTag():String
	{
		//if there is a file input in the form, make it multipart
		for ( e in elements) {
			if (Type.getClass(e) == sugoi.form.elements.FileUpload || Type.getClass(e) == sugoi.form.elements.ImageUpload){
				multipart = true;
				break;
			}
		}
		return '<form id="' + id + '" class="'+defaultClass+'" name="' + name + '" method="' + method +'" action="' + action +'" ' + (multipart?'enctype="multipart/form-data"':'') + ' >';
	}

	/**
	 * Prints form close tag ...</form>
	 */
	public function getCloseTag():String
	{
		var s = new StringBuf();
		s.add('<div style="clear:both; height:0px;">&nbsp;</div>');
		s.add('<input type="hidden" name="' + name + '_formSubmitted" value="true" /></form>');
		return s.toString();
	}

	public function isValid():Bool
	{
		if (!isSubmitted()) return false;

		populate();

		var valid = true;

		for (element in getElements()){
			//trace(element.name+" -> "+element.value+" : "+element.isValid()+"<br>");
			element.filter();
			if (!element.isValid()) valid = false;
		}
		if (extraErrors.length > 0) valid = false;
		return valid;
	}

	public function checkToken() {
		return isValid();
	}

	public function addError(error:String)
	{
		extraErrors.add(error);
	}

	public function getErrorsList():List<String>
	{
		isValid();

		var errors:List<String> = new List();

		for(e in extraErrors)
			errors.add(e);

		for (element in getElements())
			for (error in element.getErrors())
				errors.add(error);

		return errors;
	}

	public function getElements():Array<FormElement<Dynamic>>
	{
		return elements;
	}

	public function isSubmitted():Bool
	{
		//if (multipart){
			//var req = sugoi.tools.Utils.getMultipart(1024 * 1024 * 12);
			//for ( r in req.keys() ) App.current.params.set(r, req.get(r));
		//}

		return App.current.params.get(name + "_formSubmitted") == "true";
	}

	public function getSubmittedValue():String
	{
		return App.current.params.get(name + "_formSubmitted");
	}

	public function getErrors():String
	{
		if (!isSubmitted())
			return "";

		var s:StringBuf = new StringBuf();
		var errors = getErrorsList();

		if (errors.length > 0)
		{
			if (USE_TWITTER_BOOTSTRAP) s.add('<div class="alert alert-danger">');
			s.add("<ul class=\"formErrors\" >");
			for (error in errors)
			{
				s.add("<li>"+error+"</li>");
			}
			s.add("</ul>");
			if (USE_TWITTER_BOOTSTRAP) s.add('</div>');
		}
		return s.toString();
	}

	/**
	 * Render form's HTML
	 */
	public function render()
	{

		var s:StringBuf = new StringBuf();
		s.add(getOpenTag());

		//errors
		if (isSubmitted())
			s.add(getErrors());

		for (element in getElements())
			if (element != submitButton && element.internal == false)
				s.add("\t"+element.getFullRow()+"\n");

		//submit button
		if (submitButton != null) {
			submitButton.parentForm = this;
		}else if(autoGenSubmitButton){
			submitButton = new Submit('submit', submitButtonLabel != null ? submitButtonLabel : 'OK');
			submitButton.parentForm = this;
		}
		if(submitButton!=null) s.add(submitButton.getFullRow());
		
		s.add(getCloseTag());

		return s.toString();
	}

}