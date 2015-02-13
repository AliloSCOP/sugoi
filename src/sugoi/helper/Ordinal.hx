package mt.net.helper;

/**
 * Ordinal number helper
 *
 * @author fbarbut
 **/
class Ordinal /*implements IHelper*/{
	
	public var lang : String;
	public static var AVAILABLE_LANGS = ['fr','en','es'];
	
	public function new(_lang:String) {
		
		lang = _lang.toLowerCase();
		if(!Lambda.has(AVAILABLE_LANGS, lang)) lang = 'en';
	}
	
	
	
	/**
	 * Get output, like "1st" or "2nd"
	 * @param	rank		number/rank starting from 1
	 * @param	?sex		1:male,2:female, 3: neutral (german)
	 * @param	?format		text format like "::rank::<span>::suffix::</span>"
	 */
	public function toString(rank:Int, ?sex:Int, ?format:String):String {
		var suffix = "";
		if(sex == null) sex = 1;
		
		
		switch(lang) {
			case "fr":
				if(rank == 1) {
					suffix = (sex==1)?"er":"ère";
				}else {
					suffix = "ème";
				}
				
			case "es":
				//http://reglasdeortografia.com/numerales.html
				suffix = (sex == 1)?"o":"a";
				
			case "de":
				switch(sex) {
					case 1 :
						suffix = "ter";
					case 2 :
						suffix = "te";
					default :
						suffix = "tes";
				}
				
			default:
				//"en":
				if(rank == 1) {
					suffix = "st";
				}else if(rank == 2) {
					suffix = "nd";
				}else if(rank == 3) {
					suffix = "rd";
				}else {
					suffix = "th";
				}
				
			/*DE
			 *
			 * Karsten :
				Hihi. Un peu compliqué pour l'Allemand comme les suffix/mots dépendend de nombre exacte. ...en plus il y un troisième sexe.
				Je propose tu utilise ce modèle qui fonctionne toujours: > X : X.

				Voici le modèle complète :

				> masculin:
				> X = 1 : Erster
				> X = 2 : Zweiter
				> X = 3 : Dritter
				> X =  4-19 : Xter
				> X =  20-1000 : Xster
				... + : Les derniers 3 chiffres décident de nouveau (comme indiqué anvant)
				p.ex. 232456 = Y[232]X[456]

				> neutre :
				> X = 1 : Erstes
				> X = 2 : Zweites
				> X = 3 : Drittes
				> X =  4-19 : Xtes
				> X =  20-1000 : Xstes
				... + : Les derniers 3 chiffres décident de nouveau (comme indiqué anvant)
				p.ex. 232456 = Y[232]X[456]

				> feminin :
				> X = 1 : Erste
				> X = 2 : Zweite
				> X = 3 : Dritte
				> X =  4-19 : Xte
				> X =  20-1000 : Xste
				... + : Les derniers 3 chiffres décident de nouveau (comme indiqué anvant)
				p.ex. 232456 = Y[232]X[456]>
			 * */
			
		}
		
		if(format != null) {
			format = StringTools.replace(format, "::rank::", Std.string(rank));
			format = StringTools.replace(format, "::suffix::", Std.string(suffix));
			return format;
		}else {
			return rank + suffix;
		}
	}
}

