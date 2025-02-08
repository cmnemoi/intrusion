package data;

typedef Valuable = {
	id		: String,
	price	: Int,
	name	: String,
	fl_rare	: Bool,
}

private abstract AllData(String -> Null<Valuable>) {
    public function new(get: String -> Null<Valuable>) {
		this = get;
	}

	@:resolve
	public function getValuable(key: String): Valuable {
		return this(key);
	}
}

class ValuablesXml {

	public static var ALL : Hash<Valuable> = new Hash();
	public static var get : AllData = null;
	#if neko
		static var autoRun = init("fr");
	#end

	public static function init(lang: String) {
		var raw = haxe.Resource.getString("xml_valuables_"+lang);
		var h : Hash<Valuable> = new Hash();
		var xml = Xml.parse(raw);
		var doc = new haxe.xml.Access( xml.firstElement() );
		for( node in doc.nodes.v ) {
			var id = node.att.id.toLowerCase();
			if( id == null )
				throw "Missing 'id' in valuables.xml";
			if( h.exists(id) )
				throw "Duplicate id '"+id+"' in valuables.xml";
			var data : Valuable = {
				id		: id,
				price	: Std.parseInt(node.att.v),
				name	: node.att.name,
				fl_rare	: node.has.rare && node.att.rare=="1",
			}
			h.set(id,data);
		}

		ALL = h;
		get = new AllData(ALL.get);
	}

	public static function getList() {
		var list = new List();
		for (k in ALL.keys())
			list.add(ALL.get(k));
		return list;
	}

	public static function getByValue(money:Int) {
		for (k in ALL.keys())
			if ( ALL.get(k).price==money )
				return ALL.get(k);
		return null;
	}

	public static function getValues() {
		var list = new Array();
		for (k in ALL.keys())
			list.push( ALL.get(k).price );
		return list;
	}

}
