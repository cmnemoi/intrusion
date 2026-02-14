package commands;

import model.PlayerInfo;

class UpgradeDeck {
	public static inline var MINIMUM_SLOT_NUMBER = 4;
	public static inline var UPGRADE_COST_BASE = 500;
	public static inline var UPGRADE_COST_MULTIPLIER = 1_500;

	public static function execute(player:PlayerInfo, deckIndex:Int):Bool {
		if (!canUpgradeDeck(player, deckIndex))
			return false;

		var cost = nextUpgradeCost(player.decks[deckIndex].capacity);
		if (player.money < cost)
			return false;

		player.money -= cost;
		player.decks[deckIndex].capacity += 1;
		return true;
	}

	public static function nextUpgradeCost(currentDeckCapacity:Int):Int {
		var nextSlotNumber = currentDeckCapacity + 1;
		if (nextSlotNumber < MINIMUM_SLOT_NUMBER)
			nextSlotNumber = MINIMUM_SLOT_NUMBER;

		var distanceFromMinimumSlot = nextSlotNumber - MINIMUM_SLOT_NUMBER;
		return UPGRADE_COST_MULTIPLIER * distanceFromMinimumSlot * distanceFromMinimumSlot + UPGRADE_COST_BASE;
	}

	private static function canUpgradeDeck(player:PlayerInfo, deckIndex:Int):Bool {
		if (player == null)
			return false;

		return deckIndex >= 0 && deckIndex < player.decks.length;
	}
}
