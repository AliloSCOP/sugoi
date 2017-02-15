package sugoi.form.filters;


interface IFilter<T> 
{

	public function filter(data:T):T;
	
	public function filterString(data:String):T;
}