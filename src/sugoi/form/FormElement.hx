package sugoi.form;

import sugoi.form.filters.IFilter;
import sugoi.form.validators.Validator;
using StringTools;

class FormElement<T>
{
	public var parentForm:Form;
	public var name:String;
	public var label:String;
	public var description:String;
	
	//value can be any type : Int, Float, Enum... 
	public var value:T;		
	
	public var required:Bool;
	public var errors:List<String>;
	public var attributes:String;
	public var active:Bool;
	
	public var cssClass:String;
	public var inited:Bool;
	public var internal:Bool;
	
	public var validators:List<Validator<T>>;
	public var filters:List<IFilter<T>>;

	public function new()
	{
		active = true;
		errors = new List();
		validators = new List();
		filters = new List();		
		inited = false;
		internal = false;
	}
	
	/**
	 * apply all linked filter to the data
	 */
	public function filter() {
		for ( f in filters) {
			value = f.filter(value);
		}
		return value;
	}
	
	/**
	 * Checks if the current value of the elements is valid
	 */
	public function isValid():Bool
	{
		errors.clear();

		if (!active) return true;

		if ( value == null && required ) {
			//required field is empty
			errors.add("<span class=\"formErrorsField\">\"" + ((label != null && label != "") ? label : name) + "\"</span> ne doit pas être vide.");
			return false;
		}

		if (value!=null) {
			//check validity
			if (!validators.isEmpty()){
				for (validator in validators)
				{
					if (!validator.isValid(value)) 	return false;
				}

			}

			return true;
		}
		return true;
	}

	public function init(){
		inited = true;
	}

	public function addValidator(validator:Validator<T>){
		validators.add(validator);
	}
	
	public function addFilter(filter:IFilter<T>) {
		filters.add(filter);
	}

	/**
	 * Fill the element with a value taken from the web params
	 */
	public function populate():Void
	{
		if (!inited) init();

		var n = (parentForm==null?"":parentForm.name) + "_" + name;
		var v = App.current.params.get(n);
		value = getTypedValue(v);
		
		//Debug
		//trace("value of " + name +"("+n+")  is " + v + ", typed :"+ value+"<br/>");
	}
	
	/**
	 * From string (web param) to typed value.
	 * This method is in charge of cleaning the input which may be unsafe ( triming, escaping ...)
	 */
	public function getTypedValue(str:String):T{
		throw "getTypedValue() function not implemented in \""+name+"\"";
	}

	public function getErrors():List<String>
	{
		isValid();

		for (val in validators)
			for(err in val.errors)
				errors.add("<span class=\"formErrorsField\">" + label + "</span> : " + err);

		return errors;
	}

	/**
	 * Render the element in HTML
	 */
	public function render():String
	{
		if (!inited) init();
		return Std.string(value);
	}

	public function remove():Bool
	{
		if ( parentForm!= null ){
			return parentForm.removeElement(this);
		}
		return false;
	}

	/**
	 * renders the element with label+tr+td...
	 */
	public function getFullRow():String {
		var s = new StringBuf();
		if(Form.USE_TWITTER_BOOTSTRAP) s.add('<div class="form-group">\n');
		s.add(getLabel());
		s.add("<div class='col-sm-8'>" + this.render() + "</div>");
		if (Form.USE_TWITTER_BOOTSTRAP) s.add('</div>\n');
		return s.toString();
	}

	public function getType():String
	{
		return Std.string(Type.getClass(this));
	}

	/**
	 * Get CSS classes for the form element label
	 */
	public function getLabelClasses() : String
	{
		var css = "";
		if (Form.USE_TWITTER_BOOTSTRAP) css = "col-sm-4 control-label";
		
		var requiredSet = false;
		if (required) {
			css += " "+parentForm.requiredClass;
			if (parentForm.isSubmitted() && required && value == null) {
				css += " "+parentForm.requiredErrorClass;
				requiredSet = true;
			}
		}
		if(!requiredSet && parentForm.isSubmitted() && !isValid()){
			css += " "+parentForm.invalidErrorClass;
		}

		//if ( cssClass != null )
			//css += ( css == "" ) ? cssClass : " " + cssClass;

		return css;
	}

	public function getLabel():String
	{
		var n = parentForm.name + "_" + name;
		return "<label for=\"" + n + "\" class=\""+getLabelClasses()+"\" id=\"" + n + "__Label\">" + label +(required?parentForm.labelRequiredIndicator:'') +"</label>";
	}
	
	/**
	 * Return CSS classes of the element
	 */
	public function getClasses() : String
	{
		var css = ( cssClass != null ) ? cssClass : parentForm.defaultClass;

		if ( required && parentForm.isSubmitted() )
		{
			if ( value == null )
				css += " " + parentForm.requiredErrorClass;
			if ( !isValid() )
				css += " " + parentForm.invalidErrorClass;
		}
		if(css == null) css = "";
		return css.trim();
	}

	public function getErrorClasses()
	{
		var css = "";

		if ( required && parentForm.isSubmitted() )
		{
			if ( value == null )
				css += " " + parentForm.requiredErrorClass;
			if ( !isValid() )
				css += " " + parentForm.invalidErrorClass;
		}

		return css.trim();
	}

	private inline function safeString(s:Dynamic) {
		return s == null ? "" : Std.string(s).htmlEscape().split('"').join("&quot;");
	}
	
	/**
	 * Renders the element in HTML
	 */
	public function toString() :String
	{
		return render();
	}
	
	/**
	 * get element value with the correct type
	 */
	public function getValue():T{
		return value;
	}
}
