package display;

import flixel.FlxSprite;

class Arrow extends FlxSprite {
    public function new () {
        super(0, 0);

        loadGraphic(AssetPaths.arrow__png, true, 16, 16);

        animation.add('right', [0]);
        animation.add('down-right', [1]);
        animation.add('down', [2]);
        animation.add('down-left', [3]);
        animation.add('left', [4]);
        animation.add('up-left', [5]);
        animation.add('up', [6]);
        animation.add('up-right', [7]);
        animation.play('right');
        visible = false;
    }
}
