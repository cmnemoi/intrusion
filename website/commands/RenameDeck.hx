package commands;

import model.PlayerInfo;

class RenameDeck {
	public static inline var MAX_NAME_LENGTH = 32;

	public static function execute(player: PlayerInfo, deckIndex: Int, requestedName: String): Bool {
		if (isMissingInput(player, requestedName))
			return false;

		if (!hasDeckAtIndex(player, deckIndex))
			return false;

		var sanitizedName = sanitizeName(requestedName);
		if (!isValidName(sanitizedName))
			return false;

		renameDeck(player, deckIndex, sanitizedName);
		return true;
	}

	private static function isMissingInput(player: PlayerInfo, requestedName: String): Bool {
		return player == null || requestedName == null;
	}

	private static function hasDeckAtIndex(player: PlayerInfo, deckIndex: Int): Bool {
		return deckIndex >= 0 && deckIndex < player.decks.length;
	}

	private static function sanitizeName(requestedName: String): String {
		return StringTools.trim(requestedName);
	}

	private static function isValidName(name: String): Bool {
		return name.length > 0 && name.length <= MAX_NAME_LENGTH;
	}

	private static function renameDeck(player: PlayerInfo, deckIndex: Int, name: String): Void {
		player.decks[deckIndex].name = name;
	}
}
