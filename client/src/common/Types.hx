package common;
import pixi.core.display.DisplayObject;
import pixi.core.display.Container;

import mt.gx.HashEx;


typedef Transform = {
    ?x:Float,
    ?y:Float,
    ?scaleX:Float,
    ?scaleY:Float,
    ?rotation:Float,
    ?skewX:Float,
    ?skewY:Float,
    ?pivotX:Float,
    ?pivotY:Float
}

// Key is the depth
typedef Frame = {
    name: String,
    container: Container,
    sprites: IntHash<{name: String, sprite: DisplayObject, ?transform: Transform}>
}