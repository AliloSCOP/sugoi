package sugoi.form;

import haxe.crypto.Md5;
import sugoi.i18n.translator.ITranslator;
import sugoi.form.elements.*;
#if neko
import neko.Web;
#else
import php.Web;
#end
import sys.db.Types;
import sys.db.Object;
import sys.db.Manager;
import sys.db.TableInfos;

class Form
{
	public var id:String;
	public var name:String;
	public var action:String;
	public var method:FormMethod;
	public var elements:Array<FormElement>;
	public var fieldsets:Map<String,FieldSet>;
	public var forcePopulate:Bool;		//the form is populated by web params if isValid() is called
	public var submitButton:FormElement;
	private var extraErrors:List<String>;
	public var requiredClass:String;
	public var requiredErrorClass:String;
	public var invalidErrorClass:String;
	public var labelRequiredIndicator:String;
	public var defaultClass : String;
	public var multipart:Bool;

	public static var translator : ITranslator;

	public var submitButtonLabel:String;
	
	//conf	
	public static var USE_TWITTER_BOOTSTRAP = true;// App.config.getBool('form.Form.USE_TWITTER_BOOTSTRAP', true);
	public static var USE_DATEPICKER = true; //http://eonasdan.github.io/bootstrap-datetimepicker/

	public function new(name:String, ?action:String, ?method:FormMethod)
	{
		requiredClass = "formRequired";
		requiredErrorClass = "formRequiredError";
		invalidErrorClass = "formInvalidError";
		labelRequiredIndicator = " *";

		forcePopulate = true;
		multipart = false;

		this.id = this.name = name;
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
	}

	/**
	 * Adds a form element to the form
	 * @param	element
	 * @param	?fieldSetKey	Add it to a specific fieldset
	 * @param 	?index			which index do u want to push it
	 * @return
	 */
	public function addElement(element:FormElement,?index:Int, ?fieldSetKey:String = "__default"):FormElement
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

	public function removeElement(element:FormElement):Bool
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

	public function setSubmitButton(el:FormElement):FormElement
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

	public function getElement(name:String):FormElement {
		if (name == null || name=='') throw "Element name is null";
		for (element in elements){
			if (element.name == name) return element;
		}

		throw "Cannot access form element: '" + name + "'";
		return null;
	}
	
	public function removeElementByName(name:String) {
		var e = getElement(name);
		if (e != null) removeElement(e);
	}

	/**
	 * Get the value of a form element 
	 * @param	elementName
	 * @return
	 */
	public function getValueOf(elementName:String):String {
		var v = getElement(elementName).value;
		if (v == null) return null;
		return StringTools.trim(v);
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
		for (element in getElements())
		{
			
			if(Std.is(element.value,String)) {
				//trace(element.name+" "+element.value);
				var val = StringTools.trim(element.value);
				if (val == "") val = null;
				data.set(element.name, val );	
			}else {
				data.set(element.name,element.value);	
			}
			
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
	public function populate(custom:Dynamic=null){
		if (custom != null)
		{
			for (element in getElements()) {
				var n = element.name;
				var v = Reflect.field(custom, n);
				if (v != null)
					element.value = v;
			}
		} else {
			var element:FormElement;
			for (element in getElements()) {
				//populate from web param
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
			
			if (Std.is(v, String)) {
				v = StringTools.trim(v);
				if (v == "") v = null;
			}
			//trace(f + " -> " + v);
			Reflect.setProperty(obj, f, v);
			

		}
	}

	/**
	 * Generate a form from any object
	 * @param	obj
	 */
	public static function fromObject(obj:Dynamic) {
		var form = new Form('fromObj');
		for (f in Reflect.fields(obj)) {
			var val = StringTools.trim(Reflect.field(obj, f));
			if (val == "") val = null;
			form.addElement(new sugoi.form.elements.Input(f, f, val));
		}
		form.populate(obj);
		return form;
	}

	/*
	 *  Generate a form from a spod object
	 */
	public static function fromSpod(obj:sys.db.Object) {

		//generate a form name
		var name = Type.getClassName(Type.getClass(obj));

		var form = new Form("form"+Md5.encode(name));
		var ti = new TableInfos(Type.getClassName(Type.getClass(obj)));

		//translator
		var t = Form.translator;
		if(t == null) t = Form.translator = new sugoi.i18n.translator.TMap(new Map<String,String>(), App.current.session.lang);

		//get metas of this object
		var metas = haxe.rtti.Meta.getFields(Type.getClass(obj));
		
		//loop on db object fields to create form elements
		for (f in ti.fields) {
			
			var e : FormElement;
			//field value
			var v = Reflect.field(obj, f.name);

			//meta of this field						
			var meta :Dynamic = Reflect.field(metas, f.name);
			//trace(f.name+"=>" + meta + "<br/>");
			
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
						//populate customisé avec @formPopulate()
						objects = Reflect.callMethod(obj, Reflect.field(obj,Std.string(meta.formPopulate[0])) , []);	
					}
					
					if (meta!=null && Reflect.hasField(meta,'hideInForms')) {
						continue;
					}
					
					
				}else {
					//choppe toute les valeurs possibles
					objects = r.manager.all(false).map(function(d) {
						return {
							key : Std.string(Reflect.field(d,r.manager.table_keys[0])),
							value : d.toString()
						};
					});
				}

				e = new Selectbox(f.name, t._(r.prop), Lambda.array(objects),v, !isNull);

			}else {
				//not foreign key

				switch (f.type) {
				case DInt:
					e = new Input(f.name,t._(f.name), v, !isNull);

				case DId, DUId:
					e = new Hidden(f.name, v);

				case DEncoded:
					e = new Input(f.name, t._(f.name), v);
					
				case DFlags(fl, auto):
					e = new Flags(f.name,t._(f.name), Lambda.array(fl), Std.parseInt(v), false);

				case DTinyInt, DUInt, DSingle, DFloat:
					e = new Input(f.name, t._(f.name), v);
					
				case DBool :
					e = new Checkbox(f.name, t._(f.name), Std.string(v) == 'true');
					
				case DString(n):
					e = new Input(f.name,t._(f.name), v, !isNull ,null,"lenght="+n);
		
				case DTinyText, DSmallText, DText, DSerialized:
					e = new TextArea(f.name, t._(f.name), v,!isNull);

				case DTimeStamp, DDateTime:
					var d = Date.now();
					try{
						d = Date.fromString(Std.string(v));
					}catch (e:Dynamic) { }
					
					if (USE_DATEPICKER) {
						e = new DatePicker(f.name, t._(f.name), d);
						untyped e.format = "LLLL";
					}else {
						e = new DateInput(f.name, t._(f.name), d);	
					}
					
				case DDate :
					var d = Date.now();
					try{
						d = Date.fromString(Std.string(v));
					}catch (e:Dynamic) { }
					if (USE_DATEPICKER) {
						e = new DatePicker(f.name, t._(f.name), d);	
						untyped e.format = "LL";
					}else {
						e = new DateDropdowns(f.name, t._(f.name), d);	
					}
					

				case DEnum(name):
					e = new Enum(f.name, t._(f.name), name, Std.parseInt(v) );

				default :
					e = new Input(f.name, t._(f.name) , "unknown field type : "+f.type+", value : "+v);
				}
			}
			form.addElement(e);
		}
		return form;
	}


	public function clearData()
	{
		var element:FormElement;
		for (element in getElements()){
			element.value = null;
		}
	}

	function getOpenTag():String
	{
		//return '<form id="'+id+'" name="' + name + '" method="'+ method +'" action="'+ action +'"  >';

		//multipart = false;
		//for ( e in elements) {
			//if (Std.is(e,FileUpload)) multipart == true;
		//}
		
		return '<form id="' + id + '" class="'+(Form.USE_TWITTER_BOOTSTRAP?"form-horizontal":"")+'" name="' + name + '" method="' + method +'" action="' + action +'" ' + (multipart?'enctype="multipart/form-data"':'') + ' >';

	}

	function getCloseTag():String
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

		//if (forcePopulate && valid) {

		//}

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

	public function getElements():Array<FormElement>
	{
		return elements;
	}

	public function isSubmitted():Bool
	{
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

	public function toString()
	{
		/* <div class="form-group">
			<label for="inputEmail3" class="col-sm-2 control-label">Email</label>
				<div class="col-sm-10">
				  <input type="email" class="form-control" id="inputEmail3" placeholder="Email">
			</div>
		</div>*/
		
		var s:StringBuf = new StringBuf();
		s.add(getOpenTag());

		if (isSubmitted())
			s.add(getErrors());

		

		for (element in getElements())
			if (element != submitButton && element.internal == false)
				s.add("\t"+element.getFullRow()+"\n");

		//submit button
		if (submitButton != null) {
			submitButton.parentForm = this;
		}else {
			submitButton = new Submit('submit', submitButtonLabel != null ? submitButtonLabel : 'OK');
			submitButton.parentForm = this;
		}
		s.add(submitButton.getFullRow());

		
		s.add(getCloseTag());

		return s.toString();
	}

}

class FieldSet
{
	public var name:String;
	public var form:Form;
	public var label:String;
	public var visible:Bool;
	public var elements:Array<FormElement>;

	public function new(?name:String = "", ?label:String = "", ?visible:Bool = true)
	{
		this.name = name;
		this.label = label;
		this.visible = visible;

		elements = [];
	}

	public function getOpenTag()
	{
		return "<fieldset id=\""+form.name+"_"+name+"\" name=\""+form.name+"_"+name+"\" class=\""+(visible?"":"fieldsetNoDisplay")+"\" ><legend>" + label + "</legend>";
	}

	public function getCloseTag()
	{
		return "</fieldset>";
	}
}

enum FormMethod
{
	GET;
	POST;
}