package tests.routes;

import MissionGen;
import model.PlayerInfo;
import routes.Missions;
import utest.Assert;
import utest.Test;

class MissionsUberEleetTest extends Test {
	/** @spec missions.uber-eleet.player-preference::default-disabled */
	function testShouldDisableUberEleetForNewPlayer() {
		var player = PlayerInfo.createDefault(1, "Haxxor");

		Assert.isFalse(player.uberEleet);
	}

	/** @spec missions.uber-eleet.player-preference::legacy-default-disabled */
	function testShouldLoadLegacyPlayerWithoutUberEleet() {
		var parser = new json2object.JsonParser<PlayerInfo>();
		parser.fromJson(givenLegacyPlayerJson());

		Assert.equals(0, parser.errors.length);
		Assert.isFalse(parser.value.uberEleet);
	}

	/** @spec missions.uber-eleet.player-preference::persisted */
	function testShouldEnableUberEleetWhenLaunchFormIsChecked() {
		Assert.isTrue(Missions.uberEleetPreference({saveUberEleet: "1", uberEleet: "1"}, false));
	}

	/** @spec missions.uber-eleet.player-preference::persisted */
	function testShouldDisableUberEleetWhenLaunchFormIsUnchecked() {
		Assert.isFalse(Missions.uberEleetPreference({saveUberEleet: "1"}, true));
	}

	/** @spec missions.uber-eleet.player-preference::persisted */
	function testShouldKeepUberEleetPreferenceWhenNoLaunchFormExists() {
		Assert.isTrue(Missions.uberEleetPreference({}, true));
		Assert.isFalse(Missions.uberEleetPreference(null, false));
	}

	/** @spec missions.uber-eleet.mission-start::profile-flag */
	function testShouldPassEnabledPreferenceToMissionProfile() {
		var player = givenPlayer(true);

		Assert.isTrue(Missions.pinit(player, 1001, 1, 1, givenMission())._profile._leet);
	}

	/** @spec missions.uber-eleet.mission-start::profile-flag */
	function testShouldPassDisabledPreferenceToMissionProfile() {
		var player = givenPlayer(false);

		Assert.isFalse(Missions.pinit(player, 1001, 1, 1, givenMission())._profile._leet);
	}

	private function givenLegacyPlayerJson():String {
		return '{"id":"1","username":"Haxxor","money":0,"xp":0,"viruses":[],"chipsets":[],"activeChipset":"none","decks":[],"goals":{},"valuables":{},"activeMissions":[],"availableMissions":[],"completedMissions":[]}';
	}

	private function givenPlayer(uberEleet:Bool):PlayerInfo {
		var player = PlayerInfo.createDefault(1, "Haxxor");
		player.uberEleet = uberEleet;
		return player;
	}

	private function givenMission():MissionData {
		return {
			_seed: 1,
			_corp: "corp",
			_color: 0,
			_short: "short",
			_details: "details",
			_prime: 1,
			_bonus: 0,
			_type: _MTutorial,
			_xp: 1,
			_gl: 1,
			_cards: new List(),
		};
	}
}
