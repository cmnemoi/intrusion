package model;

import jsasync.IJSAsync;
import js.lib.Promise;

using jsasync.JSAsyncTools;

typedef Deck = {
    var name: String;
    var capacity: Int;
    var content: Array<String>;
}

@:structInit class PlayerInfo implements IJSAsync {
    public var id: String;
    public var username: String;
    public var money: Int;
    public var xp: Int;
    public var viruses: Array<String>;
    public var chipsets: Array<String>;
    public var activeChipset: Null<String>;
    public var decks: Array<Deck>;
    public var goals: Map<Goal, Int>;
    public var valuables: Map<String, Int>;
    public var activeMissions: Array<Mission>;
    public var availableMissions: Array<Mission>;
    public var completedMissions: Array<Mission>;

    public function level(): Int {
        return MissionGen.getGameLevel(xp);
    }

	@:jsasync public function persist():Promise<Bool> {
		var key = 'intrusion:user:${id}';

        var writer = new json2object.JsonWriter<PlayerInfo>();
        var json = writer.write(this);
        return RedisClient.set(key, json).jsawait();
	}

    @:jsasync public static function load(id:Int):Promise<PlayerInfo> {
		var key = 'intrusion:user:$id';
        var json = RedisClient.get(key).jsawait();

        if (json == null)
			return null;
        
        var parser = new json2object.JsonParser<PlayerInfo>();
        parser.fromJson(json);
        if (parser.errors.length > 0)
            throw "Error parsing player information: " + parser.errors;

        return parser.value;
	}
    
    public static function createDefault(id: Int, username: String) {
        var startingViruses = VirusXml.getStartingViruses().map(v -> v.id);
        var player: PlayerInfo = {
            id: Std.string(id),
            username: username,
            xp: 3,
            money: 10000,
            viruses: startingViruses,
            chipsets: [],
            activeChipset: "none",
            decks: [{name: "Deck Principal", capacity: 3, content: startingViruses}],
            goals: new Map(),
            valuables: new Map(),
            activeMissions: new Array(),
            availableMissions: new Array(),
            completedMissions: new Array(),
        }
        return player;
    }
}