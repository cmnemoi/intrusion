package common;

import pixi.core.text.Text as PixiText;
import pixi.core.text.DefaultStyle;
import pixi.core.math.shapes.Rectangle;


@:build(common.macros.Alias.build("x", "_x"))
@:build(common.macros.Alias.build("y", "_y"))
@:build(common.macros.Alias.build("width", "_width"))
@:build(common.macros.Alias.build("height", "_height"))
@:build(common.macros.Alias.build("visible", "_visible"))
@:build(common.macros.Alias.build("text", "htmlText"))
@:build(common.macros.Alias.build("width", "textWidth"))
// TODO: allow aliasing subfields: style.wordWrap -> wordWrap
class Text extends PixiText {
    var containerWidth: Float;
    var containerHeight: Float;
    var currentWidth: Float;
    var currentHeight: Float;
    var align: String;
    
	public var onChanged(default, set):String->Void;

    public var wordWrap(get, set): Bool;
    public var multiline(get, set): Bool;
    public var textColor(get, set): Dynamic;
    public var textHeight(get, set): Float;

    public function new (containerWidth: Float, containerHeight, initialText: String, align: String = "left", ?style:DefaultStyle) {
        super(initialText, style);
        this.align = align;
        this.containerWidth = containerWidth;
        this.containerHeight = containerHeight;

        this.currentWidth = containerWidth;
        this.currentHeight = containerHeight;
    }



    public function get_wordWrap(): Bool {
        return this.style.wordWrap;
    }
    public function set_wordWrap(value: Bool): Bool {
        this.style.wordWrap = value;
        return value;
    }

    public function get_multiline(): Bool {
        return this.style.breakWords;
    }
    public function set_multiline(value: Bool): Bool {
        this.style.breakWords = value;
        return value;
    }

    public function get_textColor(): Dynamic {
        return this.style.fill;
    }
    public function set_textColor(value: Dynamic): Dynamic {
        this.style.fill = value;
        return value;
    }

    public function get_textHeight(): Float {
        return this.style.lineHeight;
    }
    public function set_textHeight(value: Float): Float {
        this.style.lineHeight = value;
        return value;
    }
    
    public function set_onChanged(v:String->Void):String->Void {
        //TODO: Implement on Input
		return v;
	}


    /*
    public function setSize(width: Float, height: Float) {
        this.containerWidth = width;
        this.containerHeight = height;

    }

    public function setAlignment(align: String) {
        this.align = align;
    }
*/
    override function updateTransform(): Void {
        /*
        if (this.width != this.currentWidth) {
            switch (align) {
                case "left":
                case "right":
                    this.x = this.x + this.currentWidth - this.width;
                case "center":
                    this.x = this.x + (this.currentWidth - this.width) / 2;
            }
            this.currentWidth = this.width;
        }
        */

        /*
        if (this.height != this.currentHeight) {
            this.y = this.y + (this.currentHeight - this.height) / 2;
            this.currentHeight = this.height;
        }
        */
        super.updateTransform();
    }



    public function get_x(): Float {
        if (this.width != currentWidth) {
            switch (align) {
                case "left":
                case "right":
                    this.x = this.x + currentWidth - this.width;
                case "center":
                    this.x = this.x + (currentWidth - this.width) / 2;
            }
        }
        return this.x;
    }

    override public function getLocalBounds(?rect: Rectangle): Rectangle {
        return super.getLocalBounds(rect);
    }

    /*
    override public function getBounds(?skipUpdate: Bool, ?rect: Rectangle): Rectangle {
        var internalRect = rect ?? new Rectangle();
        super.getBounds(skipUpdate, internalRect);

        
        switch (align) {
            case "left":
            case "right":
                internalRect.x = internalRect.x + containerWidth - internalRect.width;
                internalRect.y = internalRect.y + containerHeight - internalRect.height;
            case "center":
                internalRect.x = internalRect.x + (containerWidth - internalRect.width) / 2;
                internalRect.y = internalRect.y + (containerHeight - internalRect.height) / 2;
        }
        
        return internalRect;
    }
*/
}
/*
class Text extends Container {
    var wrapped: PixiText;

    // Text properties
    public var text(get, set): String;
    public var style(get, set): DefaultStyle;
    // Sprite properties
    public var tint(get, set): Int;

    public function new (initialText: String, ?style:DefaultStyle) {
        super();
        wrapped = new PixiText(initialText, style);
        addChild(wrapped);
    }

    public function get_text(): String { return wrapped.text; }
    public function set_text(value: String): String { wrapped.text = value; return value; }
    public function get_style():DefaultStyle { return wrapped.style; }
    public function set_style(value: DefaultStyle):DefaultStyle { wrapped.style = value; return value; }
    
    public function get_tint(): Int { return wrapped.tint; }
    public function set_tint(value: Int): Int { wrapped.tint = value; return value; }

    public function set_anchor(x: Float, y: Float) {
        this.pivot.x = this.width / this.scale.x;
        this.pivot.y = this.width / this.scale.y;
    }
}
*/