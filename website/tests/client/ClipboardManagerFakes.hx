package tests.client;

import js.lib.Promise;

class FakeClipboard {
	public var copiedText(default, null):String;
	public var readCallCount(default, null):Int;

	var clipboardText:String;
	var shouldFailWrite:Bool;
	var shouldFailRead:Bool;

	public function new(clipboardText:String, shouldFailWrite:Bool = false, shouldFailRead:Bool = false):Void {
		this.copiedText = "";
		this.readCallCount = 0;
		this.clipboardText = clipboardText;
		this.shouldFailWrite = shouldFailWrite;
		this.shouldFailRead = shouldFailRead;
	}

	public function writeText(text:String):Promise<Bool> {
		return new Promise(function(resolve, reject) {
			if (shouldFailWrite) {
				reject("write-error");
				return;
			}

			copiedText = text;
			resolve(true);
		});
	}

	public function readText():Promise<String> {
		return new Promise(function(resolve, reject) {
			readCallCount += 1;

			if (shouldFailRead) {
				reject("read-error");
				return;
			}

			resolve(clipboardText);
		});
	}
}

class DeferredReadClipboard {
	public var readCallCount(default, null):Int;

	var readResolvers:Array<String->Void>;

	public function new():Void {
		readCallCount = 0;
		readResolvers = [];
	}

	public function writeText(_:String):Promise<Bool> {
		return Promise.resolve(true);
	}

	public function readText():Promise<String> {
		return new Promise(function(resolve, _) {
			readCallCount += 1;
			readResolvers.push(resolve);
		});
	}

	public function resolveReadAt(index:Int, text:String):Void {
		var resolve = readResolvers[index];
		if (resolve != null)
			resolve(text);
	}
}

class FakeDocument {
	public var body(default, null):FakeBody;
	public var activeElement:Null<FakeElement>;

	var elementsById:Map<String, FakeElement>;

	public function new():Void {
		elementsById = new Map();
		body = new FakeBody(registerElement);
		activeElement = null;
	}

	public function registerElement(element:FakeElement):Void {
		if (element.id == null || element.id == "")
			return;

		elementsById.set(element.id, element);
	}

	public function getElementById(elementId:String):Null<FakeElement> {
		return elementsById.get(elementId);
	}

	public function createElement(_:String):FakeElement {
		return new FakeElement();
	}

	public function addEventListener(_:String, _:Dynamic):Void {}

	public function removeEventListener(_:String, _:Dynamic):Void {}

	public function attributeForElement(elementId:String, attributeName:String):Null<String> {
		var element = elementsById.get(elementId);
		if (element == null)
			return null;

		return element.getAttribute(attributeName);
	}
}

class FakeBody {
	var appendElement:FakeElement->Void;

	public function new(appendElement:FakeElement->Void):Void {
		this.appendElement = appendElement;
	}

	public function appendChild(element:FakeElement):Void {
		appendElement(element);
	}
}

class FakeElement {
	public var id(default, null):String;
	public var style(default, null):FakeStyle;
	public var tagName(default, null):String;
	public var type(default, null):String;
	public var isContentEditable(default, null):Bool;

	var attributes:Map<String, String>;

	public function new(?id = "", ?tagName = "DIV", ?type = "", ?isContentEditable = false):Void {
		this.id = id;
		this.tagName = tagName;
		this.type = type;
		this.isContentEditable = isContentEditable;
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

class FakeStyle {
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
