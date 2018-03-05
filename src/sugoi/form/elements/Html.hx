package sugoi.form.elements;

/**
 * Use this to fill some custom HTML between form elements
 * 
 * @author fbarbut<francois.barbut@gmail.com>
 */
class Html extends sugoi.form.FormElement<String>
{
	var html : String;
	
	public function new(name:String,html:String,?label="") 
	{
		this.name = name;
		this.html = html;
		this.label = label;		
		super();
	}
	
	override public function render()
	{
		return html;
	}
	
	override public function getTypedValue(str:String):String 
	{
		return null;
	}
	
}