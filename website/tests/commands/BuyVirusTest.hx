package tests.commands;

import commands.BuyVirus;
import model.PlayerInfo;
import utest.Assert;
import utest.Test;

class BuyVirusTest extends Test {
	function testBuyVirusWhenPlayerHasEnoughMoney() {
		var player = givenPlayerWithVirusesAndMoney([], 1_000);

		var hasBoughtVirus = buyVirus(player, "unit-test-virus", 300);

		Assert.isTrue(hasBoughtVirus);
		Assert.equals(1, player.viruses.length);
		Assert.equals("unit-test-virus", player.viruses[0]);
		Assert.equals(700, player.money);
	}

	function testBuyVirusAgainWhenPlayerAlreadyOwnsIt() {
		var player = givenPlayerWithVirusesAndMoney(["unit-test-virus"], 1_000);

		var hasBoughtVirus = buyVirus(player, "unit-test-virus", 300);

		Assert.isTrue(hasBoughtVirus);
		Assert.equals(2, player.viruses.length);
		Assert.equals("unit-test-virus", player.viruses[1]);
		Assert.equals(700, player.money);
	}

	function testNotBuyVirusWhenPlayerHasNotEnoughMoney() {
		var player = givenPlayerWithVirusesAndMoney(["unit-test-virus"], 299);

		var hasBoughtVirus = buyVirus(player, "unit-test-virus", 300);

		Assert.isFalse(hasBoughtVirus);
		Assert.equals(1, player.viruses.length);
		Assert.equals(299, player.money);
	}

	function testNotBuyVirusWhenPriceIsMissing() {
		var player = givenPlayerWithVirusesAndMoney([], 1_000);

		var hasBoughtVirus = buyVirus(player, "unit-test-virus", null);

		Assert.isFalse(hasBoughtVirus);
		Assert.equals(0, player.viruses.length);
		Assert.equals(1_000, player.money);
	}

	function givenPlayerWithVirusesAndMoney(viruses:Array<String>, money:Int):PlayerInfo {
		return {
			id: "1",
			username: "tester",
			money: money,
			xp: 0,
			viruses: viruses,
			chipsets: [],
			activeChipset: "none",
			decks: [{name: "Deck 1", capacity: 3, content: []}],
			goals: new Map(),
			valuables: new Map(),
			activeMissions: [],
			availableMissions: [],
			completedMissions: [],
		};
	}

	function buyVirus(player:PlayerInfo, virusId:String, virusPrice:Null<Int>):Bool {
		return BuyVirus.execute(player, virusId, virusPrice);
	}
}
