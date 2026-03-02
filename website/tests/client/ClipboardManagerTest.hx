package tests.client;

import ClipboardManager;
import KeyboardInputPolicy;
import js.lib.Promise;
import tests.client.ClipboardManagerFakes.DeferredReadClipboard;
import tests.client.ClipboardManagerFakes.FakeClipboard;
import tests.client.ClipboardManagerFakes.FakeDocument;
import tests.client.ClipboardManagerFakes.FakeElement;
import utest.Assert;
import utest.Async;
import utest.Test;

class ClipboardManagerTest extends Test {
	static inline var COPIED_TEXT = "copied";

	function testShouldCopyTextWhenClipboardIsAvailable(asyncHandle:Async) {
		var clipboard = givenClipboardWithText("already-there");

		ClipboardManager.copy(COPIED_TEXT, clipboard).then(function(hasCopied) {
			thenCopySucceeds(hasCopied, clipboard.copiedText);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldNotTurnMainCanvasIntoEditableWhenInitializingFallback() {
		var fakeDocument = givenDocumentWithMainCanvas();

		ClipboardManager.initFallback(cast fakeDocument);

		thenCanvasRemainsNonEditable(fakeDocument);
		thenFallbackElementIsEditable(fakeDocument);
	}

	function testShouldNotCopyTextWhenClipboardWriteFails(asyncHandle:Async) {
		var clipboard = givenClipboardWithText("already-there", true, false);

		ClipboardManager.copy(COPIED_TEXT, clipboard).then(function(hasCopied) {
			thenCopyFails(hasCopied, clipboard.copiedText);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldPasteClipboardTextWhenClipboardIsAvailable(asyncHandle:Async) {
		var clipboard = givenClipboardWithText("from-clipboard");

		ClipboardManager.paste(clipboard).then(function(pastedText) {
			thenPastedTextIs("from-clipboard", pastedText);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenClipboardReadFails(asyncHandle:Async) {
		var clipboard = givenClipboardWithText("ignored", false, true);

		ClipboardManager.paste(clipboard).then(function(pastedText) {
			thenTextIsEmpty(pastedText);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenClipboardIsUnavailable(asyncHandle:Async) {
		ClipboardManager.paste(null).then(function(pastedText) {
			thenTextIsEmpty(pastedText);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenTextareaIsFocusedOutsideGame(asyncHandle:Async) {
		var clipboard = givenClipboardWithText("from-clipboard");
		var fakeDocument = givenDocumentWithFocusedElement(new FakeElement("external-textarea", "TEXTAREA"));

		ClipboardManager.paste(clipboard, cast fakeDocument).then(function(pastedText) {
			thenTextIsEmpty(pastedText);
			Assert.equals(0, clipboard.readCallCount);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenInputIsFocusedOutsideGame(asyncHandle:Async) {
		var clipboard = givenClipboardWithText("from-clipboard");
		var fakeDocument = givenDocumentWithFocusedElement(new FakeElement("external-input", "INPUT", "text"));

		ClipboardManager.paste(clipboard, cast fakeDocument).then(function(pastedText) {
			thenTextIsEmpty(pastedText);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenEditableElementIsFocusedOutsideGame(asyncHandle:Async) {
		var clipboard = givenClipboardWithText("from-clipboard");
		var fakeDocument = givenDocumentWithFocusedElement(new FakeElement("external-contenteditable", "DIV", "", true));

		ClipboardManager.paste(clipboard, cast fakeDocument).then(function(pastedText) {
			thenTextIsEmpty(pastedText);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldResolvePromiseWhenClipboardIsProvided(asyncHandle:Async) {
		var clipboard = givenClipboardWithText("test-text");

		var pastePromise = ClipboardManager.paste(clipboard);
		thenResultIsPromise(pastePromise);

		pastePromise.then(function(text) {
			thenPastedTextIs("test-text", text);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldCoalesceConcurrentPasteRequests(asyncHandle:Async) {
		var clipboard = new DeferredReadClipboard();

		var firstPaste = ClipboardManager.paste(clipboard);
		var secondPaste = ClipboardManager.paste(clipboard);
		Assert.equals(1, clipboard.readCallCount);

		clipboard.resolveReadAt(0, "shared");

		Promise.all([firstPaste, secondPaste]).then(function(results) {
			var pastedTexts:Array<String> = cast results;
			Assert.equals("shared", pastedTexts[0]);
			Assert.equals("shared", pastedTexts[1]);
			asyncHandle.done();
			return null;
		});
	}

	function testShouldReleasePasteLockAfterInFlightRequestCompletes(asyncHandle:Async) {
		var clipboard = new DeferredReadClipboard();

		var firstPaste = ClipboardManager.paste(clipboard);
		var secondPaste = ClipboardManager.paste(clipboard);
		clipboard.resolveReadAt(0, "first");

		Promise.all([firstPaste, secondPaste]).then(function(_results) {
			var thirdPaste = ClipboardManager.paste(clipboard);
			Assert.equals(2, clipboard.readCallCount);
			clipboard.resolveReadAt(1, "second");

			thirdPaste.then(function(thirdText) {
				Assert.equals("second", thirdText);
				asyncHandle.done();
				return null;
			});

			return null;
		});
	}

	function givenClipboardWithText(text:String, shouldFailWrite:Bool = false, shouldFailRead:Bool = false):FakeClipboard {
		return new FakeClipboard(text, shouldFailWrite, shouldFailRead);
	}

	function givenDocumentWithMainCanvas():FakeDocument {
		var fakeDocument = new FakeDocument();
		fakeDocument.registerElement(new FakeElement("main"));
		return fakeDocument;
	}

	function givenDocumentWithFocusedElement(focusedElement:FakeElement):FakeDocument {
		var fakeDocument = givenDocumentWithMainCanvas();
		fakeDocument.activeElement = focusedElement;
		return fakeDocument;
	}

	function thenCopySucceeds(hasCopied:Bool, copiedText:String):Void {
		Assert.isTrue(hasCopied);
		Assert.equals(COPIED_TEXT, copiedText);
	}

	function thenCopyFails(hasCopied:Bool, copiedText:String):Void {
		Assert.isFalse(hasCopied);
		Assert.equals(ClipboardManager.EMPTY_TEXT, copiedText);
	}

	function thenCanvasRemainsNonEditable(fakeDocument:FakeDocument):Void {
		Assert.equals(null, fakeDocument.attributeForElement("main", "contenteditable"));
	}

	function thenFallbackElementIsEditable(fakeDocument:FakeDocument):Void {
		Assert.equals(
			"plaintext-only",
			fakeDocument.attributeForElement(KeyboardInputPolicy.CLIPBOARD_FALLBACK_ELEMENT_ID, "contenteditable")
		);
	}

	function thenPastedTextIs(expectedText:String, pastedText:String):Void {
		Assert.equals(expectedText, pastedText);
	}

	function thenTextIsEmpty(text:String):Void {
		Assert.equals(ClipboardManager.EMPTY_TEXT, text);
	}

	function thenResultIsPromise(result:Promise<String>):Void {
		Assert.isTrue(Std.isOfType(result, Promise));
	}
}
