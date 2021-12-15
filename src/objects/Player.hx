package objects;

import echo.Body;
import flixel.FlxG;
import flixel.FlxSprite;

using echo.FlxEcho;
using hxmath.math.Vector2;

typedef HoldsObj = {
    var left:Float;
    var right:Float;
}

enum PlayerState {
    Ball;
    Glide;
}

class Player extends FlxSprite {
    static inline final BALL_ACCELERATION = 50;

    var scene:PlayState;
    var state:PlayerState = Ball;
    public var compVel:Float = 0;
    var holds:HoldsObj = {
        left: 0,
        right: 0
    };

    public function new (x:Int, y:Int, scene:PlayState) {
        super(x, y);
        this.add_body({ shape: { type: CIRCLE, radius: 8 }, elasticity: 1 });
        loadGraphic(AssetPaths.ball1__png, true, 16, 16);
        animation.add('roll', [0, 1], 12);
        animation.add('glide', [0, 1], 12);
        animation.play('roll');

        this.scene = scene;
    }

    override public function update (elapsed:Float) {
        handleInput(elapsed);

        super.update(elapsed);

        var vel:Vector2 = scene.player.get_body().velocity;
        compVel = Math.sqrt(Math.pow(vel.x, 2) + Math.pow(vel.y, 2));
    }

    function handleInput (elapsed:Float) {
        if (state == Ball) {
            var vel:Float = 0.0;
            final leftPressed = FlxG.keys.anyPressed([LEFT, A]);
            final rightPressed = FlxG.keys.anyPressed([RIGHT, D]);
            if (leftPressed) {
                vel = -1;
                holds.left += elapsed;
            } else {
                holds.left = 0;
            }

            if (rightPressed) {
                vel = 1;
                holds.right += elapsed;
            } else {
                holds.right = 0;
            }

            if (leftPressed && rightPressed) {
                if (holds.right > holds.left) {
                    vel = -1;
                } else {
                    vel = 1;
                }
            }

            this.get_body().acceleration.set(vel * BALL_ACCELERATION, 0);
        }
    }
}
