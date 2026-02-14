package routes;

import Express;
import commands.BuyDeck;
import commands.RenameDeck;
import commands.UpgradeDeck;
import haxe.Json;
import jsasync.IJSAsync;

using jsasync.JSAsyncTools;

class Decks implements IJSAsync {
    public static function create() {
        var router = new ExpressRouter();
        router.get("/", App.withAsyncErrorHandler(decks));
		router.get("/:deckId", App.withAsyncErrorHandler(decks));
		router.post("/:deckId/buy", App.withAsyncErrorHandler(buyDeck));
		router.post("/buy", App.withAsyncErrorHandler(buyDeck));
		router.post("/:deckId/upgrade", App.withAsyncErrorHandler(upgradeDeck));
		router.post("/upgrade", App.withAsyncErrorHandler(upgradeDeck));
		router.post("/:deckId/rename", App.withAsyncErrorHandler(renameDeck));
		router.post("/rename", App.withAsyncErrorHandler(renameDeck));
		router.post("/:deckId/setActiveChipset", App.withAsyncErrorHandler(setActiveChipset));
		router.post("/setActiveChipset", App.withAsyncErrorHandler(setActiveChipset));
		router.post("/:deckId", App.withAsyncErrorHandler(saveDeck));
		router.post("/", App.withAsyncErrorHandler(saveDeck));
        return router;
    }

	@:jsasync static function decks(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var activeDeckIndex = requestedDeckIndexFromRequest(req, player.decks.length);
		var activeDeck = player.decks[activeDeckIndex];

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

		var decks = [for (i in 0...player.decks.length) {
			{
				index: i,
				name: player.decks[i].name,
				active: i == activeDeckIndex ? "active" : "",
			}
		}];

		var usedVirus = activeDeck.content;
		var nextDeckCost = BuyDeck.nextDeckCost(player.decks.length);

		var content = {
			chipsets: chipsets,
			decks: decks,
			activeDeckIndex: activeDeckIndex,
			activeDeckName: activeDeck.name,
			activeDeckSlots: [for (slotIndex in 1...(activeDeck.capacity + 1)) {
				rank: slotIndex,
			}],
			activeDeckViruses: activeDeck.content.map(v -> {
				id: v,
			}),
			activeDeckExpandCost: UpgradeDeck.nextUpgradeCost(activeDeck.capacity),
			availableViruses: availableVirusIds(player.viruses, usedVirus).map(v -> {
				id: v,
			}),
			deckCapacity: activeDeck.capacity,
			buyDeckCost: nextDeckCost,
			canBuyDeck: player.money >= nextDeckCost,
			money: player.money,
		}
		App.renderContent(req, res, App.getTemplate('deck.html').execute(content));
	}

	@:jsasync static function saveDeck(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var deckIndex = requestedDeckIndexFromRequest(req, player.decks.length);

		player.activeChipset = req.body.activeChipset;
		
		var decks: Array<{name: String, content: Array<String>}> = cast Json.parse(req.body.decks);
		if (decks != null && decks.length > 0)
			player.decks[deckIndex].content = decks[0].content;
		player.persist();
		res.redirect(deckPath(deckIndex));
	}

	@:jsasync static function buyDeck(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var previousDeckIndex = requestedDeckIndexFromRequest(req, player.decks.length);
		if (BuyDeck.execute(player)) {
			player.persist();
			res.redirect(deckPath(player.decks.length - 1));
			return;
		}
		res.redirect(deckPath(previousDeckIndex));
	}

	@:jsasync static function upgradeDeck(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var deckIndex = requestedDeckIndexFromRequest(req, player.decks.length);

		if (UpgradeDeck.execute(player, deckIndex)) {
			player.persist();
		}
		res.redirect(deckPath(deckIndex));
	}

	@:jsasync static function renameDeck(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var deckIndex = requestedDeckIndexFromRequest(req, player.decks.length);

		if (RenameDeck.execute(player, deckIndex, req.body.name)) {
			player.persist();
		}
		res.redirect(deckPath(deckIndex));
	}
	
	@:jsasync static function setActiveChipset(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var deckIndex = requestedDeckIndexFromRequest(req, player.decks.length);
		player.activeChipset = req.body.id;
		player.persist();
		res.redirect(deckPath(deckIndex));
	}

	public static function normalizeDeckIndex(requestedDeckIndex:Null<Int>, deckCount:Int):Int {
		if (deckCount <= 0)
			return 0;

		if (requestedDeckIndex == null)
			return 0;

		if (requestedDeckIndex < 0 || requestedDeckIndex >= deckCount)
			return 0;

		return requestedDeckIndex;
	}

	public static function availableVirusIds(ownedVirusIds:Array<String>, usedVirusIds:Array<String>):Array<String> {
		var remainingVirusUsages = countViruses(usedVirusIds);
		var availableVirusIds = [];

		for (virusId in ownedVirusIds) {
			if (hasRemainingUsage(remainingVirusUsages, virusId)) {
				decrementUsage(remainingVirusUsages, virusId);
				continue;
			}
			availableVirusIds.push(virusId);
		}

		return availableVirusIds;
	}

	public static function requestedDeckIndexFromPath(requestedDeckId:Dynamic, deckCount:Int):Int {
		return normalizeDeckIndex(parseDeckIndex(requestedDeckId), deckCount);
	}

	public static function deckPath(deckIndex:Int):String {
		return '/decks/$deckIndex';
	}

	static function requestedDeckIndexFromRequest(req:ExpressRequest, deckCount:Int):Int {
		var fromPath = req.params == null ? null : req.params.deckId;
		if (fromPath != null)
			return requestedDeckIndexFromPath(fromPath, deckCount);

		var fromBody = req.body == null ? null : req.body.deckIndex;
		if (fromBody != null)
			return normalizeDeckIndex(parseDeckIndex(fromBody), deckCount);

		var fromQuery = req.query == null ? null : req.query.deck;
		return normalizeDeckIndex(parseDeckIndex(fromQuery), deckCount);
	}

	static function parseDeckIndex(rawValue:Dynamic):Null<Int> {
		if (rawValue == null)
			return null;

		return Std.parseInt(Std.string(rawValue));
	}

	static function countViruses(virusIds:Array<String>):Map<String, Int> {
		var virusCounts:Map<String, Int> = new Map();
		for (virusId in virusIds) {
			var count = virusCounts.get(virusId) ?? 0;
			virusCounts.set(virusId, count + 1);
		}
		return virusCounts;
	}

	static function hasRemainingUsage(remainingVirusUsages:Map<String, Int>, virusId:String):Bool {
		return (remainingVirusUsages.get(virusId) ?? 0) > 0;
	}

	static function decrementUsage(remainingVirusUsages:Map<String, Int>, virusId:String):Void {
		var remainingUsage = remainingVirusUsages.get(virusId) ?? 0;
		remainingVirusUsages.set(virusId, remainingUsage - 1);
	}
}
