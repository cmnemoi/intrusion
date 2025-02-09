package routes;

import Express;
import jsasync.IJSAsync;

class Storage implements IJSAsync {
    public static function create() {
        var router = new ExpressRouter();
		router.get("/", storage);
		router.post("/sellPack", sellPack);
        return router;
    }

	@:jsasync static function storage(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var tab = req.query.tab ?? "packs";
		var player: PlayerInfo = req.locals.player;
		var quota = 20;
		var packs = [];
		for (v in player.valuables.keyValueIterator()) {
			if (v.value <= 0)
				continue;
			var valuable = ValuablesXml.ALL.get(v.key);
			packs.push({
				id: v.key,
				name: valuable.name,
				price: valuable.price,
				count: v.value,
				sellCount: Math.min(v.value, quota),
			});
		}
		App.renderContent(req, res, App.getTemplate('storage.html').execute({tab: tab, quota: quota, packs: packs}));
	}

	@:jsasync static function sellPack(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var id = req.body.id;
		var available = player.valuables.get(id);
		var selling = Std.parseInt(req.body.count);
		var sold =  selling > available ? available : selling;
		player.valuables.set(id, available - sold);
		
		var valuable = ValuablesXml.ALL.get(id);
		player.money += sold * valuable.price;
		player.persist();

		res.redirect("/storage?tab=packs");
	}
}
