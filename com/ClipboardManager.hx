import js.lib.Promise;
import js.lib.Error;
import js.html.Document;
import js.html.Element;

typedef ClipboardAccess = {
	function writeText(text:String):Promise<Bool>;
	function readText():Promise<String>;
}

typedef BrowserWindowAccess = {
	function setTimeout(callback:Void->Void, delay:Int):Int;
	function clearTimeout(timeoutHandle:Int):Void;
}

typedef FocusableElement = {
	function focus():Void;
}

typedef FallbackElementStyle = {
	var position:String;
	var left:String;
	var top:String;
	var width:String;
	var height:String;
	var opacity:String;
	var pointerEvents:String;
}

typedef PasteTimeoutContext = {
	var document:Document;
	var browserWindow:BrowserWindowAccess;
	var onPaste:js.html.ClipboardEvent->Void;
	var resolve:String->Void;
}

class ClipboardManager {
	public static inline var EMPTY_TEXT = "";
	static inline var NO_TIMEOUT_HANDLE = -1;
	static inline var PASTE_TIMEOUT_IN_MILLISECONDS = 5_000;
	static var pasteInFlight:Null<Promise<String>> = null;

	/**
	 * Initialize clipboard paste fallback support.
	 * Creates an off-screen editable element used only during paste interception.
	 */
	public static function initFallback(?document:Document):Void {
		var resolvedDocument = getHTMLDocument(document);
		if (resolvedDocument == null)
			return;

		createFallbackPasteHTMLElement(resolvedDocument);
	}

	public static function copy(text:String, ?clipboard:ClipboardAccess):Promise<Bool> {
		var resolvedClipboard = getClipboard(clipboard);
		if (resolvedClipboard == null)
			return Promise.resolve(false);

		try {
			return cast resolvedClipboard.writeText(text).then(function(_) {
				return true;
			}, function(_) {
				return false;
			});
		}
		catch (_:Error) {
			// Clipboard APIs are optional and may throw in unsupported contexts.
			return Promise.resolve(false);
		}
	}

	public static function paste(?clipboard:ClipboardAccess, ?document:Document):Promise<String> {
		if (pasteInFlight != null)
			return pasteInFlight;

		var pasteOperation = pasteWithClipboardOrFallback(clipboard, document);
		pasteInFlight = releasePasteLockWhenComplete(pasteOperation);
		return pasteInFlight;
	}

	static function pasteWithClipboardOrFallback(?clipboard:ClipboardAccess, ?document:Document):Promise<String> {
		if (!shouldHandleClipboardFromFocusedElement(document))
			return Promise.resolve(EMPTY_TEXT);

		var resolvedClipboard = getClipboard(clipboard);
		if (resolvedClipboard == null)
			return fallbackPaste(document);

		try {
			return cast resolvedClipboard.readText().then(function(text:String) {
				if (text == null || text.length == 0)
					return fallbackPaste(document);

				return Promise.resolve(text);
			}, function(_) {
				return fallbackPaste(document);
			});
		}
		catch (_:Error) {
			// Clipboard APIs are optional and may throw in unsupported contexts.
			return fallbackPaste(document);
		}
	}

	static function releasePasteLockWhenComplete(pasteOperation:Promise<String>):Promise<String> {
		return cast pasteOperation.then(function(text:String) {
			pasteInFlight = null;
			return text;
		}, function(_:Error) {
			pasteInFlight = null;
			return EMPTY_TEXT;
		});
	}

	static function fallbackPaste(?document:Document):Promise<String> {
		var resolvedDocument = getHTMLDocument(document);
		if (resolvedDocument == null)
			return Promise.resolve(EMPTY_TEXT);

		var fallbackElement = createFallbackPasteHTMLElement(resolvedDocument);
		if (fallbackElement == null)
			return Promise.resolve(EMPTY_TEXT);

		focusElement(fallbackElement);
		return waitForPasteText(resolvedDocument);
	}

	static function shouldHandleClipboardFromFocusedElement(?document:Document):Bool {
		var resolvedDocument = getHTMLDocument(document);
		if (resolvedDocument == null)
			return true;

		return KeyboardInputPolicy.shouldHandleClipboardShortcutForTarget(
			cast resolvedDocument.activeElement,
			"clipboard-paste-fallback"
		);
	}

	static function waitForPasteText(document:Document):Promise<String> {
		return new Promise(function(resolve, _) {
			var browserWindow = getBrowserWindow();
			if (browserWindow == null) {
				resolve(EMPTY_TEXT);
				return;
			}

			waitForPasteEvent(document, browserWindow, resolve);
		});
	}

	static function waitForPasteEvent(
		document:Document,
		browserWindow:BrowserWindowAccess,
		resolve:String->Void
	):Void {
		var timeoutHandle = NO_TIMEOUT_HANDLE;
		var onPaste:js.html.ClipboardEvent->Void = null;

		onPaste = function(event:js.html.ClipboardEvent) {
			if (timeoutHandle != NO_TIMEOUT_HANDLE) {
				browserWindow.clearTimeout(timeoutHandle);
			}
			document.removeEventListener("paste", onPaste);
			resolve(readClipboardText(event));
		};

		timeoutHandle = schedulePasteTimeout({
			document: document,
			browserWindow: browserWindow,
			onPaste: onPaste,
			resolve: resolve,
		});
		document.addEventListener("paste", onPaste);
	}

	static function schedulePasteTimeout(context:PasteTimeoutContext):Int {
		var document = context.document;
		var browserWindow = context.browserWindow;
		var onPaste = context.onPaste;
		var resolve = context.resolve;

		return browserWindow.setTimeout(function() {
			document.removeEventListener("paste", onPaste);
			resolve(EMPTY_TEXT);
		}, PASTE_TIMEOUT_IN_MILLISECONDS);
	}

	static function readClipboardText(event:js.html.ClipboardEvent):String {
		if (event == null || event.clipboardData == null)
			return EMPTY_TEXT;

		var text = event.clipboardData.getData("text/plain");
		if (text == null)
			return EMPTY_TEXT;

		return text;
	}

	static function createFallbackPasteHTMLElement(document:Document):Null<Element> {
		var existingElement = document.getElementById("clipboard-paste-fallback");
		if (existingElement != null)
			return existingElement;

		if (document.body == null)
			return null;

		var fallbackElement = document.createElement("div");
		fallbackElement.setAttribute("id", "clipboard-paste-fallback");
		fallbackElement.setAttribute("contenteditable", "plaintext-only");
		fallbackElement.setAttribute("tabindex", "-1");
		fallbackElement.setAttribute("aria-hidden", "true");
		fallbackElement.style.position = "fixed";
		fallbackElement.style.left = "-10000px";
		fallbackElement.style.top = "0";
		fallbackElement.style.width = "1px";
		fallbackElement.style.height = "1px";
		fallbackElement.style.opacity = "0";
		fallbackElement.style.pointerEvents = "none";
		document.body.appendChild(fallbackElement);

		return fallbackElement;
	}

	static function focusElement(element:Element):Void {
		var focusableElement:Null<FocusableElement> = cast element;
		if (focusableElement == null)
			return;

		try {
			focusableElement.focus();
		}
		catch (_:Error) {
			// Some browsers block focus changes outside trusted interactions.
		}
	}

	static function getHTMLDocument(?document:Document):Null<Document> {
		if (document != null)
			return document;

		try {
			return js.Browser.document;
		}
		catch (_:Error) {
			// Browser globals are unavailable in non-browser execution contexts.
			return null;
		}
	}

	static function getBrowserWindow():Null<BrowserWindowAccess> {
		try {
			return cast js.Browser.window;
		}
		catch (_:Error) {
			// Browser globals are unavailable in non-browser execution contexts.
			return null;
		}
	}

	static function getClipboard(clipboard:ClipboardAccess):Null<ClipboardAccess> {
		if (clipboard != null)
			return clipboard;

		return getNavigatorClipboard();
	}

	static function getNavigatorClipboard():Null<ClipboardAccess> {
		try {
			if (js.Browser.navigator == null)
				return null;

			var navigatorClipboard:Null<ClipboardAccess> = cast js.Browser.navigator.clipboard;
			return navigatorClipboard;
		}
		catch (_:Error) {
			// Clipboard API access can fail in restricted browser environments.
			return null;
		}
	}
}
