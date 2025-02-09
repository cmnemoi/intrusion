@:jsRequire("redis")
extern class Redis {
	static public function createClient(url:String):Redis;

	public function get(key:String, cb:String->String->Void):Void;
	public function set(id:String, data:String, cb:String->Void):Void;
	public function expire(id:String, timeout:Int):Void;
	public function del(id:String, cb:String->Void):Void;
	public function keys(id:String, cb:String->Array<String>->Void):Void;
}
