package tests.commands;

import commands.UpgradeDeck;
import model.PlayerInfo;
import utest.Assert;
import utest.Test;

class UpgradeDeckTest extends Test {
	function testShouldUpgradeDeckWhenPlayerHasEnoughMoney() {
		var player = givenPlayerWithDeckCapacityAndMoney(3, 500);

		var hasUpgradedDeck = whenUpgradingDeck(player, 0);

		thenUpgradeShouldSucceed(hasUpgradedDeck);
		thenDeckShouldHaveCapacity(player, 4);
		thenPlayerShouldHaveMoney(player, 0);
	}

	function testShouldNotUpgradeDeckWhenPlayerHasNotEnoughMoney() {
		var player = givenPlayerWithDeckCapacityAndMoney(3, 499);

		var hasUpgradedDeck = whenUpgradingDeck(player, 0);

		thenUpgradeShouldFail(hasUpgradedDeck);
		thenDeckShouldHaveCapacity(player, 3);
		thenPlayerShouldHaveMoney(player, 499);
	}

	function testShouldNotUpgradeDeckWhenDeckIndexIsOutOfBounds() {
		var player = givenPlayerWithDeckCapacityAndMoney(3, 1_000);

		var hasUpgradedDeck = whenUpgradingDeck(player, 1);

		thenUpgradeShouldFail(hasUpgradedDeck);
		thenDeckShouldHaveCapacity(player, 3);
		thenPlayerShouldHaveMoney(player, 1_000);
	}

	function testShouldFollowDocumentedUpgradeCostFormula() {
		var expectedCosts = [500, 2_000, 6_500, 14_000, 24_500, 38_000];
		for (i in 0...expectedCosts.length) {
			var currentCapacity = i + 3;
			var expectedCost = expectedCosts[i];

			Assert.equals(expectedCost, UpgradeDeck.nextUpgradeCost(currentCapacity));
		}
	}

	function whenUpgradingDeck(player:PlayerInfo, deckIndex:Int):Bool {
		return UpgradeDeck.execute(player, deckIndex);
	}

	function thenUpgradeShouldSucceed(hasUpgradedDeck:Bool):Void {
		Assert.isTrue(hasUpgradedDeck);
	}

	function thenUpgradeShouldFail(hasUpgradedDeck:Bool):Void {
		Assert.isFalse(hasUpgradedDeck);
	}

	function thenDeckShouldHaveCapacity(player:PlayerInfo, expectedCapacity:Int):Void {
		Assert.equals(expectedCapacity, player.decks[0].capacity);
	}

	function thenPlayerShouldHaveMoney(player:PlayerInfo, expectedMoney:Int):Void {
		Assert.equals(expectedMoney, player.money);
	}

	function givenPlayerWithDeckCapacityAndMoney(deckCapacity:Int, money:Int):PlayerInfo {
		return {
			id: "1",
			username: "tester",
			money: money,
			xp: 0,
			viruses: [],
			chipsets: [],
			activeChipset: "none",
			decks: [{name: "Deck 1", capacity: deckCapacity, content: []}],
			goals: new Map(),
			valuables: new Map(),
			activeMissions: [],
			availableMissions: [],
			completedMissions: [],
		};
	}
}
