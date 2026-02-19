package tests.client;

import KeyboardInputPolicy;
import utest.Assert;
import utest.Test;

class KeyboardInputPolicyTest extends Test {
	function testShouldPreventDefaultOnKeyUpWithoutModifier() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyUp(65, false, false);

		Assert.isTrue(shouldPreventDefault);
	}

	function testShouldNotPreventDefaultOnKeyUpWithControl() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyUp(67, true, false);

		Assert.isFalse(shouldPreventDefault);
	}

	function testShouldNotPreventDefaultOnKeyUpWithMeta() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyUp(67, false, true);

		Assert.isFalse(shouldPreventDefault);
	}

	function testShouldPreventDefaultOnSpaceKeyDownWithoutModifier() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyDown(KeyboardInputPolicy.SPACE, false, false);

		Assert.isTrue(shouldPreventDefault);
	}

	function testShouldPreventDefaultOnArrowDownKeyDownWithoutModifier() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyDown(KeyboardInputPolicy.ARROW_DOWN, false, false);

		Assert.isTrue(shouldPreventDefault);
	}

	function testShouldNotPreventDefaultOnArrowDownKeyDownWithMeta() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyDown(KeyboardInputPolicy.ARROW_DOWN, false, true);

		Assert.isFalse(shouldPreventDefault);
	}

	function testShouldReturnPasteShortcutWhenControlAndVArePressed() {
		var shortcut = KeyboardInputPolicy.getClipboardShortcut(86, true, false);

		Assert.equals(KeyboardClipboardShortcut.Paste, shortcut);
	}

	function testShouldReturnCopyShortcutWhenMetaAndCArePressed() {
		var shortcut = KeyboardInputPolicy.getClipboardShortcut(67, false, true);

		Assert.equals(KeyboardClipboardShortcut.Copy, shortcut);
	}

	function testShouldReturnNullShortcutWhenNoModifierIsPressed() {
		var shortcut = KeyboardInputPolicy.getClipboardShortcut(67, false, false);

		Assert.isNull(shortcut);
	}

	function testShouldSanitizePasswordClipboardText() {
		var clipboardText = "Ab C-12_#xYz";

		var sanitizedText = KeyboardInputPolicy.sanitizePasswordClipboardText(clipboardText);

		Assert.equals("abc12xyz", sanitizedText);
	}

	function testShouldNormalizeCommandClipboardText() {
		var clipboardText = "ls -la\n pwd\r\nwhoami";

		var normalizedText = KeyboardInputPolicy.normalizeCommandClipboardText(clipboardText);

		Assert.equals("ls -la  pwd whoami", normalizedText);
	}
}
