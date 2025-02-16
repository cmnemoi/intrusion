package common;

import mt.gx.HashEx;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.core.text.DefaultStyle;
import pixi.core.renderers.webgl.filters.Filter;
import pixi.core.Pixi;
import common.Types;

using Std;

/*
typedef Field = {
    public var width(default, default) : Float;
    public var height(default, default) : Float;
    public var text(default, default) : Null<String>;

    // DisplayObject
    public var x(default, default) : Float;
    public var y(default, default) : Float;
    public var visible(default, default): Bool;
    public var filters(default, default): Array<Filter>;
    // Sprite
    public var tint(null, set):Int;
    public var blendMode(null, set):BlendModes;
    // Text
    public var style: DefaultStyle;
	public var wordWrap(get, set):Bool;
	public var multiline(get, set):Bool;
	public var htmlText(get, set): String;


    // ASprite
	public var _xscale(get, set):Float;
	public var _yscale(get, set):Float;
	public var _alpha(get, set):Float;
	public var _visible(get, set):Bool;
	public var _x(get, set):Float;
	public var _y(get, set):Float;
    public var _rotation(get, set): Float;
	public var _width(default, set):Float;
	public var _height(default, set):Float;
	public var _name:String;
	public var _currentframe(default, null):Int;
    public var _totalframes:Int;
	public var _parent(get, set):Container;

    
    public var on : (String, (() -> Void)) -> Dynamic;
	public var onPress(default, set):Void->Void;
	public var onRollOut(default, set):Void->Void;
	public var onRollOver(default, set):Void->Void;
	public var onMouseMove(default, set):Void->Void;
	public var onDragOver:Void->Void; // Fixme
	public var onDragOut:Void->Void; // Fixme
	public var onRelease(default, set):Void->Void; // Fixme
	public var onReleaseOutside(default, set):Void->Void; // Fixme
	public var useHandCursor:Bool;
	public var loop:Bool;
    public var nextFrame: Void -> Void;
    public var gotoAndStop: Dynamic -> Void;
    public var stop: Void -> Void;
    public var play: Void -> Void;

	public var _xmouse(get, never):Float;
	public var _ymouse(get, never):Float;
}
*/
@:forward
abstract MovieClip(InternalMovieClip) from InternalMovieClip to InternalMovieClip {

	public function new(builder: MovieClipBuilder) {
		this = new InternalMovieClip(builder);
	}

    @:resolve
    public function resolve(name:String): MovieClip
        return cast this.get(name);

    @:op(a.b) public function fieldWrite(name:String, mc: MovieClip)
        return this.set(name,  {depth: 1, object: mc});
}


@:build(common.macros.Alias.build("x", "_x"))
@:build(common.macros.Alias.build("y", "_y"))
@:build(common.macros.Alias.build("width", "_width"))
@:build(common.macros.Alias.build("height", "_height"))
@:build(common.macros.Alias.build("visible", "_visible"))
@:build(common.macros.Alias.build("parent", "_parent"))
class InternalMovieClip extends Container {
    var builder: MovieClipBuilder;


    /*
     * Frames: List<Container>
     *   Each container contains all child DisplayObject
     *   When switching frame: assign objects to new container, make old container invisible, new one visible
     * 
     */
    //var frames: Array<Hash<SpriteObject>> = new Array();
    public var _currentframe(default, null):Int = 1;
    public var _totalframes:Int = 0;

    var frames: Array<Frame> = new Array();
    var sprites: Hash<DisplayObject> = new Hash();

	public var loop:Bool;
	var isPlaying:Bool = false;
    
	var _zIndex:Int;
    public var _name:String;

    
	public var _xmouse(get, never):Float;
	public var _ymouse(get, never):Float;
	public var _xscale(get, set):Float;
	public var _yscale(get, set):Float;
	public var _alpha(get, set):Float;
	public var _rotation(get, set):Float;

    // Forwarding Sprite attributes to children
    public var tint(default, set):Int;
	public var blendMode(default, set):BlendModes;


    // Simulate actionscript on flash frames
	public var stopOnFrame:Array<Int> = [];
	public var removeOnFrame:Null<Int> = null;
	public var removeObjOnFrame:Null<Int> = null;
	public var onFrame:IntHash<Void->Void> = new IntHash();
	public var onPress(default, set):Void->Void;
	public var onRollOut(default, set):Void->Void;
	public var onRollOver(default, set):Void->Void;
	public var onMouseMove(default, set):Void->Void;
	public var onDragOver:Void->Void; // Fixme
	public var onDragOut:Void->Void; // Fixme
	public var onRelease(default, set):Void->Void;
	public var onReleaseOutside(default, set):Void->Void;
	public var useHandCursor:Bool;
    
	public var smc(get, never):MovieClip;

	public function new(builder: MovieClipBuilder) {
		super();
        this.builder = builder;
	}

    public function get(name: String) {
        //return this.sprites.get(name);
		for (sprite in this.frames[this._currentframe - 1].sprites) {
			if (sprite.name == name)
				return sprite.sprite;
		}
		// Fallback to returning one of the sprites with the given names in any frame.
		// Not really correct, but best effort.
        return this.sprites.get(name);
    }

    public function set(name: String, sprite: {depth: Int, object: DisplayObject}): {depth: Int, object: DisplayObject} {
        this.sprites.set(name, sprite.object);
		if (this._totalframes == 0) {
			var sprites = new IntHash();
			sprites.set(sprite.depth, {name: name, sprite: sprite.object});
			addFrame(name, sprites);
		} else {
			this.frames[this._currentframe - 1].sprites.set(sprite.depth, {name: name, sprite: sprite.object});
		}

        return sprite;
    }

    public function setSprites(sprites: Hash<DisplayObject>) {
        this.sprites = sprites;
    }


    public function get_smc(): MovieClip {
        return cast this.sprites.get("smc");
    }

	public function update() {
		for (i in this.children) {
			if (Std.is(i, InternalMovieClip)) {
				(cast i).update();
			}
		}

		if (this.isPlaying && this.visible) {
			this.nextFrame();
		}
	}

    public function stop() {
		this.isPlaying = false;
	}

	public function play() {
		this.isPlaying = true;
	}

    public function gotoAndStop(frame:Dynamic) {
		if (Std.is(frame, Int)) {
			var f = Std.int(frame);
			if (_totalframes == 0) {
				this._currentframe = f;
				return;
			}

			if (f < 1)
				f = 1;
			else if (f > _totalframes)
				f = _totalframes;

			this._currentframe = f;
		} else if (Std.is(frame, String)) {
			for (i in 0...this._totalframes) {
				if (this.frames[i].name == Std.string(frame)) {
					this._currentframe = i + 1;
				}
			}
		} else {
			throw 'Invalid frame reference in goToAndStop: ' + frame;
		}
		
		this.isPlaying = false;
		showFrame();
	}

	public function gotoAndPlay(frame:Dynamic) {
		gotoAndStop(frame);
		play();
	}

    public function nextFrame() {
		if (this._totalframes == 0) {
			this._currentframe++;
			return;
		}

		if (this._currentframe == this._totalframes) {
			if (!this.loop) {
				stop();
				return;
			} else {
				this._currentframe = 0;
			}
		}

		this._currentframe++;
		showFrame();
	}

	public function showFrame(isInitialLoading: Bool = false) {
        // TODO: copy scale
		//var scale = untyped this.scale.clone();
		//this.texture = textures[this._currentframe - 1];
		//this.scale.copyFrom(scale);
		for (i in 0...this._totalframes) {
			if (i != this._currentframe - 1) {
				this.frames[i].container.visible = false;
			}
		}

        for (sprite in this.frames[this._currentframe - 1].sprites) {
            if (sprite.transform != null) {
                var t = sprite.transform;
				var tx = t.x;
				var ty = t.y;
				// This is horribly hacky, trying to preserve custom x/y set manually instead of overriding with file position..
				if (!isInitialLoading && (sprite.sprite.x != 0 || sprite.sprite.y != 0)) {
					tx = sprite.sprite.x;
					ty = sprite.sprite.y;
				}
                sprite.sprite.setTransform(tx,  ty, t.scaleX, t.scaleY, t.rotation, t.skewX, t.skewY, t.pivotX, t.pivotY);
            }
            this.frames[_currentframe - 1].container.addChild(sprite.sprite);
        }
        this.frames[this._currentframe - 1].container.visible = true;

        var e = this.width;
		if (this.stopOnFrame.contains(this._currentframe)) {
			stop();
		}

		if (this.removeOnFrame == this._currentframe) {
			stop();
			removeMovieClip();
		}
		if (this.removeObjOnFrame == this._currentframe) {
			stop();
		}

		if (this.onFrame.exists(this._currentframe)) {
			this.onFrame.get(this._currentframe)();
		}
	}

    public function addFrame(name: String, sprites: IntHash<{name: String, sprite: DisplayObject, ?transform: Transform}>) {
        this._totalframes++;
        var container = new Container();
        container.visible = false;
        frames.push({name: name, container: container, sprites: sprites});

        addChild(container);
        
        // Should we really auto-play?
        if (this._totalframes > 1) {
            this.loop = true;
            play();
        }
        /*
        // Preserve scaleX / scaleY
		var scaleX = this.scale.x;
		var scaleY = this.scale.y;
		this.scale.x = scaleX;
		this.scale.y = scaleY;
        */
    }

    private function zsort() {
		if (this.parent != null)
			parent.children.sort(function(a, b) return (untyped a)._zIndex - (untyped b)._zIndex);
	}
    public function getDepth():Int {
		return _zIndex;
	}
	public function swapDepths(with:Dynamic) {
		if (Std.is(with, Container)) {
			this.parent.swapChildren(this, with);
		} else {
			this._zIndex = with;
			this.zsort();
			// Int
		}
	}

    public function createEmptyMovieClip(newName:String = "smc", depth:Int = 0): MovieClip {
        var t = new MovieClip(this.builder);
		t._zIndex = depth;
		t._name = newName;
		addChild(t);
		t.zsort();
		return t;
	}

    public function attachBitmap(b:Texture, depth:Int) {
		var newSprite = new Sprite(b);

		for (f in this.frames) {
			if (f.sprites.exists(depth)) {
				var previousSprite = f.sprites.get(depth);
				f.container.removeChild(previousSprite.sprite);
				
				for (s in this.sprites.keyValueIterator()) {
					if (s.value == previousSprite.sprite) {
						this.sprites.set(s.key, newSprite);
					}
				}
				f.sprites.set(depth, {name: "bitmap", sprite: newSprite, transform: previousSprite.transform});
				f.container.addChild(newSprite);
			}
		}
		return newSprite;
	}

    public function attachMovieImage(identifier:String, image:String, newName:String = "smc", depth:Int = 0): MovieClip {
        var a = this.builder.buildMovieClip(identifier, newName);
        addChild(a);
		a._zIndex = depth;
		a.zsort();
        return a;
	}

    public function attachMovie(identifier:String, newName:String = "smc", depth:Int = 0):MovieClip {
		return attachMovieImage(identifier, "sprite", newName, depth);
	}

    public function removeMovieClip() {
		if (this.parent != null) {
			this.parent.removeChild(this);
		}

		this._name = null; // For DepthManager garbage collection
		for (i in this.children) {
			if (Std.is(i, InternalMovieClip))
				(cast i).removeMovieClip();
		}
	}





    // TODO: See if that's really needed
    
	public var centerX:Bool = false;

	public function get__xmouse():Float {
		return Manager.app.renderer.plugins.interaction.mouse.global.x;
	}

	public function get__ymouse():Float {
		return Manager.app.renderer.plugins.interaction.mouse.global.y;
	}

	public function get__rotation()
		return (rotation / (Math.PI * 2)) * 360;

	public function set__rotation(v:Float) {
		this.rotation = (v / 360) * Math.PI * 2;
		return v;
	}

	public function get__alpha()
		return alpha * 100;

	public function set__alpha(v:Float) {
		alpha = v / 100;
		return alpha;
	}

	public function get__xscale()
		return this.scale.x * 100;

	public function set__xscale(v:Float) {
		this.scale.x = v / 100;
		return v;
	}

	public function get__yscale()
		return this.scale.y * 100;

	public function set__yscale(v:Float) {
		this.scale.y = v / 100;
		return v;
	}

    
	public function set_onRollOut(v:Void->Void):Void->Void {
		this.onRollOut = v;
		this.interactive = v != null;
		if (v != null) {
			this.removeAllListeners("pointerout");
			this.addListener('pointerout', v);
		}

		return v;
	}

	public function set_onRollOver(v:Void->Void):Void->Void {
		this.onRollOver = v;
		this.interactive = v != null;
		if (v != null) {
			this.removeAllListeners("pointerover");
			this.addListener('pointerover', v);
		}
		return v;
	}

	public function set_onMouseMove(v:Void->Void):Void->Void {
		this.onMouseMove = v;
		this.interactive = v != null;
		if (v != null) {
			this.removeAllListeners("pointermove");
			this.addListener('pointermove', v);
		}
		return v;
	}

	public function set_onPress(v:Void->Void):Void->Void {
		this.onPress = v;
		this.interactive = v != null;
		if (v != null) {
			this.removeAllListeners("pointerdown");
			this.addListener('pointerdown', (e) -> {
				e.stopPropagation();
				v();
			});
		}

		return v;
	}

	public function set_onRelease(v:Void->Void):Void->Void {
		this.onRelease = v;
		this.interactive = v != null;
		if (v != null) {
			this.removeAllListeners("pointerup");
			this.addListener('pointerup', (e) -> {
				e.stopPropagation();
				v();
			});
		}

		return v;
	}

	public function set_onReleaseOutside(v:Void->Void):Void->Void {
		this.onReleaseOutside = v;
		this.interactive = v != null;
		if (v != null) {
			this.removeAllListeners("pointerupoutside");
			this.addListener('pointerupoutside', (e) -> {
				e.stopPropagation();
				v();
			});
		}

		return v;
	}


    // Forwarding attributes to children
    public function set_tint(value: Int):Int {
        for (s in this.sprites) {
			if (Std.is(s, InternalMovieClip))
				(cast s).tint = value;
			if (Std.is(s, Sprite))
				(cast s).tint = value;
        }
        this.tint = value;
        return value;
    }
    public function set_blendMode(value: BlendModes):BlendModes {
        for (s in this.sprites) {
			if (Std.is(s, InternalMovieClip))
				(cast s).blendMode = value;
			if (Std.is(s, Sprite))
				(cast s).blendMode = value;
        }
        this.blendMode = value;
        return value;
    }
}


    /**
     * MovieClip is an ASprite that has arbitrary members:
     *   - Other MovieClip
     *   - pixi.TextField
     *   - ..?
     * 
     * The root MovieClip has a builder that can be used to build other sprites.
     * It must be pass to children as other sprites can be constructed from there
     * 
     * 
     * Flash sprite has:
     *   - Text
     *   - (nested) sprites
     *   - Shape
     * 
     * Base resouces:
     *   - Fonts
     *   - Shapes
     * 
     * Frames in nested sprites:
     *   - Can manually or automatically advance frames independently from parent
     *   - .update() recursively called, but only takes care of advancing frame if autoplaying
     *   - Displaying a frame is simply updating its this.texture. If we fill this.textures, ASprite will take care of displaying the right one
     *   - visible can be used to hide sprites. It applies to children, if correctly declared.
     *   - 2 different sprites in different frames can share the same name
     * 
     * When building sprite:
     *   - Need create individual frames that MUST share underlying resources / sprites:
     *     - Need to assign 0 or 1 texture per frame from a shape.
     *     - Need to addChild to 
     * 
     * 
     * Examples:
     *   Sprite with 1 frame & 1 shape
     *     -> Sprite(texture=shape)
     *   
     *   Sprite with 2 frames & 1 shape each
     *     -> frames = [
     *         Sprite(texture=shape1)
     *         Sprite(texture=shape2)
     *       ]
     * 
     * Sprite with 1 frame & 1 shape + 1 text
     *     -> MovieClip(
     *           Sprite(texture=shape)
     *           Text(text)
     *        )
     * 
     * Sprite with 2 frames and same text used in both
     *     -> MovieClip(frames = [
     *        field -> Text(text)
     *        field -> Text(text)
     *       ])
     * 
     * sprite with another sprite:
     *   -> MovieClip(frames = [
     *        smc -> MovieClip(frames = [
     *          Sprite(texture=shape)
     *        ])
     *      ])
     * 
     * sprite with 2 frames with the same sprite:
     *   -> MovieClip(frames = [
     *        smc -> MovieClip(frames = [
     *          Sprite(texture=shape)
     *        ]),
     * 
     *        smc -> MovieClip(frames = [
     *          Sprite(texture=shape) // sprite moved for example
     *        ])
     *      ])
     * 
     * Switching frames:
     * nextFrame()
     *   frames[current].visible = false
     *   removeChild(frames[current++])
     *   frames[current].visible = true
     *   addChild(frames[current])
     * 
     * Field access:
     *   scrollNext.smc.smc._xscale *= -1 
     *   mc.field.text = "test";
     */

