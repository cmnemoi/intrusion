/**
Represents clipboard shortcuts triggered from keyboard events.
*/
enum KeyboardClipboardShortcut {
	Copy;
	Paste;
	Cut;
}

/**
Represents metadata for the current keyboard event target.
*/
typedef KeyboardShortcutTarget = {
	@:optional var id:String;
	@:optional var tagName:String;
	@:optional var type:String;
	@:optional var isContentEditable:Bool;
}

/**
Represents keyboard metadata used to resolve shortcut handling.
*/
typedef KeyboardShortcutContext = {
	var keyCode:Int;
	var ctrlKey:Bool;
	var metaKey:Bool;
	var target:KeyboardShortcutTarget;
	var allowedEditableElementId:String;
}

/**
Provides keyboard input policies used by client event handlers.
*/
class KeyboardInputPolicy {
	public static inline var CLIPBOARD_FALLBACK_ELEMENT_ID = "clipboard-paste-fallback";
	public static inline var ARROW_DOWN_KEY_CODE = 40;
	public static inline var SPACE_KEY_CODE = 32;

	public static inline var KEY_CODE_C = 67;
	public static inline var KEY_CODE_V = 86;
	public static inline var KEY_CODE_X = 88;
	static inline var KEY_CODE_DIGIT_ZERO = 48;
	static inline var KEY_CODE_DIGIT_NINE = 57;
	static inline var KEY_CODE_UPPERCASE_A = 65;
	static inline var KEY_CODE_UPPERCASE_Z = 90;
	static inline var CHARACTER_CODE_DIGIT_ZERO = 48;
	static inline var CHARACTER_CODE_DIGIT_NINE = 57;
	static inline var CHARACTER_CODE_LOWERCASE_A = 97;
	static inline var CHARACTER_CODE_LOWERCASE_Z = 122;

	/**
	Returns whether default key-up browser behavior should be prevented.

	Parameters
	----------
	ctrlKey : Bool
		Whether Control is pressed.
	metaKey : Bool
		Whether Meta (Command) is pressed.

	Returns
	-------
	Bool
		True when browser default behavior must be prevented.
	*/
	public static function shouldPreventDefaultOnKeyUp(ctrlKey:Bool, metaKey:Bool):Bool {
		return !ctrlKey && !metaKey;
	}

	/**
	Returns whether default key-down browser behavior should be prevented.

	Parameters
	----------
	keyCode : Int
		Pressed key code.
	ctrlKey : Bool
		Whether Control is pressed.
	metaKey : Bool
		Whether Meta (Command) is pressed.

	Returns
	-------
	Bool
		True when browser default behavior must be prevented.
	*/
	public static function shouldPreventDefaultOnKeyDown(keyCode:Int, ctrlKey:Bool, metaKey:Bool):Bool {
		if (ctrlKey || metaKey)
			return false;

		return keyCode == SPACE_KEY_CODE || keyCode == ARROW_DOWN_KEY_CODE;
	}

	/** @spec missions.uber-eleet.client-input::prevent-browser-navigation */
	public static function shouldPreventDefaultInCommandLine(ctrlKey:Bool, metaKey:Bool):Bool {
		return !ctrlKey && !metaKey;
	}

	/**
	Resolves clipboard shortcut action from a key combination.

	Parameters
	----------
	keyCode : Int
		Pressed key code.
	ctrlKey : Bool
		Whether Control is pressed.
	metaKey : Bool
		Whether Meta (Command) is pressed.

	Returns
	-------
	Null<KeyboardClipboardShortcut>
		Resolved shortcut, or null when none matches.
	*/
	public static function getClipboardShortcut(keyCode:Int, ctrlKey:Bool, metaKey:Bool):Null<KeyboardClipboardShortcut> {
		if (!ctrlKey && !metaKey)
			return null;

		return switch (keyCode) {
			case KEY_CODE_C: Copy;
			case KEY_CODE_V: Paste;
			case KEY_CODE_X: Cut;
			default: null;
		}
	}

	/**
	Returns whether a clipboard shortcut should be handled by game code.

	Parameters
	----------
	context : KeyboardShortcutContext
		Keyboard key state, target metadata, and allowed fallback id.

	Returns
	-------
	Bool
		True when game code should handle the clipboard shortcut.
	*/
	public static function shouldHandleClipboardShortcut(context:KeyboardShortcutContext):Bool {
		var shortcut = getClipboardShortcut(context.keyCode, context.ctrlKey, context.metaKey);
		if (shortcut == null)
			return false;

		return shouldHandleClipboardShortcutForTarget(context.target, context.allowedEditableElementId);
	}

	/**
	Returns whether game code should handle clipboard shortcut for target.

	Parameters
	----------
	target : KeyboardShortcutTarget
		Current keyboard event target metadata.
	allowedEditableElementId : String
		Identifier of editable fallback element controlled by the game.

	Returns
	-------
	Bool
		True when clipboard handling should be managed by the game.
	*/
	public static function shouldHandleClipboardShortcutForTarget(
		target:KeyboardShortcutTarget,
		allowedEditableElementId:String
	):Bool {
		// if clipboard is handled by the game (ie. in the canvas), allow it
		if (target == null || target.id == allowedEditableElementId)
			return true;

		// else, allow if not a text editing target, ie. browser should be able to handle it itself
		return !isTextEditingTarget(target);
	}

	/**
	Sanitizes pasted password text by keeping only alphanumeric chars.

	Parameters
	----------
	text : String
		Raw clipboard text.

	Returns
	-------
	String
		Lowercased alphanumeric string.
	*/
	public static function sanitizePasswordClipboardText(text:String):String {
		final lowercaseText = text.toLowerCase();
		final sanitizedText = new StringBuf();

		for (characterIndex in 0...lowercaseText.length) {
			var characterCode = lowercaseText.charCodeAt(characterIndex);
			if (isAlphaNumerical(characterCode))
				sanitizedText.addChar(characterCode);
		}

		return sanitizedText.toString();
	}

	/**
	Normalizes command clipboard text by replacing line breaks with spaces.

	Parameters
	----------
	text : String
		Raw clipboard text.

	Returns
	-------
	String
		Single-line text.
	*/
	public static function normalizeCommandClipboardText(text:String):String {
		var normalizedText = StringTools.replace(text, "\r\n", " ");
		normalizedText = StringTools.replace(normalizedText, "\n", " ");
		normalizedText = StringTools.replace(normalizedText, "\r", " ");
		return normalizedText;
	}

	/**
	Returns a printable command-line character from a key event.

	Parameters
	----------
	key : Null<String>
		Browser key value.
	ctrlKey : Bool
		Whether Control is pressed.
	metaKey : Bool
		Whether Meta (Command) is pressed.

	Returns
	-------
	Null<String>
		Lowercased character, or null for shortcuts and special keys.
	*/
	/** @spec missions.uber-eleet.client-input::typed-characters-visible */
	public static function commandLineCharacter(key:Null<String>, ctrlKey:Bool, metaKey:Bool):Null<String> {
		if (key == null || key.length != 1 || ctrlKey || metaKey)
			return null;
		return key.toLowerCase();
	}

	/**
	Masks password text with asterisks while preserving its length.

	Parameters
	----------
	text : String
		Input password text.

	Returns
	-------
	String
		Masked password text.
	*/
	public static function maskPasswordText(text:String):String {
		if (isEmptyString(text))
			return "";

		return StringTools.lpad("", "*", text.length);
	}

	/**
	Returns whether a key-down should append a password character.

	Parameters
	----------
	keyCode : Int
		Pressed key code.
	ctrlKey : Bool
		Whether Control is pressed.
	metaKey : Bool
		Whether Meta (Command) is pressed.

	Returns
	-------
	Bool
		True when the key should append a password character.
	*/
	public static function shouldAcceptPasswordCharacterKey(keyCode:Int, ctrlKey:Bool, metaKey:Bool):Bool {
		if (ctrlKey || metaKey)
			return false;

		return isPasswordCharacterKeyCode(keyCode);
	}

	static function isTextEditingTarget(target:KeyboardShortcutTarget):Bool {
		var normalizedTagName = (target.tagName ?? "").toLowerCase();
		if (target.isContentEditable || normalizedTagName == "textarea")
			return true;

		return normalizedTagName == "input";
	}

	static function isAlphaNumerical(characterCode:Int):Bool {
		var isDigit = characterCode >= CHARACTER_CODE_DIGIT_ZERO && characterCode <= CHARACTER_CODE_DIGIT_NINE;
		var isLetter = characterCode >= CHARACTER_CODE_LOWERCASE_A && characterCode <= CHARACTER_CODE_LOWERCASE_Z;
		return isDigit || isLetter;
	}

	static function isPasswordCharacterKeyCode(keyCode:Int):Bool {
		var isDigit = keyCode >= KEY_CODE_DIGIT_ZERO && keyCode <= KEY_CODE_DIGIT_NINE;
		var isLetter = keyCode >= KEY_CODE_UPPERCASE_A && keyCode <= KEY_CODE_UPPERCASE_Z;
		return isDigit || isLetter;
	}

	static function isEmptyString(value:Null<String>):Bool {
		return value == null || value.length == 0;
	}
}
