package routes;

import Express;
import haxe.Json;
import jsasync.IJSAsync;

using jsasync.JSAsyncTools;

class Store implements IJSAsync {

    public static function create() {
        var router = new ExpressRouter();
		router.get("/", store);
		router.post("/", buy);
        return router;
    }

    @:jsasync static function store(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
        var player: PlayerInfo = req.locals.player;
		var tab = req.query.tab ?? "home";
		App.renderContent(req, res, App.getTemplate('store.html').execute(getContent(player, tab)));
	}

    @:jsasync static function buy(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {	
		var player: PlayerInfo = req.locals.player;
		if (req.body.virusId != null) {
			if (player.viruses.contains(req.body.virusId)) {
				res.redirect('/store?tab=' + req.query.tab);
				return;
			}
			var virus = VirusXml.ALL.get(req.body.virusId);
			player.money -= virus.price;
			player.viruses.push(virus.id);
		}
		if (req.body.chipsetId != null) {
			if (player.chipsets.contains(req.body.chipsetId)) {
				res.redirect('/store?tab=' + req.query.tab);
				return;
			}
			var chipset = ChipsetsXml.ALL.get(req.body.chipsetId);
			player.money -= chipset.price;
			player.chipsets.push(chipset.id);
		}
		
		player.persist();
		req.locals.player = player;
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
