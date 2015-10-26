package sugoi.form;
#if neko
import neko.Web;
#else
import php.Web;
#end
import sugoi.form.filters.IFilter;
using StringTools;

class FormElement
{
	public var parentForm:Form;
	public var name:String;
	public var label:String;
	public var description:String;
	public var value:Dynamic;
	public var required:Bool;
	public var errors:List<String>;
	public var attributes:String;
	public var active:Bool;
	
	public var cssClass:String;
	public var inited:Bool;
	public var internal:Bool;
	
	public var validators:List<Validator>;
	public var filters:List<IFilter>;

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
	 * Return typed value of the element
	 * @return
	 */
	public function getTypedValue():Dynamic {
		return value;
	}

	public function isValid():Bool
	{
		errors.clear();

		if (!active) return true;

		if (value == "" && required || value == null && required) {
			//required field is empty
			errors.add("<span class=\"formErrorsField\">\"" + ((label != null && label != "") ? label : name) + "\"</span> ne doit pas être vide.");
			return false;
		}

		if (value != "" && value!=null) {
			//check validity
			if (!validators.isEmpty()){
				var pass:Bool = true;
				for (validator in validators)
				{
					if (!validator.isValid(value)) 	return false;
				}

			}

			return true;
		}
		return true;
	}

	public function checkValid(){
		value == "";
	}


	public function init(){
		inited = true;
	}

	public function addValidator(validator:Validator){
		validators.add(validator);
	}
	
	public function addFilter(filter:IFilter) {
		filters.add(filter);
	}

	public function populate():Void
	{
		if (!inited) init();

		var n = parentForm.name + "_" + name;
		var v = App.current.params.get(n);

		if (v != null) value = v;
	}

	public function getErrors():List<String>
	{
		isValid();

		for (val in validators)
			for(err in val.errors)
				errors.add("<span class=\"formErrorsField\">" + label + "</span> : " + err);

		return errors;
	}

	public function render():String
	{
		if (!inited) init();
		return value;
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

	public function getLabelClasses() : String
	{
		var css = "";
		if (Form.USE_TWITTER_BOOTSTRAP) css = "col-sm-4 control-label";
		
		var requiredSet = false;
		if (required) {
			css += " "+parentForm.requiredClass;
			if (parentForm.isSubmitted() && required && value == "") {
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

	public function getClasses() : String
	{
		var css = ( cssClass != null ) ? cssClass : parentForm.defaultClass;

		if ( required && parentForm.isSubmitted() )
		{
			if ( value == "" )
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
			if ( value == "" )
				css += " " + parentForm.requiredErrorClass;
			if ( !isValid() )
				css += " " + parentForm.invalidErrorClass;
		}

		return css.trim();
	}

	private inline function safeString(s:Dynamic) {
		return s == null ? "" : Std.string(s).htmlEscape().split('"').join("&quot;");
	}
}
