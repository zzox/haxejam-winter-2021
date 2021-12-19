package objects;

import flixel.FlxSprite;

using echo.FlxEcho;
using flixel.util.FlxSpriteUtil;

class Spikes extends FlxSprite {
    public function new (x:Int, y:Int, w:Int, h:Int) {
        super(x, y);
        // needed?
        makeGraphic(w, h, 0xff8595a1);
        visible = false;
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
