package routes;

import Express;
import haxe.Json;
import jsasync.IJSAsync;

using jsasync.JSAsyncTools;

class Decks implements IJSAsync {
	static var ADD_DECK_COST = [
		0,	// deck 1
		2500,	// deck 2
		4500,	// deck 3
		9500,	// deck 4
	];
	static var ADD_SLOT_COST = [
		0,	// slot 1
		0,	// slot 2
		0,	// slot 3
		2500,	// slot 4
		4500,	// slot 5
		8000,	// slot 6
		14000, // slot 7
		24500, // slot 8
	];

    public static function create() {
        var router = new ExpressRouter();
        router.get("/", decks);
		router.post("/", saveDeck);
		router.post("/setActiveChipset", setActiveChipset);
        return router;
    }

	@:jsasync static function decks(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		// TODO: decks can also be upgraded: https://youtu.be/nzoTSSlAOUM?t=1058 for 75000
		var player: PlayerInfo = req.locals.player;
		var chipsets = [{
			id: "none",
			icon: "delete",
			active: player.activeChipset == "none" ? "active" : "",
			name: "Aucun",
		}];

		chipsets = chipsets.concat([for (c in player.chipsets) {
			id: ChipsetsXml.ALL.get(c).id,
			icon: "chip",
			active: player.activeChipset == c ? "active" : "",
			name: ChipsetsXml.ALL.get(c).name,
		}]);

		var rank = 1;
		var decks = player.decks.map(d -> {
			slots: [for (i in 1...(d.capacity+1)){
				rank: i,
			}],
			viruses: d.content.map(v -> {
				id: v,
				rank: rank++,
			}),
			name: d.name,
			expandCost: deckExpandCost(d.capacity),
			money: player.money,
		});

		var usedVirus = decks[0].viruses.map(v -> v.id);

		var content = {
			chipsets: chipsets,
			decks: decks,
			availableViruses: player.viruses.filter(v -> !usedVirus.contains(v)).map(v -> {
				id: v,
			}),
			deckCapacity: player.decks[0].capacity,
		}
		App.renderContent(req, res, App.getTemplate('deck.html').execute(content));
	}

	@:jsasync static function saveDeck(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		if (req.query.expand != null) {
			var cost = deckExpandCost(player.decks[0].capacity);
			if (cost <= player.money) {
				player.decks[0].capacity +=1;
				player.money -= cost;
				player.persist();
			}
			res.redirect('/decks');
			return;
		}

		player.activeChipset = req.body.activeChipset;
		
		var decks: Array<{name: String, content: Array<String>}> = cast Json.parse(req.body.decks);
		// TODO: update all decks.
		player.decks[0].name = decks[0].name;
		player.decks[0].content = decks[0].content;
		player.persist();
		res.redirect('/decks');
	}
	
	@:jsasync static function setActiveChipset(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		player.activeChipset = req.body.id;
		player.persist();
		res.redirect('/decks');
	}

	public static function deckExpandCost(currentSize: Int) {
		return (currentSize >= 8)  ? 999999 : ADD_SLOT_COST[currentSize + 1];
	}
}