package objects;

import echo.Body;
import echo.data.Options.BodyOptions;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;

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

enum LrDir {
    Left;
    Right;
}

class Player extends FlxSprite { 
    static inline final BALL_ACCELERATION = 50;
    static inline final GLIDE_ACCELERATION = 500;
    static inline final MAX_GLIDE_Y_VEL = 100;
    static inline final LEAD_DISTANCE = 64;

    var scene:PlayState;
    public var state:PlayerState = Ball;
    public var compVel:Float = 0;
    public var xVel:Float = 0;
    public var yVel:Float = 0;
    public var canMove:Bool = false;
    public var lead:FlxSprite;
    var holds:HoldsObj = {
        left: 0,
        right: 0,
        up: 0,
        down: 0
    };

    var glideToBallSound:FlxSound;
    var ballToGlideSound:FlxSound;

    var dirLastPressed:LrDir = Right;

    public function new (x:Int, y:Int, scene:PlayState) {
        super(x, y);
        this.scene = scene;
        this.add_body({
            shape: { type: CIRCLE, radius: 8 },
            elasticity: 1,
        });
        loadGraphic(AssetPaths.ball1__png, true, 16, 16);
        animation.add('ball-still-right', [0]);
        animation.add('roll-slow-right', [0, 1], 2);
        animation.add('roll-medium-right', [0, 1], 6);
        animation.add('ball-still-left', [2]);
        animation.add('roll-slow-left', [2, 3], 2);
        animation.add('roll-medium-left', [2, 3], 6);
        animation.add('roll-fast-right', [4, 5, 6, 7], 12);
        animation.add('roll-fast-left', [8, 9, 10, 11], 12);
        animation.add('roll-very-fast-right', [4, 5, 6, 7], 30);
        animation.add('roll-very-fast-left', [8, 9, 10, 11], 30);
        animation.add('glide', [12, 13], 12);
        animation.add('glide-still', [14]);
        animation.play('ball-still');

        lead = new FlxSprite(x, y);
        lead.visible = false;
        lead.setSize(16, 16);

        glideToBallSound = FlxG.sound.load(AssetPaths.glide_to_ball__mp3, 1);
        ballToGlideSound = FlxG.sound.load(AssetPaths.ball_to_glide__mp3, 1);
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

        lead.setPosition(x + LEAD_DISTANCE, y);

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
            ballToGlideSound.play(true);
        } else {
            this.add_body({
                velocity_x: body.velocity.x,
                velocity_y: body.velocity.y,
                shape: { type: CIRCLE, radius: 8 },
                elasticity: 1,
                gravity_scale: 1
            });
            state = Ball;
            glideToBallSound.play(true);
        }

        scene.collisionListen();
    }

    function handleAnimation () {
        if (scene.result == Lose) {
            animation.play('glide-still');
        } else {
            final leftPressed = FlxG.keys.anyPressed([LEFT, A]);
            final rightPressed = FlxG.keys.anyPressed([RIGHT, D]);
            if (state == Ball) {
                if (compVel < 1) {    
                    if (leftPressed && !rightPressed) {
                        animation.play('roll-slow-left');
                    } else if (!leftPressed && rightPressed) {
                        animation.play('roll-slow-right');
                    } else {
                        if (dirLastPressed == Left) {
                            animation.play('ball-still-left');
                        } else if (dirLastPressed == Right) {
                            animation.play('ball-still-right');
                        }
                    }
                } else if (compVel < 25) {
                    if (dirLastPressed == Left) {
                        animation.play('roll-slow-left');
                    } else if (dirLastPressed == Right) {
                        animation.play('roll-slow-right');
                    }
                } else if (compVel < 100) {
                    if (dirLastPressed == Left) {
                        animation.play('roll-medium-left');
                    } else if (dirLastPressed == Right) {
                        animation.play('roll-medium-right');
                    }
                } else if (compVel < 250) {
                    if (dirLastPressed == Left) {
                        animation.play('roll-fast-left');
                    } else if (dirLastPressed == Right) {
                        animation.play('roll-fast-right');
                    }
                } else {
                    if (velocity.x < 0) {
                        animation.play('roll-very-fast-left');
                    } else {
                        animation.play('roll-very-fast-right');
                    }
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
                dirLastPressed = Left;
            } else {
                holds.left = 0;
            }

            if (rightPressed) {
                vel = 1;
                holds.right += elapsed;
                dirLastPressed = Right;
            } else {
                holds.right = 0;
            }

            if (leftPressed && rightPressed) {
                if (holds.right > holds.left) {
                    vel = -1;
                    dirLastPressed = Left;
                } else {
                    vel = 1;
                    dirLastPressed = Right;
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
