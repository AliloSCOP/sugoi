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

	// Submitted button's name
	public var submittedButtonName : String;
	var wymEditorCount:Int;
	public static var translator : ITranslator;

	//conf
	//public static var HTML5 = App.config.getBool('form.Form.HTML5', true);
	public static var USE_TWITTER_BOOTSTRAP = true;// App.config.getBool('form.Form.USE_TWITTER_BOOTSTRAP', true);

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

		wymEditorCount = 0;

		submittedButtonName = null;

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

	public function getElement(name:String):FormElement{
		for (element in elements)
		{
			if (element.name == name)
				return element;
		}

		throw "Cannot access Form Element: '" + name + "'";
		return null;
	}
	
	public function removeElementByName(name:String) {
		var e = getElement(name);
		if (e != null) removeElement(e);
	}

	public function getValueOf(elementName:String):String{
		return StringTools.trim(getElement(elementName).value);
	}

	public function getElementTyped<T>(name:String, type:Class<T>):T{
		var o:T = cast(getElement(name));
		return o;
	}

	/**
	 * return datas contained in current form elements
	 * @return
	 */
	public function getData():Dynamic
	{
		var data:Dynamic = {};
		for (element in getElements())
		{
			//if ( Std.is( element, Checkbox ) )
				//Reflect.setField(data, element.name, cast( element, Checkbox ).checked );
			//else
				Reflect.setField(data, element.name, element.value);
			if ( Std.is(element, DateSelector) )
			{
				var ds = cast(element, DateSelector);
				//trace("ds.value = " + ds.value);
			}
		}
		return data;
	}

	/**
	 * populate Form from anonymous object or if null from web params.
	 * @param	custom
	 */
	public function populateElements(custom:Dynamic=null){
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
		var id = Std.parseInt(Reflect.field(data, "id"));
		if (id == 0) id = null;
		if (id != null) {
			obj.lock();
		}

		for (f in Reflect.fields(data)) {
			//check if field was in the original form
			if (this.getElement(f) == null) throw "field '"+f+"' was not in the original form";
			var v = Reflect.field(data, f);
			if (v != null && f!="id") {
				//App.log("toSpod set "+f+" = "+v);
				if (Std.is(v, String)) {
					v = StringTools.trim(v);
					if (v == "") v = null;
				}
				Reflect.setField(obj, f, v);
			}

		}
	}

	/**
	 * Generate a form from any object
	 * @param	obj
	 */
	public static function fromObject(obj:Dynamic) {
		//TODO

		var f = new Form('fromObj');
		f.populateElements(obj);
		return f;
	}

	/*
	 *  Generate a form from a spod object
	 */
	public static function fromSpod(obj:sys.db.Object) {

		//generate a unique form name
		var name = "";
		try {
			name = obj.toString();
		}catch(e:Dynamic) {
			name = Type.getClassName(Type.getClass(obj));
		}

		var form = new Form("form"+Md5.encode(name));
		var ti = new TableInfos(Type.getClassName(Type.getClass(obj)));

		//translator
		var t = Form.translator;
		if(t == null) t = Form.translator = new sugoi.i18n.translator.TMap(new Map<String,String>(), App.current.session.lang);

		for(f in ti.fields) {
			var e : FormElement;
			//field value
			var v = Reflect.field(obj, f.name);

			//check if its a foreign key
			var rl = Lambda.filter(ti.relations, function(r) return r.key == f.name );
			var isNull = ti.nulls.get(f.name);
			if (rl.length > 0 ) {
				//foreign key

				var r = rl.first();
				//Sys.print(f.name + ' is a key for ' + r.key + "/"+r.prop);
				var objects = new List();
				var meta = haxe.rtti.Meta.getFields(Type.getClass(obj));
				var objMeta :Dynamic = Reflect.field(meta, r.prop);
				//trace("field "+ r.prop + " de "+meta+" = "+objMeta );
				if (objMeta != null && objMeta.formPopulate != null) {
					//populate customisé avec @formPopulate()
					objects = Reflect.callMethod(obj, Reflect.field(obj,Std.string(objMeta.formPopulate[0])) , []);
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
					//e = new Input(f.name, f.name, v, null,null,null,true);
					e = new Hidden(t._(f.name), v);

				case DEncoded:
					e = new Input(f.name,t._(f.name), v);
				case DFlags(fl, auto):
					//App.log("flag data : "+fl);
					e = new Flags(f.name,t._(f.name), Lambda.array(fl), Std.parseInt(v), false);

				case DTinyInt, DUInt, DSingle, DFloat:
					e = new Input(f.name, t._(f.name), v);
				case DBool :
					e = new Checkbox(f.name, t._(f.name), Std.string(v)=='true');
				case DString(n):
					e = new Input(f.name,t._(f.name), v, !isNull ,null,"lenght="+n);
					/*
					case DDate: "DATE";
					case DDateTime: "DATETIME";
					case DTimeStamp: "TIMESTAMP"+(nulls.exists(f.name) ? " NULL DEFAULT NULL" : " DEFAULT 0");*/
				case DTinyText, DSmallText, DText, DSerialized:
					e = new TextArea(f.name, t._(f.name), v,!isNull);
					/*case DSmallBinary: "BLOB";
					case DBinary, DNekoSerialized: "MEDIUMBLOB";
					case DData: "MEDIUMBLOB";
					case DEnum(_): "TINYINT UNSIGNED";
					case DLongBinary: "LONGBLOB";
					case DBigInt: "BIGINT";
					case DBigId: "BIGINT AUTO_INCREMENT";
					case DBytes(n): "BINARY(" + n + ")";
					case DTinyUInt: "TINYINT UNSIGNED";
					case DSmallInt: "SMALLINT";
					case DSmallUInt: "SMALLINT UNSIGNED";
					case DMediumInt: "MEDIUMINT";
					case DMediumUInt: "MEDIUMINT UNSIGNED";
					case DNull, DInterval: throw "assert";*/
				case DTimeStamp, DDateTime:
					var d = Date.now();
					try{
						d = Date.fromString(Std.string(v));
					}catch (e:Dynamic) {}
					e = new DateInput(f.name, t._(f.name), d);
				case DDate :
					var d = Date.now();
					try{
						d = Date.fromString(Std.string(v));
					}catch (e:Dynamic) {}
					e = new DateDropdowns(f.name, t._(f.name), d);

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
		//
		return '<form id="' + id + '" name="' + name + '" method="' + method +'" action="' + action +'" ' + (multipart?'enctype="multipart/form-data"':'') + ' >';

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

		populateElements();

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
		var s:StringBuf = new StringBuf();
		s.add(getOpenTag());

		if (isSubmitted())
			s.add(getErrors());

		s.add('<table cellspacing="0" cellspacing="0" border="0" >\n');

		for (element in getElements())
			if (element != submitButton && element.internal == false)
				s.add("\t"+element.getPreview()+"\n");

		//submit button
		if (submitButton != null) {
			submitButton.parentForm = this;
		}else {
			submitButton = new Submit('submit', 'OK');
			submitButton.parentForm = this;
		}
		s.add(submitButton.getPreview());

		s.add("</table>\n");
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