package sugoi;

enum ControllerAction {
	RedirectAction( url : String );
	ErrorAction( url : String, ?text : String );
	OkAction( url : String, ?text : String );
}