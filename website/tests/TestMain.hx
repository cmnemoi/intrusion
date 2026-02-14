package tests;

import tests.commands.BuyDeckTest;
import tests.commands.RenameDeckTest;
import tests.routes.DecksRouteTest;
import utest.UTest;

class TestMain {
	public static function main() {
		UTest.run([new RenameDeckTest(), new BuyDeckTest(), new DecksRouteTest()]);
	}
}
