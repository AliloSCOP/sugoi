package sugoi.tools;

/**
	Wrap actions in a MySQL InnoDB transaction.
**/
class TransactionWrappedTask{

	var func:Void->Void;

	/**
		instanciate with function to execute
	**/
	public function new(_func){
		func = _func;
	}

	public function execute(?noException=false){
		sys.db.Manager.cnx.startTransaction();
		
		if(noException){
			//The task will fail silently
			try{
				func();
			}catch(e:Dynamic){
				var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
				App.current.logError(e, stack);
			}
		}else{
			func();
		}
		sys.db.Manager.cnx.commit();
	}











}