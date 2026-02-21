package tests;

import utest.Assert;
import utest.Test;

class MissionGenXpProgressTest extends Test {
	function testShouldCalculateXpProgressWhenAtStartOfLevel() {
		var xpProgress = MissionGen.getXpProgress(3);

		Assert.equals(3, xpProgress.currentLevelXp);
		Assert.equals(10, xpProgress.nextLevelXp);
		Assert.equals(7, xpProgress.remainingXp);
		Assert.equals(0, xpProgress.progressPercent);
	}

	function testShouldCalculateXpProgressWhenInMiddleOfLevel() {
		var xpProgress = MissionGen.getXpProgress(6);

		Assert.equals(3, xpProgress.currentLevelXp);
		Assert.equals(10, xpProgress.nextLevelXp);
		Assert.equals(4, xpProgress.remainingXp);
		Assert.equals(42, xpProgress.progressPercent);
	}

	function testShouldReturnFullProgressWhenAtMaximumLevel() {
		var xpProgress = MissionGen.getXpProgress(250);

		Assert.equals(250, xpProgress.currentLevelXp);
		Assert.equals(250, xpProgress.nextLevelXp);
		Assert.equals(0, xpProgress.remainingXp);
		Assert.equals(100, xpProgress.progressPercent);
	}
}
