package tests.client;

import ClipboardManager;
import js.lib.Promise;
import utest.Assert;
import utest.Async;
import utest.Test;

class ClipboardManagerTest extends Test {
	function testShouldCopyTextWhenClipboardIsAvailable(async:Async) {
		var clipboard = givenClipboardWithText("already-there");

		ClipboardManager.copy("copied", clipboard).then(function(hasCopied) {
			Assert.isTrue(hasCopied);
			Assert.equals("copied", clipboard.copiedText);
			async.done();
			return null;
		});
	}

	function testShouldNotCopyTextWhenClipboardWriteFails(async:Async) {
		var clipboard = givenClipboardWithText("already-there", true, false);

		ClipboardManager.copy("copied", clipboard).then(function(hasCopied) {
			Assert.isFalse(hasCopied);
			Assert.equals("", clipboard.copiedText);
			async.done();
			return null;
		});
	}

	function testShouldPasteClipboardTextWhenClipboardIsAvailable(async:Async) {
		var clipboard = givenClipboardWithText("from-clipboard");

		ClipboardManager.paste(clipboard).then(function(pastedText) {
			Assert.equals("from-clipboard", pastedText);
			async.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenClipboardReadFails(async:Async) {
		var clipboard = givenClipboardWithText("ignored", false, true);

		ClipboardManager.paste(clipboard).then(function(pastedText) {
			Assert.equals("", pastedText);
			async.done();
			return null;
		});
	}

	function testShouldReturnEmptyStringWhenClipboardIsUnavailable(async:Async) {
		ClipboardManager.paste(null).then(function(pastedText) {
			Assert.equals("", pastedText);
			async.done();
			return null;
		});
	}

	function givenClipboardWithText(text:String, ?failWrite=false, ?failRead=false):FakeClipboard {
		return new FakeClipboard(text, failWrite, failRead);
	}
}

private class FakeClipboard {
	public var copiedText(default, null):String;

	var clipboardText:String;
	var failWrite:Bool;
	var failRead:Bool;

	public function new(clipboardText:String, failWrite:Bool, failRead:Bool) {
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
