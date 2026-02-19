import js.lib.Promise;

typedef ClipboardAccess = {
	function writeText(text:String):Promise<Dynamic>;
	function readText():Promise<String>;
}

class ClipboardManager {
	public static function copy(text:String, ?clipboard:ClipboardAccess):Promise<Bool> {
		var resolvedClipboard = resolveClipboard(clipboard);
		if (resolvedClipboard == null)
			return Promise.resolve(false);

		try {
			return cast resolvedClipboard.writeText(text).then(function(_) {
				return true;
			}, function(_) {
				return false;
			});
		}
		catch (_:Dynamic) {
			return Promise.resolve(false);
		}
	}

	public static function paste(?clipboard:ClipboardAccess):Promise<String> {
		var resolvedClipboard = resolveClipboard(clipboard);
		if (resolvedClipboard == null)
			return Promise.resolve("");

		try {
			return cast resolvedClipboard.readText().then(function(text) {
				if (text == null)
					return "";

				return text;
			}, function(_) {
				return "";
			});
		}
		catch (_:Dynamic) {
			return Promise.resolve("");
		}
	}

	static function resolveClipboard(clipboard:ClipboardAccess):Null<ClipboardAccess> {
		if (clipboard != null)
			return clipboard;

		try {
			var navigatorClipboard:Dynamic = untyped js.Browser.navigator != null ? untyped js.Browser.navigator.clipboard : null;
			return cast navigatorClipboard;
		}
		catch (_:Dynamic) {
			return null;
		}
	}
}
