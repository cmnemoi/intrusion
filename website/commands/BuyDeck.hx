package commands;

import model.PlayerInfo;

class BuyDeck {
	public static function execute(player:PlayerInfo):Bool {
		if (player == null)
			return false;

		var cost = nextDeckCost(player.decks.length);
		if (player.money < cost)
			return false;

		player.money -= cost;
		player.decks.push({
			name: defaultDeckName(player.decks.length + 1),
			capacity: 3,
			content: [],
		});

		return true;
	}

	public static function nextDeckCost(currentDeckCount:Int):Int {
		var nextDeckNumber = currentDeckCount + 1;
		if (nextDeckNumber < 2)
			nextDeckNumber = 2;

		var distanceFromSecondDeck = nextDeckNumber - 2;
		return 2000 * distanceFromSecondDeck * distanceFromSecondDeck + 2500;
	}

	private static function defaultDeckName(deckNumber:Int):String {
		return 'Deck $deckNumber';
	}
}
