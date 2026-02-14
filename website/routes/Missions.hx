package routes;

import Protocol;
import MissionGen;

import Express;
import haxe.Serializer;
import haxe.Unserializer;
import jsasync.IJSAsync;

using jsasync.JSAsyncTools;

class Missions implements IJSAsync {
    static var MISSION_EXPIRATION_HOURS : Int = 24;
    static var ASSET_ROOT               : String = "/";
    static var fsNames                  : data.TextXml = null;
    static var texts                    : data.TextXml = null;
    static var names                    : data.TextXml = null;


    public static function create(lang: String) {
        init(lang);
        var router = new ExpressRouter();
        router.get("/", App.withAsyncErrorHandler(missions));
		router.get('/:missionId/details', App.withAsyncErrorHandler(details));
        router.get("/:missionId/start", App.withAsyncErrorHandler(start));
        router.post("/:missionId/end", App.withAsyncErrorHandler(end));
        return router;
    }

    private static function init(lang: String) {
        if (fsNames!=null) return;
        var fl_adult = true;
        fsNames = new data.TextXml(0, haxe.Resource.getString("xml_fsNames_"+lang), "xml_fsNames", fl_adult);
        texts = new data.TextXml(0, haxe.Resource.getString("xml_texts_"+lang), "xml_texts", fl_adult);
        names = new data.TextXml(0, haxe.Resource.getString("xml_names_"+lang), "xml_names", fl_adult);
        fsNames.fl_underscoreRep = true;
        texts.fl_autoCaps = true;
    }

	@:jsasync static function missions(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
        var player: PlayerInfo = req.locals.player;
		var tab = req.query.tab ?? "available";

		var ongoing = [for (m in player.activeMissions) toMissionData(player, m)];
        var available = getAvailableMissions(player).jsawait();
        var level = Math.ceil(Math.min(player.level(), 3));
        var tutorial = [for (l in 1...level+1) generateOffer(l)];
        var completed = [for (m in player.completedMissions) toMissionData(player, m)];

		App.renderContent(req, res, App.getTemplate('missions.html').execute(
			{
				tab: tab,
				numOngoing: ongoing.length,
				ongoing: ongoing,
				available: available,
				tutorial: tutorial,
				completed: completed,
			}
		));
	}
    
	@:jsasync static function details(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var missionId = Std.parseInt(req.params.missionId);
		var mission = getAvailableMission(player, missionId).jsawait();
		
		var availableChipsets = [for (chipset in player.chipsets) {
			id: chipset,
			name: ChipsetsXml.ALL.get(chipset).name,
		}];

		var viruses = player.decks[0].content.map(v -> {id: v});

		var content = {
			missionId: missionId,
			difficulty: mission.difficulty,
			short: mission.short,
			level: mission.level,
			date: mission.expireTs.toString(),
			desc: mission.details,
			prime: mission.value,
			chipsetName: player.activeChipset ?? "Aucun",
			selectChipset: availableChipsets.length > 0 ? "" : "hidden",
			availableChipsets: availableChipsets,
			viruses: viruses}

		App.renderContent(req, res, App.getTemplate('details.html').execute(content));
	  }

	@:jsasync static function start(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var missionId = Std.parseInt(req.params.missionId);
		var player: PlayerInfo = req.locals.player;

		var mission = null;
		for (m in player.availableMissions) {
			if (m.id() == missionId) {
				mission = m;
			}
		}
		if (mission != null) {
			player.availableMissions = player.availableMissions.filter((m) -> m.id() != missionId);
			player.activeMissions.push(mission);
			player.persist();
		}
		App.renderContent(req, res, App.getTemplate('start.html').execute({init: getStartData(player, missionId)}));
	}
    
	@:jsasync static function end(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var player: PlayerInfo = req.locals.player;
		var missionId = Std.parseInt(req.params.missionId);

		var msg = new Unserializer(req.body.msg).unserialize();
		switch (msg) {
			case MISSION_RESULT(end):							
				var mission = null;
				for (m in player.activeMissions) {
					if (m.id() == missionId) {
						mission = m;
					}
				}
				if (mission != null) {
					if (end._success) {
						player.activeMissions = player.activeMissions.filter((m) -> m.id() != missionId);
						player.completedMissions.push(mission);
						incrementStats(end, player);
						req.locals.player = player;
						player.persist();
					}
				}

                var goals = [for (goal in end._goals) {
                    desc: Goal.description(goal._gid),
                    value: goal._n,
                }];
                var extracted = [for (valuable in end._valuables) ValuablesXml.get.getValuable(valuable)];
                var copied = [for (file in end._storage) file];
                var end_content = {
                    status: end._success ? "headerSuccess" : "headerFailure",
                    success: end._success ? "" : "hidden",
                    failure: end._success ? "hidden" : "",
                    missionId: missionId,
                    prime: end._init._m._prime,
                    goals: goals,
                    extracted: extracted.map(e -> {
                        desc: e.name,
                    }),
                    copied: copied,
                }

				App.renderContent(req, res, App.getTemplate('end.html').execute(end_content));

			case _:
				throw "Wrong end message received: " + msg;
		}
	}

    @:jsasync private static function getAvailableMission(player: PlayerInfo, missionId: Int) {
        for (m in getAvailableMissions(player).jsawait())
            if (m.missionId == missionId)
                return m;
        throw 'Mission is not available: $missionId';
    }


    @:jsasync private static function getAvailableMissions(player: PlayerInfo) {
		var missions = player.availableMissions.filter((m) -> Date.now().getTime() - m.createdTs.getTime() <= MISSION_EXPIRATION_HOURS * 60 * 60 * 1000);
		if (missions.length == 0) {
			if (player.level() < 4) {
				var mdata = generateData(player.level(), Std.random(9999999));
				missions.push({
					seed: mdata._seed,
					level: mdata._gl,
					prime: mdata._prime,
					createdTs: Date.now(),
				});
			} else {
				for (i in 0...9) {
					var level = player.level() + Std.random(3) - 1;
					var gameLevel = cast(Math.max(4, level), Int);
					var mdata = generateData(gameLevel, Std.random(9999999));
					missions.push({
						seed: mdata._seed,
						level: mdata._gl,
						prime: mdata._prime,
						createdTs: Date.now(),
					});
				}

			}
			player.availableMissions = missions;
			player.persist();
		}
		return [for (m in missions) toMissionData(player, m)];
	}

    private static function getStartData(player: PlayerInfo, missionId: Int) {
        var seed = Math.floor(missionId / 1000);
        var gameLevel = missionId % 10;
        var mission = generateData(gameLevel, seed);

		var serializer = new Serializer();
		serializer.serialize(pinit(player, missionId, gameLevel, seed, mission));
		return serializer.toString();
    }

    
    private static function getDecks(player: PlayerInfo): List<{_name:String, _content:Array<String>}> {
        var decks = new List();
        decks.push({
            _name: player.decks[0].name,
            _content: player.decks[0].content,
        });
        return decks;
    }

    private static function getChipset(player: PlayerInfo): String {
        return player.activeChipset == "none" ? null : player.activeChipset;
    }

    private static function pinit(player: PlayerInfo, missionId: Int, level: Int, seed: Int, mission: MissionData): PInit {
        return {
            _sfxVer		: 1,
            _musicVer	: 2,
            _startUrl	: "",
            _endUrl		: "/missions/" + missionId + "/end",
            _errorUrl	: "",
            _iconsUrl	: ASSET_ROOT + "img/dockicons/",
            _iconsVer	: 1,
            _sfxUrl		: ASSET_ROOT + "sfx/",
            _seed		: seed,
            _gl			: level,
            _m			: mission,
            _decks		: getDecks(player),
            _chip		: getChipset(player),
            _c			: false,
            _bios		: 1,
            _profile	: {
                _uname		: "Haxxor",
                _low		: false,
                _adult		: true,
                _ulevel		: 4,
                _leet		: false,
                _cfg		: "
                    alias d=avdmg1
                    alias    up = cd ..
                ",
                _sfx		: true,
                _ambiant	: true,
                _beat		: true,
            }
        };
    }


    
    private static function incrementStats(end: PEnd, player: PlayerInfo) {
        if (end._success) {
            end._goals.add({_gid: MissionsFulfilled, _n: 1});
            // TODO: also collect success on first try

            for (goal in end._goals) {
                var value = goal._n + (player.goals.get(goal._gid) ?? 0);
                player.goals.set(goal._gid, value);
            }


            for (valuable in end._valuables) {
                var number = 1 + (player.valuables.get(valuable) ?? 0);
                player.valuables.set(valuable, number);
            }
            for (copied in end._storage) {
                // TODO
            }

            player.money += end._init._m._prime;
            player.xp += end._init._m._xp;
        }
    }

    private static function toMissionData(player: PlayerInfo, mission: Mission) {
		var mdata = generateData(mission.level, mission.seed);
		return {
			short: mdata._short,
			details: mdata._details,
			level: mdata._gl,
			value: mdata._prime,
			difficulty: difficulty(mdata._gl, player.level()),
			missionId: mdata._seed * 1000 + mdata._gl,
			expireTs: DateTools.delta(mission.createdTs, 24 * 3600 * 1000),
		}
	}

    public static function difficulty(missionLevel: Int, playerLevel: Int): String {
		if (missionLevel == playerLevel) {
			return "medium";
		} else if (missionLevel < playerLevel) {
			return "easy";
		} else {
			return "hard";
		}
	}

    private static function generateOffer(gameLevel: Int) {
		var mdata = generateData(gameLevel, Std.random(9999999));
        return {short: mdata._short, value: mdata._prime, difficulty: difficulty(mdata._gl, gameLevel), missionId: mdata._seed * 1000 + gameLevel};
    }

	private static function generateData(gameLevel: Int, seed): MissionData {
		var mg = new MissionGen(texts, fsNames, names);
		return mg.generate(gameLevel, seed);
	}
}
