package objects;

import echo.Body;
import flixel.FlxSprite;

using echo.FlxEcho;

class Player extends FlxSprite {
    public function new (x:Int, y:Int) {
        super(x, y);
        loadGraphic(AssetPaths.ball1__png, true, 16, 16);
        animation.add('roll', [0, 1], 12);
        animation.play('roll');
    }

    override public function update (elapsed:Float) {
        super.update(elapsed);

        var body:Body = this.get_body();
        trace(body.velocity);
    }
}
