import haxe.Serializer;
import js.Browser;
import js.html.FormElement;
import js.html.InputElement;
import js.swfobject.SWFObject;
import Protocol;

class JSMain {
	static var VIDEO_WID = "360";
	static var VIDEO_HEI = "240";

    public function new() {}

    public function lockBar() {
		//mt.js.Twinoid.lockBar();
    }

    function htmlize(str: String) {
        return "<p>" + str.split("\n").join("</p><p>") + "</p>";
    }

    public function print(title: String, str: String) {
        var dom = js.Browser.document.getElementById("sideContent");
        if(title != null) dom.innerHTML = "<h1>" + title + "</h1>" + str; else dom.innerHTML = str;
    }

    public function printTutorial(title: String, str: String) {
		var dom = js.Browser.document.getElementById("tutorial");
		dom.innerHTML = "<div>" + (title != null?"<h1>" + title + "</h1>":"") + str + "</div>";
	}

    public function clearTutorial() {
		var dom = js.Browser.document.getElementById("tutorial");
		dom.innerHTML = "";
	}

    public function printTip(title: String, str: String) {
		// TODO: Add tips to side bar.
		/*
		var dom = js.Browser.document.getElementById("clientTipContent");
		dom.innerHTML = "<div>" + (title != null?"<h1>" + title + "</h1>":"") + str + "</div>";
		var dom1 = js.Browser.document.getElementById("clientTip");
		dom1.style.display = "block";
		*/
	}

	public function anotherTip() {
		//JsMain.cnx.resolve("_Com").resolve("_anotherTip").call([]);
	}

	public function clearTip() {
		/*
		var dom = js.Browser.document.getElementById("clientTipContent");
		dom.innerHTML = "";
		var dom1 = js.Browser.document.getElementById("clientTip");
		dom1.style.display = "none";
		*/
	}

    public function printBriefing(short: String, full: String) {
        var dom = js.Browser.document.getElementById("briefingContent");
        dom.innerHTML = htmlize("<strong>" + short + "</strong>") + htmlize(full);
    }

	public function clear() {
		var dom = js.Browser.document.getElementById("sideContent");
		dom.innerHTML = "";
	}

    public function embedVideo(title: String, id: String) {
		/*
		var dom = js.Browser.document.getElementById("sideContent");
		var params = {"allowScriptAccess": "always"};
		SWFObject.embedSWF("http://www.youtube.com/v/" + id + "&enablejsapi=1&playerapiid=player1","hackerPlayer",VIDEO_WID,VIDEO_HEI,"8","#000000", null, params, null, (event: SWFObjectEvent) -> {});
		dom.innerHTML = "<h1>" + title + "</h1> " + so.getSWFHTML();
		*/
    }

    public function embedImage(title: String, thumb: String, big: String) {
		var dom = js.Browser.document.getElementById("sideContent");
		dom.innerHTML = "<h1>" + title + "</h1>" + "<a href='" + big + "' target='_blank' class='pic'>" + "<img src='" + thumb + "' alt='Loading...'/>" + "</a>";
    }

	public function send(url: String, msg: _Message, cb: _Message -> Void) {
		var form: FormElement = cast js.Browser.document.createElement('form');
		form.method = "post";
		form.action = url;
		var input: InputElement = cast js.Browser.document.createElement('input');
		input.type = "text";
		input.name = "msg";
		var serializer =  new Serializer();
		serializer.serialize(msg);
		input.value = serializer.toString();
		form.appendChild(input);
		js.Browser.document.body.appendChild(form);
		form.submit();
		// Weird to have a callback after redirecting..
		cb(msg);
	}

    public function nextTutoStep() {
		//JsMain.cnx.resolve("_Com").resolve("_nextTutoStep").call([]);
	}

	/*
	JsMain.getElem = function(eid) {
		return js.Lib.document.getElementById(eid);
	}
	JsMain.initSort = function() {
		var listener = { onChange : function(e,source,dest) {
			JsMain.getElem("deckContainer").className = "";
			JsMain.getElem("poolContainer").className = "";
			if(source.id == "pool" && dest.id == "pool") return;
			if(source.id == "deck" && dest.id == "deck") JsMain.saveDeck(false); else if(JsMain.allowAdd) JsMain.saveDeck(true); else haxe.Log.trace("refused.",{ fileName : "JsMain.hx", lineNumber : 117, className : "JsMain", methodName : "initSort"});
		}, onDragStart : function(e) {
			mt.js.Tip.hide();
			if(e.parentNode.id == "pool") JsMain.getElem("deckContainer").className = "highlight"; else JsMain.getElem("poolContainer").className = "highlight";
		}, onDragCancel : function(e) {
			JsMain.getElem("deckContainer").className = "";
			JsMain.getElem("poolContainer").className = "";
		}, onDragOver : function(e,target) {
		}, onDragOut : function(e,target) {
		}, onDrop : function(e,target) {
			JsMain.getElem("deckContainer").className = "";
			JsMain.getElem("poolContainer").className = "";
		}};
		var sortableFilter = function(e) {
			return e.id != "IESUCKS";
		};
		JsMain.sort = new js.fx.Sort([JsMain.getElem("pool"),JsMain.getElem("deck")],listener,sortableFilter);
		JsMain.sort.start();
	}
	JsMain.onData = function(data) {
		if(data != "ok") JsMain.onError(data); else {
			JsMain.getElem("loading").style.display = "none";
			JsMain.sort.start();
		}
	}
	JsMain.onError = function(raw) {
		if(raw != null) {
			var msg = raw.split("|")[1];
			js.Lib.window.location.assign("/deck/error?msg=" + msg);
		} else js.Lib.window.location.assign("/deck/error");
	}
	JsMain.saveDeck = function(fl_virusAdded) {
		var deck = JsMain.getElem("deck");
		var child = deck.firstChild;
		var list = new List();
		var n = 0;
		var ieFoundAt = -1;
		while(child != null) {
			if(child.nodeType == 1 && child.nodeName == "LI") {
				var id = child.getAttribute("id");
				if(id != null && id != "IESUCKS") {
					var vid = id.split("_")[1];
					list.add(vid);
				}
				if(id == "IESUCKS") ieFoundAt = n;
			}
			child = child.nextSibling;
			n++;
		}
		if(ieFoundAt < n - 2) {
			JsMain.onError();
			return;
		}
		JsMain.getElem("loading").style.display = "block";
		JsMain.sort.stop();
		var req = new haxe.Http("/deck/saveDeck");
		req.onData = JsMain.onData;
		req.onError = JsMain.onError;
		req.setParameter("list",list.join(":"));
		if(fl_virusAdded) req.setParameter("added","1");
		req.request(true);
	}
	*/
}