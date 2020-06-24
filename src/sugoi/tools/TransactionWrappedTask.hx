package sugoi.tools;

/**
	Wrap actions in a MySQL InnoDB transaction.
**/
class TransactionWrappedTask{

	var func:Void->Void;
	var name:String;
	var printLog:Bool;
	var startTime:Float;
	var _log:Array<String>;
	/**
		instanciate with function to execute
	**/
	public function new(?_name,?_func){
		func = _func;
		name = _name;
		printLog = true;
		_log = [];
	}

	public function setTask(_func){
		func = _func;
	}

	public function log(str:String){
		_log.push(str);
	}

	public function warning(str:String){
		_log.push('<span style="color:#600;font-weight:bold;">$str</span>');
	}

	public function title(str:String){
		_log.push('<h3>$str</h3>');
	}

	public function execute(?noException=false){
		log('<h2>$name</h2>');
		startTime = Date.now().getTime()/1000;

		sys.db.Manager.cnx.startTransaction();
		
		if(noException){
			//The task will fail silently
			try{
				func();
			}catch(e:tink.core.Error){
				var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
				warning(e.message);
				App.current.logError(e, stack);
			}catch(e:Dynamic){
				var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
				warning(Std.string(e));
				App.current.logError(e, stack);
			}
		}else{
			func();
		}
		sys.db.Manager.cnx.commit();


		var sec = Date.now().getTime()/1000 - startTime;
		log('Task took ${Math.round(sec*100)/100} seconds');
		

		if(printLog){
			Sys.println('<div style="padding:8px;margin:8px;background-color:#DDD;font-family: monospace;">');
			for( l in _log) Sys.println('$l<br/>');
			Sys.println('</div>');
		}
	}











}