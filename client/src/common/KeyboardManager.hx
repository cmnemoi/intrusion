package common;

import haxe.ds.IntMap;
import js.html.KeyboardEvent;
import KeyboardInputPolicy;

class KeyboardManager {
	static public inline var ARROW_DOWN = 40;
	static public inline var ARROW_UP = 38;
	static public inline var ARROW_LEFT = 37;
	static public inline var ARROW_RIGHT = 39;
	static public inline var SPACE = 32;
	static public inline var ESCAPE = 27;

	public static var lastKeyCodeDown:Int = 0;
	private static var keyState:IntMap<Bool>;


	static public function init() {
		keyState = new IntMap();

		js.Browser.window.addEventListener("keydown", onKeyDown);
		js.Browser.window.addEventListener("keyup", onKeyUp);
	}

	static public function isAnyArrowKeyDown():Bool {
		return isKeyDown(ARROW_RIGHT) || isKeyDown(ARROW_UP) || isKeyDown(ARROW_LEFT) || isKeyDown(ARROW_DOWN);
	}

	static public function isKeyDown(keyCode:Int):Bool {
		return keyState.exists(keyCode);
	}

	static private function onKeyUp(event:KeyboardEvent):Void {
		keyState.remove(event.keyCode);
		if (KeyboardInputPolicy.shouldPreventDefaultOnKeyUp(event.ctrlKey, event.metaKey))
			event.preventDefault();
	}

	static private function onKeyDown(event:KeyboardEvent):Void {
		keyState.set(event.keyCode, true);
		lastKeyCodeDown = event.keyCode;
		if (KeyboardInputPolicy.shouldPreventDefaultOnKeyDown(event.keyCode, event.ctrlKey, event.metaKey))
			event.preventDefault();
	}
}
