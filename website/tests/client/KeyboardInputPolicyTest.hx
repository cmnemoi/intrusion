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

	/** @spec missions.uber-eleet.client-input::prevent-browser-navigation */
	function testShouldPreventDefaultInCommandLineWithoutModifier() {
		Assert.isTrue(KeyboardInputPolicy.shouldPreventDefaultInCommandLine(false, false));
	}

	/** @spec missions.uber-eleet.client-input::prevent-browser-navigation */
	function testShouldNotPreventDefaultInCommandLineWithModifier() {
		Assert.isFalse(KeyboardInputPolicy.shouldPreventDefaultInCommandLine(true, false));
		Assert.isFalse(KeyboardInputPolicy.shouldPreventDefaultInCommandLine(false, true));
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

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcut({
			keyCode: 65,
			ctrlKey: false,
			metaKey: false,
			target: target,
			allowedEditableElementId: KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID
		});

		Assert.isFalse(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTextareaIsFocused() {
		var target:KeyboardShortcutTarget = { tagName: "TEXTAREA" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcut({
			keyCode: KeyboardInputPolicy.KEY_CODE_C,
			ctrlKey: true,
			metaKey: false,
			target: target,
			allowedEditableElementId: KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID
		});

		Assert.isFalse(shouldHandle);
	}

	function testShouldHandleClipboardShortcutWhenTargetIsNotEditable() {
		var target:KeyboardShortcutTarget = { tagName: "DIV" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcut({
			keyCode: KeyboardInputPolicy.KEY_CODE_V,
			ctrlKey: true,
			metaKey: false,
			target: target,
			allowedEditableElementId: KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID
		});

		Assert.isTrue(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTargetIsTextarea() {
		var target:KeyboardShortcutTarget = { tagName: "TEXTAREA" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(
			target,
			KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID
		);

		Assert.isFalse(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTargetIsTextInput() {
		var target:KeyboardShortcutTarget = { tagName: "INPUT", type: "text" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(
			target,
			KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID
		);

		Assert.isFalse(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTargetIsCheckboxInput() {
		var target:KeyboardShortcutTarget = { tagName: "INPUT", type: "checkbox" };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(
			target,
			KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID
		);

		Assert.isFalse(shouldHandle);
	}

	function testShouldNotHandleClipboardShortcutWhenTargetIsEditableElement() {
		var target:KeyboardShortcutTarget = { isContentEditable: true };

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(
			target,
			KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID
		);

		Assert.isFalse(shouldHandle);
	}

	function testShouldHandleClipboardShortcutWhenTargetIsFallbackElement() {
		var target:KeyboardShortcutTarget = {
			id: KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID,
			isContentEditable: true
		};

		var shouldHandle = KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(
			target,
			KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID
		);

		Assert.isTrue(shouldHandle);
	}

	function testShouldAcceptPasswordCharacterKeyWithoutModifier() {
		var shouldAccept = KeyboardInputPolicy.shouldAcceptPasswordCharacterKey(
			KeyboardInputPolicy.KEY_CODE_V,
			false,
			false
		);

		Assert.isTrue(shouldAccept);
	}

	function testShouldRejectPasswordCharacterKeyWithControlModifier() {
		var shouldAccept = KeyboardInputPolicy.shouldAcceptPasswordCharacterKey(
			KeyboardInputPolicy.KEY_CODE_V,
			true,
			false
		);

		Assert.isFalse(shouldAccept);
	}

	function testShouldRejectPasswordCharacterKeyWithMetaModifier() {
		var shouldAccept = KeyboardInputPolicy.shouldAcceptPasswordCharacterKey(
			KeyboardInputPolicy.KEY_CODE_V,
			false,
			true
		);

		Assert.isFalse(shouldAccept);
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

	/** @spec missions.uber-eleet.client-input::typed-characters-visible */
	function testShouldReturnLowercaseCommandLineCharacter() {
		Assert.equals("a", KeyboardInputPolicy.commandLineCharacter("A", false, false));
	}

	/** @spec missions.uber-eleet.client-input::typed-characters-visible */
	function testShouldReturnCommandLineSpace() {
		Assert.equals(" ", KeyboardInputPolicy.commandLineCharacter(" ", false, false));
	}

	/** @spec missions.uber-eleet.client-input::typed-characters-visible */
	function testShouldRejectCommandLineControlShortcut() {
		Assert.isNull(KeyboardInputPolicy.commandLineCharacter("c", true, false));
		Assert.isNull(KeyboardInputPolicy.commandLineCharacter("c", false, true));
	}

	/** @spec missions.uber-eleet.client-input::typed-characters-visible */
	function testShouldRejectCommandLineSpecialKey() {
		Assert.isNull(KeyboardInputPolicy.commandLineCharacter("ArrowLeft", false, false));
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
