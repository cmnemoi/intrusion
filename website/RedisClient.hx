import js.lib.Promise;

class RedisClient {
	static var client:Redis = null;

	static private function connect() {
		if (client == null) {
			client = Redis.createClient("redis://localhost");
		}
	}

	static public function setWithTimeout(key:String, value:String, timeout_sec:Int):Promise<Bool> {
		return set(key, value).then(function(v) {
			client.expire(key, timeout_sec);
			return v;
		});
	}

	static public function keys(pattern:String):Promise<Array<String>> {
		return new Promise(function(resolve, reject) {
			connect();
			client.keys(pattern, function(err, keys) {
				if (err != null) {
					trace("Error listing keys: " + err);
				}

				resolve(keys);
			});
		});
	}

	static public function set(key:String, value:String):Promise<Bool> {
		return new Promise(function(resolve, reject) {
			connect();
			client.set(key, value, function(err) {
				resolve(err == null);
			});
		});
	}

	static public function del(key:String):Promise<Bool> {
		return new Promise(function(resolve, reject) {
			connect();
			client.del(key, function(err) {
				resolve(err == null);
			});
		});
	}

	static public function get(key:String):Promise<String> {
		return new Promise(function(resolve, reject) {
			connect();
			client.get(key, function(err, reply) {
				if (err != null) {
					reject(err);
				} else {
					resolve(reply);
				}
			});
		});
	}
}
