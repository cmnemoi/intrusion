package routes;

import Express;
import commands.BuyVirus;
import haxe.Json;
import jsasync.IJSAsync;

using jsasync.JSAsyncTools;

class Store implements IJSAsync {

    public static function create() {
        var router = new ExpressRouter();
		router.get("/", App.withAsyncErrorHandler(store));
		router.post("/", App.withAsyncErrorHandler(buy));
        return router;
    }

    @:jsasync static function store(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
        var player: PlayerInfo = req.locals.player;
		var tab = req.query.tab ?? "home";
		App.renderContent(req, res, App.getTemplate('store.html').execute(getContent(player, tab)));
	}

    @:jsasync static function buy(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {	
		var player: PlayerInfo = req.locals.player;
		var hasBoughtItem = false;
		if (req.body.virusId != null) {
			var virus = VirusXml.ALL.get(req.body.virusId);
			var virusPrice = virus == null ? null : virus.price;
			hasBoughtItem = BuyVirus.execute(player, req.body.virusId, virusPrice) || hasBoughtItem;
		}
		if (req.body.chipsetId != null) {
			if (!player.chipsets.contains(req.body.chipsetId)) {
				var chipset = ChipsetsXml.ALL.get(req.body.chipsetId);
				player.money -= chipset.price;
				player.chipsets.push(chipset.id);
				hasBoughtItem = true;
			}
		}

		if (hasBoughtItem) {
			player.persist();
			req.locals.player = player;
		}
		res.redirect('/store?tab=' + req.query.tab);
		return;
	}

    private static function getContent(player: PlayerInfo, tab: String) {
        var content = VirusXml.getCategorized(player.level());

        var chipsets = [for (c in ChipsetsXml.ALL) if (ChipsetsXml.isAvailable(c, player.level())) toChipsetOutput(player, c)];
        return {
            tab: tab,
            virus_dmg: getViruses(player, content, "damage"),
            virus_debuff: getViruses(player, content, "debuff"),
            virus_combo: getViruses(player, content, "combo"),
            virus_utils: getViruses(player, content, "utils"),
            chipsets: chipsets,
            money: player.money,
            playerLevel: player.level(),
        }
    }

    private static function getViruses(player: PlayerInfo, content: Hash<List<Virus>>, category: String) {
        var viruses = content.get(category) ?? new List();
        return  [for (v in viruses) toVirusOutput(player, v)];
    }

    private static function toVirusOutput(player: PlayerInfo, virus: Virus) {            
        return {
            id: virus.id,
            name: virus.name,
            cc: virus.cc,
            price: virus.price,
            bought: player.viruses.contains(virus.id),
            level: virus.level,
        }
    }

    private static function toChipsetOutput(player: PlayerInfo, chipset: ChipsetData) {
        return {
            id: chipset.id,
            name: chipset.name,
            desc: chipset.desc,
            level: chipset.level,
            price: chipset.price,
            bought: player.chipsets.contains(chipset.id),
        }
    }
}
