package tests.client;

import KeyboardInputPolicy;
import KeyboardInputPolicy.KeyboardShortcutTarget;
import utest.Assert;
import utest.Test;

class KeyboardInputPolicyTest extends Test {
	function testShouldPreventDefaultOnKeyUpWithoutModifier() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyUp(false, false);

		Assert.isTrue(shouldPreventDefault);
	}

	function testShouldNotPreventDefaultOnKeyUpWithControl() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyUp(true, false);

		Assert.isFalse(shouldPreventDefault);
	}

	function testShouldNotPreventDefaultOnKeyUpWithMeta() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyUp(false, true);

		Assert.isFalse(shouldPreventDefault);
	}

	function testShouldPreventDefaultOnSpaceKeyDownWithoutModifier() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyDown(KeyboardInputPolicy.SPACE_KEY_CODE, false, false);

		Assert.isTrue(shouldPreventDefault);
	}

	function testShouldPreventDefaultOnArrowDownKeyDownWithoutModifier() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyDown(KeyboardInputPolicy.ARROW_DOWN_KEY_CODE, false, false);

		Assert.isTrue(shouldPreventDefault);
	}

	function testShouldNotPreventDefaultOnArrowDownKeyDownWithMeta() {
		var shouldPreventDefault = KeyboardInputPolicy.shouldPreventDefaultOnKeyDown(KeyboardInputPolicy.ARROW_DOWN_KEY_CODE, false, true);

		Assert.isFalse(shouldPreventDefault);
	}

	function testShouldReturnPasteShortcutWhenControlAndVArePressed() {
		var shortcut = KeyboardInputPolicy.getClipboardShortcut(KeyboardInputPolicy.KEY_CODE_V, true, false);

		Assert.equals(KeyboardClipboardShortcut.Paste, shortcut);
	}

	function testShouldReturnCopyShortcutWhenMetaAndCArePressed() {
		var shortcut = KeyboardInputPolicy.getClipboardShortcut(KeyboardInputPolicy.KEY_CODE_C, false, true);

		Assert.equals(KeyboardClipboardShortcut.Copy, shortcut);
	}

	function testShouldReturnNullShortcutWhenNoModifierIsPressed() {
		var shortcut = KeyboardInputPolicy.getClipboardShortcut(KeyboardInputPolicy.KEY_CODE_C, false, false);

		Assert.isNull(shortcut);
	}

	function testShouldNotHandleClipboardShortcutWhenShortcutIsMissing() {
		var target:KeyboardShortcutTarget = { tagName: "DIV" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcut(
			65,
			false,
			false,
			target,
			"clipboard-paste-fallback"
		);

		Assert.isFalse(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTextareaIsFocused() {
		var target:KeyboardShortcutTarget = { tagName: "TEXTAREA" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcut(
			KeyboardInputPolicy.KEY_CODE_C,
			true,
			false,
			target,
			"clipboard-paste-fallback"
		);

		Assert.isFalse(shouldHandle);
	}

	function testShouldHandleClipboardShortcutWhenTargetIsNotEditable() {
		var target:KeyboardShortcutTarget = { tagName: "DIV" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcut(
			KeyboardInputPolicy.KEY_CODE_V,
			true,
			false,
			target,
			"clipboard-paste-fallback"
		);

		Assert.isTrue(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTargetIsTextarea() {
		var target:KeyboardShortcutTarget = { tagName: "TEXTAREA" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(target, "clipboard-paste-fallback");

		Assert.isFalse(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTargetIsTextInput() {
		var target:KeyboardShortcutTarget = { tagName: "INPUT", type: "text" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(target, "clipboard-paste-fallback");

		Assert.isFalse(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTargetIsCheckboxInput() {
		var target:KeyboardShortcutTarget = { tagName: "INPUT", type: "checkbox" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(target, "clipboard-paste-fallback");

		Assert.isFalse(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTargetIsEditableElement() {
		var target:KeyboardShortcutTarget = { isContentEditable: true };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(target, "clipboard-paste-fallback");

		Assert.isFalse(shouldHandle);
	}

	function testShouldHandleClipboardShortcutWhenTargetIsFallbackElement() {
		var target:KeyboardShortcutTarget = { id: "clipboard-paste-fallback", isContentEditable: true };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(target, "clipboard-paste-fallback");

		Assert.isTrue(shouldHandle);
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

	function testShouldMaskPasswordTextWithAsterisks() {
		var maskedText = KeyboardInputPolicy.maskPasswordText("abc123");

		Assert.equals("******", maskedText);
	}

	function testShouldKeepEmptyPasswordTextUnchanged() {
		var maskedText = KeyboardInputPolicy.maskPasswordText("");

		Assert.equals("", maskedText);
	}
}
