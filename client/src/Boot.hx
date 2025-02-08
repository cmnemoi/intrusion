import pixi.core.utils.Utils;
import pixi.core.Application;
import common.MovieClipBuilder;
import common.KeyboardManager;
import Types;

class Boot {
	public static var man = null;

	static function main() {
		//haxe.Log.setColor(0xFFFF00);
		//haxe.Log.trace = log;

		KeyboardManager.init();
		Utils.skipHello();

		var view = cast js.Browser.document.getElementById("main");
		Manager.app = new pixi.core.Application({width: Data.WID, height: Data.HEI, view: view
		//, backgroundColor: 0x56a6e3
		});

		untyped globalThis.__PIXI_APP__ = Manager.app;
		untyped js.Browser.window.__PIXI_DEVTOOLS__ = {
			app: Manager.app,
		  };

		man = new Manager();
		//man = new Debug();
	}
}

class Debug {
	var textures_loaded: Bool = false;
	var sprite_created: Bool = false;
	var DM: mt.DepthManager;

	public function new() {
			// INIT
			var spriteBuilder = new MovieClipBuilder("xml_sprites", Manager.ASSET_ROOT);
			spriteBuilder.preloadAssets(() -> {
				textures_loaded = true;
			});

			var ROOT = new common.MovieClip(spriteBuilder);
			Manager.app.stage.addChild(ROOT);

			DM = new mt.DepthManager(ROOT);
			js.Browser.window.requestAnimationFrame(update);
		}

	private function update(ts: Float) {
		js.Browser.window.requestAnimationFrame(update);

		if (textures_loaded && !sprite_created) {
			var mc = DM.attach("file", 0);
			mc.x = 100;
			mc.y = 100;

			mc.icon.gotoAndStop("antivir");
			var mcc : MCField = cast mc.icon;
			mcc.field.text = "FAN";

			sprite_created = true;
		}
	}
}

