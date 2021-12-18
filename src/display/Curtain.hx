package display;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import haxe.Constraints.Function;

class Curtain extends FlxGroup {
    static inline final CIRCLE_DIST = 32;
    static inline final MAX_TIME = 0.25;

    public function new () {
        super();

        for (x in 0...(Math.ceil(FlxG.width / CIRCLE_DIST))) {
            for (y in 0...(Math.ceil(FlxG.height / CIRCLE_DIST))) {
                var circle = new FlxSprite(x * CIRCLE_DIST, y * CIRCLE_DIST);
                circle.makeGraphic(8, 8, 0xff060608);
                circle.loadGraphic(AssetPaths.big_circle__png);
                circle.scrollFactor.set(0, 0);
                add(circle);
            }
        }
    }

    public function open (callback:Function) {
        forEach((circle:FlxBasic) -> {
            new FlxTimer().start(Math.random() * MAX_TIME,
                (_:FlxTimer) -> {
                    FlxTween.tween(circle, { "scale.x": 0.01, "scale.y": 0.01 }, MAX_TIME, {
                        ease: FlxEase.sineOut,
                        onComplete: (_:FlxTween) -> {
                            circle.visible = false;
                        }
                    });
                }
            );
        });

        new FlxTimer().start(MAX_TIME, (_:FlxTimer) -> callback());
    }

    public function close (callback:Function) {
        forEach((circle:FlxBasic) -> {
            new FlxTimer().start(Math.random() * MAX_TIME,
                (_:FlxTimer) -> {
                    FlxTween.tween(circle, { "scale.x": 1, "scale.y": 1 }, MAX_TIME, {
                        ease: FlxEase.sineIn,
                        // onComplete: (_:FlxTween) -> {
                        //     circle.visible = false;
                        // }
                    });
                }
            );
        });

        new FlxTimer().start(MAX_TIME, (_:FlxTimer) -> callback());
    }
}