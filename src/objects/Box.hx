package objects;

import flixel.FlxSprite;

using echo.FlxEcho;
using flixel.util.FlxSpriteUtil;

class Box extends FlxSprite {
    public function new (x:Int, y:Int, w:Int, h:Int) {
        super(x, y);
        makeGraphic(w, h, 0xff8595a1);
        this.add_body({
            mass: 0,
            shape: {
                type: RECT,
                height: h,
                width: w
            }
        });
    }
}
