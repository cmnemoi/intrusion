package tests;

import tests.AppErrorHandlingTest;
import tests.commands.BuyDeckTest;
import tests.commands.BuyVirusTest;
import tests.commands.RenameDeckTest;
import tests.commands.UpgradeDeckTest;
import tests.routes.DecksRouteTest;
import utest.UTest;

class TestMain {
	public static function main() {
		UTest.run([new RenameDeckTest(), new BuyDeckTest(), new BuyVirusTest(), new UpgradeDeckTest(), new DecksRouteTest(), new AppErrorHandlingTest()]);
	}
}
