import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite {
    public function new() {
        super();
        addChild(new FlxGame(480, 270, PreState, 1, 60, 60, true));
        // addChild(new FPS(900, 10, 0xffffff));
    }
}
