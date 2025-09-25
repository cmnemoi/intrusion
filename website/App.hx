import model.Viruses;

import haxe.crypto.Md5;
import js.node.Fs;
import jsasync.IJSAsync;
import Express;

using jsasync.JSAsyncTools;

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
		app.post("/register", registerPlayer);
		app.use('/missions', loadPlayer, routes.Missions.create("fr"));
		app.use('/decks', loadPlayer, routes.Decks.create());
		app.use('/store', loadPlayer, routes.Store.create());
		app.use('/storage', loadPlayer, routes.Storage.create());


		app.listen(port, function() {
			trace('Listening on port $port');
		});
	}

	public static function getTemplate(name: String): haxe.Template {
		return new haxe.Template(Fs.readFileSync(TEMPLATES_ROOT + name).toString());
	}

	@:jsasync private static function renderRegister(res:ExpressResponse) {
		res.end(getTemplate('site_template.html').execute({
			content: Fs.readFileSync(TEMPLATES_ROOT + 'register.html').toString(),
			money: 0,
			level: 0
		}));
	}
	
	@:jsasync public static function renderContent(req:ExpressRequest, res:ExpressResponse, content: String) {
		var player: PlayerInfo = req.locals.player;
		res.end(getTemplate('site_template.html').execute({
			content: content,
			money: player.money,
			level: player.level(),
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
			throw new Error("Player ID too high!");
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
