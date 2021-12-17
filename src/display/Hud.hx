package display;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.text.FlxBitmapText;
import openfl.Assets;

class Hud extends FlxGroup {
    static inline final ARROW_GRACE = 16;
    var scene:PlayState;
    var speed:FlxBitmapText;
    var arrow:FlxSprite;
    static final arrowAngles = ['left', 'up-left', 'up', 'up', 'up-right', 'right', 'down-right', 'down', 'down', 'down-left', 'left'];

    public function new (scene:PlayState) {
        super();
        var textBytes = Assets.getText(AssetPaths.miniset__fnt);
        var XMLData = Xml.parse(textBytes);
        var fontAngelCode = FlxBitmapFont.fromAngelCode(AssetPaths.miniset__png, XMLData);

        speed = new FlxBitmapText(fontAngelCode);
        speed.color = 0xffffffff;
        speed.text = '0 pps';
        speed.letterSpacing = -1;
        speed.scrollFactor.set(0, 0);
        speed.setPosition(4, 4);
        add(speed);

        arrow = new Arrow();
        add(arrow);

        this.scene = scene;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        final speedText = Math.floor(scene.player.compVel);
        final xVel = Math.round(scene.player.xVel);
        final yVel = Math.round(scene.player.yVel);
        speed.text = '$speedText pps x:$xVel | y:$yVel';

        adjustDisplayArrow();
    }

    function adjustDisplayArrow () {
        final player = scene.player;
        final end = scene.end;
        final camera = FlxG.camera;

        final angle:Float = FlxAngle.angleBetween(player, end, true);
        final angleSimplified = Math.floor((angle + 196) / 36);
        final endDistance = Math.sqrt(Math.pow(player.x - end.x, 2) + Math.pow(player.x - end.x, 2));

        if ((end.x > camera.scroll.x + ARROW_GRACE && end.x < camera.scroll.x + camera.width - ARROW_GRACE &&
            end.y > camera.scroll.y + ARROW_GRACE && end.y < camera.scroll.y + camera.height - ARROW_GRACE) ||
            scene.result != null) {
            arrow.visible = false;
        } else {
            var arrowDistance = endDistance / 20;
            if (arrowDistance < 16) arrowDistance = 16;
            if (arrowDistance > 100) arrowDistance = 100;

            arrow.setPosition(
                player.x + arrowDistance * Math.cos(angle * Math.PI / 180),
                player.y + arrowDistance * Math.sin(angle * Math.PI / 180)
            );
            arrow.animation.play(arrowAngles[angleSimplified]);
            arrow.visible = true;
        }
    }
}
