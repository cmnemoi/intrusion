package tests.client;

import ClipboardManager;
import js.lib.Promise;
import utest.Assert;
import utest.Async;
import utest.Test;

class ClipboardManagerTest extends Test {
	static inline var COPIED_TEXT = "copied";
	static inline var EMPTY_TEXT = "";

	function testShouldCopyTextWhenClipboardIsAvailable(async:Async) {
		var clipboard = givenClipboardWithText("already-there");

		ClipboardManager.copy(COPIED_TEXT, clipboard).then(function(hasCopied) {
			thenCopySucceeds(hasCopied, clipboard.copiedText);
			async.done();
			return null;
		});
	}

	function testShouldNotTurnMainCanvasIntoEditableWhenInitializingFallback() {
		var fakeDocument = givenDocumentWithMainCanvas();

		ClipboardManager.initFallback(cast fakeDocument);

		thenCanvasRemainsNonEditable(fakeDocument);
		thenFallbackElementIsEditable(fakeDocument);
	}

	function testShouldNotCopyTextWhenClipboardWriteFails(async:Async) {
		var clipboard = givenClipboardWithText("already-there", true, false);

		ClipboardManager.copy(COPIED_TEXT, clipboard).then(function(hasCopied) {
			thenCopyFails(hasCopied, clipboard.copiedText);
			async.done();
			return null;
		});
	}

	function testShouldPasteClipboardTextWhenClipboardIsAvailable(async:Async) {
		var clipboard = givenClipboardWithText("from-clipboard");

		ClipboardManager.paste(clipboard).then(function(pastedText) {
			thenPastedTextIs("from-clipboard", pastedText);
			async.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenClipboardReadFails(async:Async) {
		var clipboard = givenClipboardWithText("ignored", false, true);

		ClipboardManager.paste(clipboard).then(function(pastedText) {
			thenTextIsEmpty(pastedText);
			async.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenClipboardIsUnavailable(async:Async) {
		ClipboardManager.paste(null).then(function(pastedText) {
			thenTextIsEmpty(pastedText);
			async.done();
			return null;
		});
	}

	function testShouldResolvePromiseWhenClipboardIsProvided(async:Async) {
		var clipboard = givenClipboardWithText("test-text");

		var pastePromise = ClipboardManager.paste(clipboard);
		thenResultIsPromise(cast pastePromise);

		pastePromise.then(function(text) {
			thenPastedTextIs("test-text", text);
			async.done();
			return null;
		});
	}

	function givenClipboardWithText(text:String, ?failWrite=false, ?failRead=false):FakeClipboard {
		return new FakeClipboard(text, failWrite, failRead);
	}

	function givenDocumentWithMainCanvas():FakeDocument {
		var fakeDocument = new FakeDocument();
		fakeDocument.registerElement(new FakeElement("main"));
		return fakeDocument;
	}

	function thenCopySucceeds(hasCopied:Bool, copiedText:String):Void {
		Assert.isTrue(hasCopied);
		Assert.equals(COPIED_TEXT, copiedText);
	}

	function thenCopyFails(hasCopied:Bool, copiedText:String):Void {
		Assert.isFalse(hasCopied);
		Assert.equals(EMPTY_TEXT, copiedText);
	}

	function thenCanvasRemainsNonEditable(fakeDocument:FakeDocument):Void {
		Assert.equals(null, fakeDocument.attributeForElement("main", "contenteditable"));
	}

	function thenFallbackElementIsEditable(fakeDocument:FakeDocument):Void {
		Assert.equals(
			"plaintext-only",
			fakeDocument.attributeForElement("clipboard-paste-fallback", "contenteditable")
		);
	}

	function thenPastedTextIs(expectedText:String, pastedText:String):Void {
		Assert.equals(expectedText, pastedText);
	}

	function thenTextIsEmpty(text:String):Void {
		Assert.equals(EMPTY_TEXT, text);
	}

	function thenResultIsPromise(result:Dynamic):Void {
		Assert.isTrue(Std.isOfType(result, Promise));
	}
}

private class FakeClipboard {
	public var copiedText(default, null):String;

	var clipboardText:String;
	var failWrite:Bool;
	var failRead:Bool;

	public function new(clipboardText:String, failWrite:Bool, failRead:Bool):Void {
		this.copiedText = "";
		this.clipboardText = clipboardText;
		this.failWrite = failWrite;
		this.failRead = failRead;
	}

	public function writeText(text:String):Promise<Dynamic> {
		return new Promise(function(resolve, reject) {
			if (failWrite) {
				reject("write-error");
				return;
			}

			copiedText = text;
			resolve(null);
		});
	}

	public function readText():Promise<String> {
		return new Promise(function(resolve, reject) {
			if (failRead) {
				reject("read-error");
				return;
			}

			resolve(clipboardText);
		});
	}
}

private class FakeDocument {
	public var body(default, null):FakeBody;

	var elementsById:Map<String, FakeElement>;

	public function new():Void {
		elementsById = new Map();
		body = new FakeBody(registerElement);
	}

	public function registerElement(element:FakeElement):Void {
		if (element.id == null || element.id == "")
			return;

		elementsById.set(element.id, element);
	}

	public function getElementById(elementId:String):FakeElement {
		return elementsById.get(elementId);
	}

	public function createElement(tagName:String):FakeElement {
		return new FakeElement();
	}

	public function addEventListener(eventName:String, handler:Dynamic):Void {}

	public function removeEventListener(eventName:String, handler:Dynamic):Void {}

	public function attributeForElement(elementId:String, attributeName:String):Null<String> {
		var element = elementsById.get(elementId);
		if (element == null)
			return null;

		return element.getAttribute(attributeName);
	}
}

private class FakeBody {
	var appendElement:FakeElement->Void;

	public function new(appendElement:FakeElement->Void):Void {
		this.appendElement = appendElement;
	}

	public function appendChild(element:FakeElement):Void {
		appendElement(element);
	}
}

private class FakeElement {
	public var id(default, null):String;
	public var style(default, null):FakeStyle;

	var attributes:Map<String, String>;

	public function new(?id = ""):Void {
		this.id = id;
		this.style = new FakeStyle();
		this.attributes = new Map();
	}

	public function focus():Void {}

	public function setAttribute(name:String, value:String):Void {
		if (name == "id")
			id = value;

		attributes.set(name, value);
	}

	public function getAttribute(attributeName:String):Null<String> {
		return attributes.get(attributeName);
	}
}

private class FakeStyle {
	public var position:String;
	public var left:String;
	public var top:String;
	public var width:String;
	public var height:String;
	public var opacity:String;
	public var pointerEvents:String;

	public function new():Void {
		position = "";
		left = "";
		top = "";
		width = "";
		height = "";
		opacity = "";
		pointerEvents = "";
	}
}
