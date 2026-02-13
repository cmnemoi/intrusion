package tests;

import tests.commands.RenameDeckTest;
import utest.UTest;

class TestMain {
	public static function main() {
		UTest.run([new RenameDeckTest()]);
	}
}
