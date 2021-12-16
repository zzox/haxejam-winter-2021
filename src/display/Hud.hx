package display;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import openfl.Assets;

class Hud extends FlxGroup {
    var scene:PlayState;
    var speed:FlxBitmapText;

    public function new (scene:PlayState) {
        super();
        var textBytes = Assets.getText(AssetPaths.miniset__fnt);
        var XMLData = Xml.parse(textBytes);
        var fontAngelCode = FlxBitmapFont.fromAngelCode(AssetPaths.miniset__png, XMLData);

        speed = new FlxBitmapText(fontAngelCode);
        speed.color = 0xffffffff;
        speed.text = '0 pps';
        speed.letterSpacing = -1;
        // speed.scale.set(1, 2);
        speed.scrollFactor.set(0, 0);
        speed.setPosition(4, 4);
        add(speed);

        this.scene = scene;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        final speedText = Math.floor(scene.player.compVel);
        final xVel = Math.round(scene.player.xVel);
        final yVel = Math.round(scene.player.yVel);
        speed.text = '$speedText pps x:$xVel | y:$yVel';
    }
}
