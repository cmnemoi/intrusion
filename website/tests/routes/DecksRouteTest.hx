package tests.routes;

import routes.Decks;
import utest.Assert;
import utest.Test;

class DecksRouteTest extends Test {
	function testNormalizeDeckIndexWhenRequestedIndexIsNull() {
		Assert.equals(0, Decks.normalizeDeckIndex(null, 3));
	}

	function testNormalizeDeckIndexWhenRequestedIndexIsNegative() {
		Assert.equals(0, Decks.normalizeDeckIndex(-1, 3));
	}

	function testNormalizeDeckIndexWhenRequestedIndexIsOutOfBounds() {
		Assert.equals(0, Decks.normalizeDeckIndex(3, 3));
	}

	function testNormalizeDeckIndexWhenRequestedIndexIsValid() {
		Assert.equals(2, Decks.normalizeDeckIndex(2, 3));
	}

	function testNormalizeDeckIndexWhenDeckCountIsZero() {
		Assert.equals(0, Decks.normalizeDeckIndex(4, 0));
	}

	function testRequestedDeckIndexFromPathWhenPathIsValidInteger() {
		Assert.equals(2, Decks.requestedDeckIndexFromPath("2", 4));
	}

	function testRequestedDeckIndexFromPathWhenPathIsInvalid() {
		Assert.equals(0, Decks.requestedDeckIndexFromPath("abc", 4));
	}

	function testDeckPathUsesSegmentFormat() {
		Assert.equals("/decks/3", Decks.deckPath(3));
	}
}
