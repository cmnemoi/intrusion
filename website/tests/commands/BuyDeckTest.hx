package tests.commands;

import commands.BuyDeck;
import model.PlayerInfo;
import utest.Assert;
import utest.Test;

class BuyDeckTest extends Test {
	function testBuyDeckWhenPlayerHasEnoughMoney() {
		var player = givenPlayerWithDeckCountAndMoney(1, 2500);

		var hasBoughtDeck = BuyDeck.execute(player);

		Assert.isTrue(hasBoughtDeck);
		Assert.equals(2, player.decks.length);
		Assert.equals(0, player.money);
		Assert.equals(3, player.decks[1].capacity);
		Assert.equals(0, player.decks[1].content.length);
	}

	function testNotBuyDeckWhenPlayerHasNotEnoughMoney() {
		var player = givenPlayerWithDeckCountAndMoney(1, 2499);

		var hasBoughtDeck = BuyDeck.execute(player);

		Assert.isFalse(hasBoughtDeck);
		Assert.equals(1, player.decks.length);
		Assert.equals(2499, player.money);
	}

	function testDeckCostFollowsDocumentedFormula() {
		var expectedCosts = [2500, 4500, 10500, 20500, 34500, 52500, 74500, 100500];
		for (i in 0...expectedCosts.length) {
			var currentDeckCount = i + 1;
			var expectedCost = expectedCosts[i];

			Assert.equals(expectedCost, BuyDeck.nextDeckCost(currentDeckCount));
		}
	}

	function givenPlayerWithDeckCountAndMoney(deckCount:Int, money:Int):PlayerInfo {
		var decks = [for (i in 0...deckCount) {
			name: 'Deck ${i + 1}',
			capacity: 3,
			content: [],
		}];

		return {
			id: "1",
			username: "tester",
			money: money,
			xp: 0,
			viruses: [],
			chipsets: [],
			activeChipset: "none",
			decks: decks,
			goals: new Map(),
			valuables: new Map(),
			activeMissions: [],
			availableMissions: [],
			completedMissions: [],
		};
	}
}
