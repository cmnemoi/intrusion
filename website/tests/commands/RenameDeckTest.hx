package tests.commands;

import commands.RenameDeck;
import model.PlayerInfo;
import utest.Assert;
import utest.Test;

class RenameDeckTest extends Test {
	var player:PlayerInfo;

	public function setup() {
		player = givenPlayerWithOneDeck("Deck Principal");
	}

	function testRenameDeckWhenNameIsValid() {
		var hasBeenRenamed = renameDeck(0, "Aggro");

		Assert.isTrue(hasBeenRenamed);
		Assert.equals("Aggro", player.decks[0].name);
	}

	function testTrimNameBeforeRenamingDeck() {
		var hasBeenRenamed = renameDeck(0, "  Combo  ");

		Assert.isTrue(hasBeenRenamed);
		Assert.equals("Combo", player.decks[0].name);
	}

	function testRenameDeckWhenNameLengthIsExactlyMax() {
		var maximumLengthName = nameWithLength(32);
		var hasBeenRenamed = renameDeck(0, maximumLengthName);

		Assert.isTrue(hasBeenRenamed);
		Assert.equals(maximumLengthName, player.decks[0].name);
	}

	function testNotRenameDeckWhenNameIsEmptyAfterTrim() {
		var hasBeenRenamed = renameDeck(0, "   ");

		Assert.isFalse(hasBeenRenamed);
		Assert.equals("Deck Principal", player.decks[0].name);
	}

	function testNotRenameDeckWhenNameIsTooLong() {
		var hasBeenRenamed = renameDeck(0, nameWithLength(33));

		Assert.isFalse(hasBeenRenamed);
		Assert.equals("Deck Principal", player.decks[0].name);
	}

	function testNotRenameDeckWhenDeckIndexIsOutOfBounds() {
		var hasBeenRenamed = renameDeck(1, "Control");

		Assert.isFalse(hasBeenRenamed);
		Assert.equals("Deck Principal", player.decks[0].name);
	}

	function testNotRenameDeckWhenDeckIndexIsNegative() {
		var hasBeenRenamed = renameDeck(-1, "Control");

		Assert.isFalse(hasBeenRenamed);
		Assert.equals("Deck Principal", player.decks[0].name);
	}

	function testNotRenameDeckWhenRequestedNameIsNull() {
		var hasBeenRenamed = renameDeck(0, null);

		Assert.isFalse(hasBeenRenamed);
		Assert.equals("Deck Principal", player.decks[0].name);
	}

	function givenPlayerWithOneDeck(deckName:String):PlayerInfo {
		return {
			id: "1",
			username: "tester",
			money: 0,
			xp: 0,
			viruses: [],
			chipsets: [],
			activeChipset: "none",
			decks: [{name: deckName, capacity: 3, content: []}],
			goals: new Map(),
			valuables: new Map(),
			activeMissions: [],
			availableMissions: [],
			completedMissions: [],
		};
	}

	function nameWithLength(length:Int):String {
		return [for (_ in 0...length) "A"].join("");
	}

	function renameDeck(deckIndex:Int, requestedName:String):Bool {
		return RenameDeck.execute(player, deckIndex, requestedName);
	}
}
