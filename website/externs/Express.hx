import haxe.extern.Rest;

typedef ExpressRequest = {
	var params:Dynamic<String>;
	var locals:Dynamic;
	var query:Dynamic;
	var path: String;
	var body:Dynamic<String>;
	var cookies:Dynamic<String>;

	var originalUrl:String;
	var baseUrl:String;
};

typedef ExpressResponse = {
	var locals:{
		@:optional var context:Dynamic;
		@:optional var template:String;
		@:optional var title:String;
		@:optional var redirect:String;
	};
	var set:Dynamic->Void;

	var end:?Dynamic->Void;
	var redirect:String->Void;
};

typedef ExpressCB = ExpressRequest->ExpressResponse->(?Dynamic->Void)->Void;
typedef ExpressErrorCB = Dynamic->ExpressRequest->ExpressResponse->(?Dynamic->Void)->Void;

@:jsRequire("cookie-parser")
extern class ExpressCookieParser {
	@:selfCall
	public function new():Void;
}

@:jsRequire("express")
extern class Express {
	@:selfCall
	public function new():Void;

	public function disable(what:String):Void;

	public function listen(port:Int, ?cb:Void->Void):Void;

	public function all(path:String, cb:Rest<ExpressCB>):Void;
	public function get(route:String, cb:Rest<ExpressCB>):Void;
	public function post(route:String, cb:Rest<ExpressCB>):Void;

	@:overload(function(cb:ExpressCookieParser):Void {})
	@:overload(function(cb:ExpressCB):Void {})
	@:overload(function(cb:ExpressErrorCB):Void {})
	@:overload(function(route:String, router:ExpressRouter):Void {})
	@:overload(function(route:String, cb:ExpressCB, router:ExpressRouter):Void {})
	public function use(route:String, cb:Rest<ExpressCB>):Void;

	static public function urlencoded(opts:Dynamic):Dynamic;

	@:native('static')
	static public function staticServe(path:String):Dynamic;
	static public function json():Dynamic;
}

@:jsRequire("express", "Router")
extern class ExpressRouter {
	public function new():Void;

	public function get(route:String, cb:Rest<ExpressCB>):Void;
	public function post(route:String, cb:Rest<ExpressCB>):Void;

	@:overload(function(cb:ExpressCB):Void {})
	public function use(route:String, cb:Rest<ExpressCB>):Void;
}
