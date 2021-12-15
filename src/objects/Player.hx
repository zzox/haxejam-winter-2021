package objects;

import echo.Body;
import flixel.FlxG;
import flixel.FlxSprite;

using echo.FlxEcho;

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
    var holds:HoldsObj = {
        left: 0,
        right: 0
    };

    var state:PlayerState = Ball;

    public function new (x:Int, y:Int) {
        super(x, y);
        this.add_body({ shape: { type: CIRCLE, radius: 8 }, elasticity: 1 });
        loadGraphic(AssetPaths.ball1__png, true, 16, 16);
        animation.add('roll', [0, 1], 12);
        animation.play('roll');
    }

    override public function update (elapsed:Float) {
        handleInput(elapsed);

        super.update(elapsed);

        var body:Body = this.get_body();
        trace(body.velocity);
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
