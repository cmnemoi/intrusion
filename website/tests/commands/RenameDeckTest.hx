package tests.commands;

import commands.RenameDeck;
import model.PlayerInfo;

class RenameDeckTest {
	public static function run() {
		testShouldRenameDeckWhenNameIsValid();
		testShouldTrimNameBeforeRenamingDeck();
		testShouldRenameDeckWhenNameLengthIsExactlyMax();
		testShouldNotRenameDeckWhenNameIsEmptyAfterTrim();
		testShouldNotRenameDeckWhenNameIsTooLong();
		testShouldNotRenameDeckWhenDeckIndexIsOutOfBounds();
		testShouldNotRenameDeckWhenDeckIndexIsNegative();
		testShouldNotRenameDeckWhenRequestedNameIsNull();
	}

	static function testShouldRenameDeckWhenNameIsValid() {
		var player = givenPlayerWithOneDeck("Deck Principal");

		var hasBeenRenamed = whenRenamingDeck(player, 0, "Aggro");

		thenRenameShouldSucceed(hasBeenRenamed);
		thenDeckNameShouldBe(player, "Aggro");
	}

	static function testShouldTrimNameBeforeRenamingDeck() {
		var player = givenPlayerWithOneDeck("Deck Principal");

		var hasBeenRenamed = whenRenamingDeck(player, 0, "  Combo  ");

		thenRenameShouldSucceed(hasBeenRenamed);
		thenDeckNameShouldBe(player, "Combo");
	}

	static function testShouldRenameDeckWhenNameLengthIsExactlyMax() {
		var player = givenPlayerWithOneDeck("Deck Principal");

		var hasBeenRenamed = whenRenamingDeck(player, 0, givenNameWithLength(32));

		thenRenameShouldSucceed(hasBeenRenamed);
		thenDeckNameShouldBe(player, givenNameWithLength(32));
	}

	static function testShouldNotRenameDeckWhenNameIsEmptyAfterTrim() {
		var player = givenPlayerWithOneDeck("Deck Principal");

		var hasBeenRenamed = whenRenamingDeck(player, 0, "   ");

		thenRenameShouldFail(hasBeenRenamed);
		thenDeckNameShouldBe(player, "Deck Principal");
	}

	static function testShouldNotRenameDeckWhenNameIsTooLong() {
		var player = givenPlayerWithOneDeck("Deck Principal");

		var hasBeenRenamed = whenRenamingDeck(player, 0, givenNameWithLength(33));

		thenRenameShouldFail(hasBeenRenamed);
		thenDeckNameShouldBe(player, "Deck Principal");
	}

	static function testShouldNotRenameDeckWhenDeckIndexIsOutOfBounds() {
		var player = givenPlayerWithOneDeck("Deck Principal");

		var hasBeenRenamed = whenRenamingDeck(player, 1, "Control");

		thenRenameShouldFail(hasBeenRenamed);
		thenDeckNameShouldBe(player, "Deck Principal");
	}

	static function testShouldNotRenameDeckWhenDeckIndexIsNegative() {
		var player = givenPlayerWithOneDeck("Deck Principal");

		var hasBeenRenamed = whenRenamingDeck(player, -1, "Control");

		thenRenameShouldFail(hasBeenRenamed);
		thenDeckNameShouldBe(player, "Deck Principal");
	}

	static function testShouldNotRenameDeckWhenRequestedNameIsNull() {
		var player = givenPlayerWithOneDeck("Deck Principal");

		var hasBeenRenamed = whenRenamingDeck(player, 0, null);

		thenRenameShouldFail(hasBeenRenamed);
		thenDeckNameShouldBe(player, "Deck Principal");
	}

	static function givenPlayerWithOneDeck(deckName: String): PlayerInfo {
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

	static function givenNameWithLength(length: Int): String {
		return [for (_ in 0...length) "A"].join("");
	}

	static function whenRenamingDeck(player: PlayerInfo, deckIndex: Int, requestedName: String): Bool {
		return RenameDeck.execute(player, deckIndex, requestedName);
	}

	static function thenRenameShouldSucceed(hasBeenRenamed: Bool) {
		if (!hasBeenRenamed)
			throw "Expected rename to succeed";
	}

	static function thenRenameShouldFail(hasBeenRenamed: Bool) {
		if (hasBeenRenamed)
			throw "Expected rename to fail";
	}

	static function thenDeckNameShouldBe(player: PlayerInfo, expectedName: String) {
		if (player.decks[0].name != expectedName)
			throw 'Expected deck name "$expectedName" but got "${player.decks[0].name}"';
	}
}
