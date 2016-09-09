package sugoi.i18n.translator;

/**
 * Text translation interface
 *
 * @author fbarbut
 */

interface ITranslator{
		
	/**
	 * Get translated text
	 *
	 * @param	t			Key to translate
	 * @param	?params		Params to inject in string
	 */
	public function _( t : String, ?params : Dynamic ):String;
	
	public function getStrings():Map<String,String>;
	
}