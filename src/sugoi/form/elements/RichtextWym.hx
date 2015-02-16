/*
 *	WYMEditor ( XHTML wysiwig editor )
 * 	http://files.wymeditor.org/wymeditor-1.0.0b2/examples/
 */
package form.elements;

import form.Form;
import form.FormElement;

class RichtextWym extends FormElement
{
	public var width:Float;
	public var height:Float;
	public var allowImages:Bool;
	public var allowTables:Bool;
	public var editorStyles:String;
	public var containersItems:String;
	public var classesItems:String;
	
	public function new(name:String, label:String, ?value:String, ?required:Bool=false, ?attibutes:String="")
	{
		super();
		this.name = name;
		this.label = label;
		this.value = value;
		this.required = required;
		this.attributes = attibutes;
		
		width = 500;
		height = 300;
		
		allowImages = true;
		allowTables = false;
		editorStyles = "";
		containersItems = "";
		classesItems = "";
	}
	
	override public function render():String
	{
		var n = form.name + "_" +name;
		
		editorStyles = StringTools.replace(editorStyles, "\n", " ");
		editorStyles = StringTools.replace(editorStyles, "\r", " ");
		
		var str:StringBuf = new StringBuf();
		str.add("\n <textarea name=\"" + n + "\" id=\"" + n + "\" >" + value + "</textarea>");
		str.add("<script type=\"text/javascript\">");
		str.add("jQuery(function() {");
		str.add("	jQuery('#" + n + "').wymeditor({");
		str.add("logoHtml: '',");
		//str.add("		stylesheet: './css/site.css',");
		str.add("editorStyles: [\""+editorStyles+"\"],");
		str.add("postInit: function(wym) {");
		str.add("	jQuery(wym._box).find(wym._options.containersSelector).removeClass('wym_dropdown').addClass('wym_panel').find('h2 > span').remove();");
		str.add("	jQuery(wym._box).find(wym._options.iframeSelector).css('height', '"+height+"px').css('width', '"+width+"px');");
		str.add("},");
		str.add("toolsItems: [");
		str.add("	{'name': 'Bold', 'title': 'Strong', 'css': 'wym_tools_strong'}, ");
		str.add("	{'name': 'Italic', 'title': 'Emphasis', 'css': 'wym_tools_emphasis'},");
		str.add("	{'name': 'CreateLink', 'title': 'Link', 'css': 'wym_tools_link'},");
		str.add("	{'name': 'Unlink', 'title': 'Unlink', 'css': 'wym_tools_unlink'},");
		if(allowImages) str.add("{'name': 'InsertImage', 'title': 'Image', 'css': 'wym_tools_image'},");
		str.add("	{'name': 'InsertOrderedList', 'title': 'Ordered_List', 'css': 'wym_tools_ordered_list'},");
		str.add("	{'name': 'InsertUnorderedList', 'title': 'Unordered_List', 'css': 'wym_tools_unordered_list'},");
		if(allowTables) str.add("{'name': 'InsertTable', 'title': 'Table', 'css': 'wym_tools_table'},");
		str.add("	{'name': 'Paste', 'title': 'Paste_From_Word', 'css': 'wym_tools_paste'},");
		str.add("	{'name': 'Undo', 'title': 'Undo', 'css': 'wym_tools_undo'},");
		str.add("	{'name': 'Redo', 'title': 'Redo', 'css': 'wym_tools_redo'},");
		str.add("	{'name': 'ToggleHtml', 'title': 'HTML', 'css': 'wym_tools_html'}");
		str.add("],");
		str.add("containersItems: [" + containersItems + "],");
		if (classesItems != "") {
			str.add("classesItems: [" + classesItems + "],");
		}else {
			str.add("classesHtml: '',");
		}
		str.add("postInitDialog: function (wym, wdw) { if(wymeditor_filebrowser != null) wymeditor_filebrowser(wym, wdw); }");
		str.add("	});");
		str.add("});");
		str.add("</script>");
		
		if (!isValid()) str.add(" required");
		
		return str.toString();
	}
	
	public function toString() :String
	{
		return render();
	}
}