package sugoi.form.elements;

/**
 * 
 * Use this to fill some custom HTML between your form elements
 * 
 * @author fbarbut<francois.barbut@gmail.com>
 */
class Html extends sugoi.form.FormElement<String>
{

	var html : String;
	
	public function new(html:String,?label="") 
	{
		this.html = html;
		this.label = label;
		this.name = Std.string(Std.random(999));
		super();
	}
	
	override public function render() {
		return html;
	}
	
	override public function getTypedValue(str:String):String 
	{
		return null;
	}
	
	
	
}