package objects;

import echo.Body;
import echo.data.Options.BodyOptions;
import flixel.FlxG;
import flixel.FlxSprite;

using echo.FlxEcho;
using echo.data.Types;
using hxmath.math.Vector2;

typedef HoldsObj = {
    var left:Float;
    var right:Float;
    var up:Float;
    var down:Float;
}

enum PlayerState {
    Ball;
    Glide;
}

class Player extends FlxSprite { 
    static inline final BALL_ACCELERATION = 50;
    static inline final GLIDE_ACCELERATION = 250;
    static inline final MAX_GLIDE_Y_VEL = 100;

    var scene:PlayState;
    var state:PlayerState = Glide;
    public var compVel:Float = 0;
    var holds:HoldsObj = {
        left: 0,
        right: 0,
        up: 0,
        down: 0
    };

    public function new (x:Int, y:Int, scene:PlayState) {
        super(x, y);
        this.scene = scene;
        loadGraphic(AssetPaths.ball1__png, true, 16, 16);
        animation.add('ball-still', [0]);
        animation.add('roll-slow', [0, 1], 2);
        animation.add('roll-medium', [0, 1], 6);
        animation.add('roll-fast', [0, 1], 12);
        animation.add('glide', [2, 3], 12);
        animation.play('roll');

        switchState(true);
    }

    override public function update (elapsed:Float) {
        handleInput(elapsed);
        handleAnimation();

        // TODO: toggle mode?
        if (FlxG.keys.anyJustPressed([SPACE, Z, TAB])) {
            switchState();
        }

        var vel:Vector2 = this.get_body().velocity;

        if (state == Glide) {
            flipX = this.get_body().velocity.x < 0;

            // doing our own max velocity setting
            if (vel.y > MAX_GLIDE_Y_VEL) {
                this.get_body().velocity.y = MAX_GLIDE_Y_VEL;
            }

            if (vel.y < -MAX_GLIDE_Y_VEL) {
                this.get_body().velocity.y = -MAX_GLIDE_Y_VEL;
            }
        }

        trace(this.get_body().elasticity, state);

        super.update(elapsed);

        compVel = Math.sqrt(Math.pow(vel.x, 2) + Math.pow(vel.y, 2));
    }

    function switchState (skip = false) {
        final body = this.get_body();

        // needed?
        var bodyVelX = 0.;
        var bodyVelY = 0.;
        if (body != null) {
            bodyVelX = body.velocity.x;
            bodyVelY = body.velocity.y;
        }

        scene.removeMe();
        if (state == Ball) {
            this.add_body({
                velocity_x: bodyVelX,
                velocity_y: bodyVelY,
                shape: { type: CIRCLE, radius: 8 },
                elasticity: 1,
                gravity_scale: 0.1
            });
            animation.play('glide');
            flipX = false;
            state = Glide;
        } else {
            this.add_body({
                velocity_x: bodyVelX,
                velocity_y: bodyVelY,
                shape: { type: CIRCLE, radius: 8 },
                elasticity: 0
            });
            animation.play('roll');
            state = Ball;
            this.get_body().max_velocity.set(0, 100);
        }

        if (!skip) {
            scene.collisionListen();
        }
    }

    function handleAnimation () {
        if (state == Ball) {
            if (compVel < 1) {
                animation.play('ball-still');
            } else if (compVel < 25) {
                animation.play('roll-slow');
            } else if (compVel < 100) {
                animation.play('roll-medium');
            } else {
                animation.play('roll-fast');
            }
        }
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
        } else {
            final xVel:Float = this.get_body().velocity.x > 0 ? 1 : -1;
            var yVel:Float = 0;
            final upPressed = FlxG.keys.anyPressed([UP, W]);
            final downPressed = FlxG.keys.anyPressed([DOWN, S]);
            if (upPressed) {
                yVel = -1;
                holds.up += elapsed;
            } else {
                holds.up = 0;
            }

            if (downPressed) {
                yVel = 1;
                holds.down += elapsed;
            } else {
                holds.down = 0;
            }

            if (downPressed && downPressed) {
                if (holds.down > holds.down) {
                    yVel = -1;
                } else {
                    yVel = 1;
                }
            }

            // TODO: play different animations depending on going up or down
            if (yVel == 1) {
                this.get_body().acceleration.set(xVel * BALL_ACCELERATION, GLIDE_ACCELERATION);
            } else if (yVel == -1) {
                // weird function where you can only have upward acceleration if you're going fast enough
                final calcUpAccel = Math.abs(this.get_body().velocity.x) - GLIDE_ACCELERATION;
                this.get_body().acceleration.set(0, calcUpAccel > 0 ? -calcUpAccel : 0);
                this.get_body().drag.set(25, 0);
            } else {
                this.get_body().acceleration.set(0, 0);
            }
        }
    }
}
