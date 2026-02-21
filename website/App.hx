import model.Viruses;

import haxe.crypto.Md5;
import js.node.Fs;
import js.lib.Promise;
import jsasync.IJSAsync;
import Express;

using jsasync.JSAsyncTools;

private typedef AsyncExpressCallback = ExpressRequest->ExpressResponse->(?Dynamic->Void)->Promise<Dynamic>;

class App implements IJSAsync {
	static inline private var MAX_PLAYER_UID = 0xFFFFFF;
	static inline private var TEMPLATES_ROOT = "website/templates/";

	static function main() {
		data.ValuablesXml.init("fr");		
        data.VirusXml.init("fr");
		data.ChipsetsXml.init("fr");

		var port = 8001;
		var app = new Express();

		app.disable("x-powered-by");
		app.use(new ExpressCookieParser());
		app.use(Express.urlencoded({extended: false}));
		app.use(Express.staticServe('./www/'));
		app.use(Express.staticServe('./client/img/'));
		app.use(Express.staticServe('./xml/'));
		
		app.get("/", (req, res, next) -> res.redirect("/missions"));
		app.post("/register", withAsyncErrorHandler(registerPlayer));
		app.use('/missions', withAsyncErrorHandler(loadPlayer), routes.Missions.create("fr"));
		app.use('/decks', withAsyncErrorHandler(loadPlayer), routes.Decks.create());
		app.use('/store', withAsyncErrorHandler(loadPlayer), routes.Store.create());
		app.use('/storage', withAsyncErrorHandler(loadPlayer), routes.Storage.create());
		app.use(handleUnhandledError);


		app.listen(port, function() {
			trace('Listening on port $port');
		});
	}

	public static function withAsyncErrorHandler(callback:AsyncExpressCallback):ExpressCB {
		return function(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void):Void {
			try {
				callback(req, res, next).then(function(_):Dynamic {
					return null;
				}, function(error:Dynamic):Dynamic {
					if (next != null)
						next(error);
					return null;
				});
			} catch (error:Dynamic) {
				if (next != null)
					next(error);
			}
		}
	}

	public static function handleUnhandledError(error:Dynamic, req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void):Void {
		trace('Unhandled route error: ${Std.string(error)}');
		if (untyped res.headersSent == true) {
			if (next != null)
				next(error);
			return;
		}

		untyped res.statusCode = 500;
		res.end("Internal Server Error");
	}

	public static function getTemplate(name: String): haxe.Template {
		return new haxe.Template(Fs.readFileSync(TEMPLATES_ROOT + name).toString());
	}

	@:jsasync private static function renderRegister(res:ExpressResponse) {
		res.end(getTemplate('site_template.html').execute({
			content: Fs.readFileSync(TEMPLATES_ROOT + 'register.html').toString(),
			money: 0,
			level: 0,
			xp: 0,
			xpRemaining: 0,
			xpProgress: 0,
		}));
	}
	
	@:jsasync public static function renderContent(req:ExpressRequest, res:ExpressResponse, content: String) {
		var player: PlayerInfo = req.locals.player;
		var xpProgress = MissionGen.getXpProgress(player.xp);
		res.end(getTemplate('site_template.html').execute({
			content: content,
			money: player.money,
			level: player.level(),
			xp: player.xp,
			xpRemaining: xpProgress.remainingXp,
			xpProgress: xpProgress.progressPercent,
			virusData: if (StringTools.contains(content, "tooltipOnEnter")) Viruses.jSData(player) else "",
		}));
	}

	@:jsasync static function loadPlayer(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		if ( req.path == '/register') {
			next();
			return;
		}
		if (req.cookies.abuid == null) {
			req.locals = {};
			renderRegister(res);
			return ;
		}
		var id = Std.parseInt(req.cookies.abuid);
		if (id > MAX_PLAYER_UID) {
			throw new haxe.Exception("Player ID too high, could not create player");
		}

		req.locals = {};
		req.locals.id = id;
		req.locals.player = PlayerInfo.load(id).jsawait();
		if (req.locals.player == null) {
			req.locals = {};
			renderRegister(res);
			return ;
		}
		if (req.locals.player.username == null) req.locals.player.username = req.locals.username;
		next();
	}

	@:jsasync static function registerPlayer(req:ExpressRequest, res:ExpressResponse, next:?Dynamic->Void) {
		var body = req.body;
		var id = Std.parseInt("0x" + Md5.encode(body.username).substr(0, 6));
		if (PlayerInfo.load(id).jsawait() == null) {
			PlayerInfo.createDefault(id, body.username).persist().jsawait();
		}

		var cookie_age = 3600 * 24 * 365 * 5; // 5 years
		res.set({'set-cookie': 'abuid=$id; Max-Age=$cookie_age'});
		res.set({'content-type': 'text/html'});
		res.redirect("/");
	}
}
