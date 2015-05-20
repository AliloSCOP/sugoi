package sugoi.helper;

/**
 * Simple class to print a HTML table
 *
 * @author fbarbut
 *
 * It should be able to print a lot of structures :
 * - a spod request result
 * - arrays, lists
 * - anonymous objects
 *
 * usage :
 * var t = new Table();
 * t.title = "the table";
 * t.setContent( [{toto:1,tata:2},{toto:4,tata:7}] );
 * neko.Lib.print( t.toString(); );
 **/
class Table{
	
	//table content
	public var title : String;
	public var head : Array<String>;
	public var content : Array<Array<Dynamic>>;
	
	//table CSS class
	public var tableCSSClass : String;
	
	
	public function new(?defaultCss:String) {
		
		if(defaultCss != null) tableCSSClass = defaultCss;
	
	}
	
	public function toString(?param:Dynamic):String {
		if(param != null) {
			setContent(param);
			return go();
		}else {
			return "null";
		}
		
		
	}
	
	public function go():String {
		var output = "";
		output += "<table " + (tableCSSClass != null?"class=\"" + tableCSSClass + "\"":"") +">";
		
		if (title != null) {
			var length = 0;
			for(row in content) {
				for(cell in row) {
					length++;
				}
				break;
			}
			
			//alors là je comprends pas du tout du tout du tout pourquoi content[0].length ne marche pas...
			//output += content[0]+ "  "+Type.getClass(content[0])+"   "+content[0].length ;
			output += "<tr><th colspan='"+length+"'>" + title + "</th></tr>";
		}
		
		
		if (head != null) {
			output += "<tr>";
			for ( cell in head ) {
				output += "<th>" + cell + "</th>";
			}
			output += "</tr>";
		}
		
		for (row in content) {
			output += "<tr>";
			for (cell in row) {
				output += "<td>"+cell+"</td>";
			}
			output += "</tr>";
		}
		output += "</table>";
		return output;
	}
	

	/**
	 * Iterable -> Array
	 */
	function fromIterableToArray<T>(iterable) {
		var out = [];
		var iterable : Iterable<T> = cast iterable;
		for (el in iterable) {
			out.push(el);
		}
		return out;
	}
	
	/**
	 * Reflectable -> Array
	 */
	function fromReflectableToArray<T>(reflectable) {
		var out = [];
		//get fields
		for (field in Reflect.fields(reflectable) ) {
			if(!Reflect.isFunction(Reflect.field(reflectable,field)) && field!="__cache__" && field!="__lock")
				out.push(Reflect.field(reflectable,field));
		}
		return out;
		
	}
	
	public function toArray<T>(c:Dynamic) {
		if (c.iterator!=null) { //Reflect.hasField(c, "iterator")
			//trace("fromIterableToArray "+c);
			return fromIterableToArray(c);
		}else {
			//trace("fromReflectableToArray "+c);
			return fromReflectableToArray(c);
		}
	}
	
	public function setContent<T>(c:Dynamic) {
		//header
		head = [];
		
		//content
		content = [];
		var row = [];
		
		//on essaye de voir si il y a une deuxieme dimension au tableau (ex : liste d'objets )
		try{
			for (obj in toArray(c) ) {
				row = [];
					for (prop in toArray(obj)) {
						//get header
						if(head.length==0){
							for (prop in Reflect.fields(obj)) {
								//if the field is not a function, lets add it :
								if(!Reflect.isFunction(Reflect.field(obj,prop)) && prop!="__cache__")
									head.push(prop);
							}
						}
						row.push(prop);
					}
				content.push(row);
			}
		}catch(e :Dynamic) {
			content = [];
			head = ["field","value"];
			//a priori c'est un objet simple pas une liste , donc on liste ses propriétés
			for (field in Reflect.fields(c) ) {
				var row = [];
				if(!Reflect.isFunction(Reflect.field(c, field)) && field != "__cache__" && field != "__lock") {
					row.push(field);
					row.push(Reflect.field(c, field));
				}
				content.push(row);
			}

		}
		return content;
	}
	
	
}

