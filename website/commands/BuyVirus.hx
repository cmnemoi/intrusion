package commands;

import model.PlayerInfo;

class BuyVirus {
	public static function execute(player:PlayerInfo, virusId:String, virusPrice:Null<Int>):Bool {
		if (isMissingInput(player, virusId, virusPrice))
			return false;

		if (player.money < virusPrice)
			return false;

		player.money -= virusPrice;
		player.viruses.push(virusId);
		return true;
	}

	private static function isMissingInput(player:PlayerInfo, virusId:String, virusPrice:Null<Int>):Bool {
		return player == null || virusId == null || virusPrice == null;
	}
}
