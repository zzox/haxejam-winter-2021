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
    static inline final GLIDE_ACCELERATION = 500;
    static inline final MAX_GLIDE_Y_VEL = 100;

    var scene:PlayState;
    public var state:PlayerState = Ball;
    public var compVel:Float = 0;
    public var xVel:Float = 0;
    public var yVel:Float = 0;
    public var canMove:Bool = false;
    var holds:HoldsObj = {
        left: 0,
        right: 0,
        up: 0,
        down: 0
    };

    public function new (x:Int, y:Int, scene:PlayState) {
        super(x, y);
        this.scene = scene;
        this.add_body({
            shape: { type: CIRCLE, radius: 8 },
            elasticity: 1,
        });
        loadGraphic(AssetPaths.ball1__png, true, 16, 16);
        animation.add('ball-still', [0]);
        animation.add('roll-slow', [0, 1], 2);
        animation.add('roll-medium', [0, 1], 6);
        animation.add('roll-fast', [0, 1], 12);
        animation.add('glide', [2, 3], 12);
        animation.add('glide-still', [4]);
        animation.play('ball-still');
    }

    override public function update (elapsed:Float) {
        if (canMove) {
            handleInput(elapsed);
            if (FlxG.keys.anyJustPressed([SPACE, Z, TAB])) {
                switchState();
            }
        } else if (scene.result == Lose) {
            this.get_body().velocity.set(0, 0);
            this.get_body().acceleration.set(0, 0);
        }
        handleAnimation();

        var vel:Vector2 = this.get_body().velocity;

        if (state == Glide && scene.result != Lose) {
            flipX = this.get_body().velocity.x < 0;
        }

        super.update(elapsed);

        // for access from HUD
        compVel = Math.sqrt(Math.pow(vel.x, 2) + Math.pow(vel.y, 2));
        xVel = vel.x;
        yVel = vel.y;
    }

    function switchState (skip = false) {
        final body = this.get_body();

        if (state == Ball) {
            this.add_body({
                velocity_x: body.velocity.x,
                velocity_y: body.velocity.y,
                max_velocity_y: 200,
                shape: { type: CIRCLE, radius: 4 },
                elasticity: 0,
                gravity_scale: 0.1
            });
            animation.play('glide');
            flipX = false;
            state = Glide;
        } else {
            this.add_body({
                velocity_x: body.velocity.x,
                velocity_y: body.velocity.y,
                shape: { type: CIRCLE, radius: 8 },
                elasticity: 1,
                gravity_scale: 1
            });
            state = Ball;
        }

        scene.collisionListen();
    }

    function handleAnimation () {
        if (scene.result == Lose) {
            animation.play('glide-still');
        } else {
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
                this.get_body().drag.set(0, 0);
            } else if (yVel == -1) {
                // weird stuff where you can only have upward acceleration if you're going fast enough
                final calcUpAccel = Math.abs(this.get_body().velocity.x) - GLIDE_ACCELERATION * 0.33;
                this.get_body().acceleration.set(0, calcUpAccel > 0 ? -calcUpAccel : 0);
                this.get_body().drag.set(25, 0);
            } else {
                this.get_body().drag.set(0, 0);
                this.get_body().acceleration.set(0, 0);
            }
        }
    }
}
