package common;
import pixi.core.renderers.webgl.filters.Filter;
import pixi.filters.extras.GlowFilter as PixiGlowFilter;
import pixi.filters.blur.BlurFilter as PixiBlurFilter;
import pixi.filters.colormatrix.ColorMatrixFilter as PixiColorMatrixFilter;
import pixi.filters.alpha.AlphaFilter as PixiAlphaFilter;

class GlowFilter  {
    static public function create(color:Int, alpha:Float, blurX:Float, blurY:Float, ?strength:Float, ?quality:Int, ?inner:Bool, ?knockout:Bool): Array<Filter> {
        var glowFilter = new PixiGlowFilter(
            (blurX + blurY) / 2 / 10, // distance
            if (!inner) strength / 10 else 0, // outerStrength
            if (inner) strength / 10 else 0, // innerStrength
            color,
            quality * 10 / 15.0);

        // TODO: glow filters aren't rendering properly, disabling for now
        return [];
        if (alpha != 1) {
            var alphaFilter = new PixiAlphaFilter(alpha);
            return [glowFilter, alphaFilter];
        }
        return [glowFilter];
    }
}

class BlurFilter  {
    static public function create(blurX:Float, blurY:Float, quality:Float = 1): PixiBlurFilter {
        var filter = new PixiBlurFilter();
        filter.blurX = blurX;
        filter.blurY = blurY;
        filter.passes = Math.ceil(quality);
        return filter;
    }
}

class ColorMatrixFilter  {
    static public function create(matrix: Array<Float>): PixiColorMatrixFilter {
        var filter = new PixiColorMatrixFilter();
        return filter;
    }
}

@:native("PIXI.filters.DropShadowFilter")
extern class PixiDropShadowFilter extends Filter {
	function new(rotation: Float, distance:Float, blur: Float, color: Int, alpha: Float);
}

class DropShadowFilter {
    static public function create(distance:Float, angle:Float, color:Int, alpha:Float, blurX:Float, blurY:Float, ?strength:Float, ?quality:Float, ?inner:Bool, ?knockout:Bool, ?hideObject:Bool):PixiDropShadowFilter {
    // 3, 1.3
        return new PixiDropShadowFilter(angle, distance, (blurX + blurY) / 10, color, alpha);
    }
}