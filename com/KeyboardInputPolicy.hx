enum KeyboardClipboardShortcut {
	Copy;
	Paste;
	Cut;
}

class KeyboardInputPolicy {
	static public inline var ARROW_DOWN = 40;
	static public inline var SPACE = 32;

	static inline var KEY_C = 67;
	static inline var KEY_V = 86;
	static inline var KEY_X = 88;

	static public function shouldPreventDefaultOnKeyUp(_:Int, ctrlKey:Bool, metaKey:Bool):Bool {
		return !ctrlKey && !metaKey;
	}

	static public function shouldPreventDefaultOnKeyDown(keyCode:Int, ctrlKey:Bool, metaKey:Bool):Bool {
		if (ctrlKey || metaKey)
			return false;

		return keyCode == SPACE || keyCode == ARROW_DOWN;
	}

	static public function getClipboardShortcut(keyCode:Int, ctrlKey:Bool, metaKey:Bool):Null<KeyboardClipboardShortcut> {
		if (!ctrlKey && !metaKey)
			return null;

		return switch (keyCode) {
			case KEY_C: Copy;
			case KEY_V: Paste;
			case KEY_X: Cut;
			default: null;
		}
	}

	static public function sanitizePasswordClipboardText(text:String):String {
		var lowercaseText = text.toLowerCase();
		var sanitizedText = new StringBuf();

		for (i in 0...lowercaseText.length) {
			var characterCode = lowercaseText.charCodeAt(i);
			var isDigit = characterCode >= 48 && characterCode <= 57;
			var isLetter = characterCode >= 97 && characterCode <= 122;
			if (isDigit || isLetter)
				sanitizedText.addChar(characterCode);
		}

		return sanitizedText.toString();
	}

	static public function normalizeCommandClipboardText(text:String):String {
		var normalizedText = StringTools.replace(text, "\r\n", " ");
		normalizedText = StringTools.replace(normalizedText, "\n", " ");
		normalizedText = StringTools.replace(normalizedText, "\r", " ");
		return normalizedText;
	}

	static public function maskPasswordText(text:String):String {
		if (text == null || text.length == 0)
			return "";

		var maskedText = new StringBuf();
		for (_ in 0...text.length)
			maskedText.add("*");

		return maskedText.toString();
	}
}
