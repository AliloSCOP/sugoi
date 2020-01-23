package sugoi.tools;

class ResultsBrowser<T> {

	public var page : Int;
	public var pages : Int;
	public var next : Int;
	public var prev : Int;
	public var size : Int;
	public var paginationVisiblePages : Int;

	var index : Int;
	var browse : Int -> Int -> Iterable<T>;
	var paginationStartPage : Int;
	var paginationEndPage : Int;


	public function new( count : Int, size : Int, browse : Int -> Int -> Iterable<T>, ?defpos, ?paginationVisiblePages = 10 ) {
		this.size = size;
		this.browse = browse;
		page = Std.parseInt(App.current.params.get("page"));
		if( page == null ) {
			if( defpos == null )
				page = 1;
			else
				page = Std.int(defpos()/size) + 1;
		}
		if( page < 1 )
			page = 1;
		prev = if( page > 1 ) page - 1 else null;
		if( count != null ) {
			pages = Math.ceil(count/size);
			if( pages == 0 )
				pages = 1;
		}
		next = if( pages == null || page < pages ) page + 1 else null;
		index = (page - 1) * size;

		//Pagination Logic
		this.paginationVisiblePages = paginationVisiblePages;
		paginationStartPage = (Math.ceil(page/paginationVisiblePages) - 1) * paginationVisiblePages + 1;
		paginationEndPage = paginationStartPage + paginationVisiblePages;
		if( paginationEndPage > pages + 1 ) {
			paginationEndPage = pages + 1;
		}
					
	}	

	public function current() {
		return browse((page-1)*size,size);
	}


}