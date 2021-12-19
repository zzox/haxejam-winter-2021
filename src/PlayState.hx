import data.Game;
import data.Utils;
import display.Curtain;
import display.Hud;
import echo.Body;
import echo.data.Data.CollisionData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import objects.Box;
import objects.CloudSet;
import objects.Player;
import objects.Spikes;
import objects.Triangle;

using echo.FlxEcho;
using flixel.util.FlxSpriteUtil;
using hxmath.math.Vector2;

enum Results {
    Win;
    Lose;
}

class PlayState extends FlxState {
    static final BELOW_BOUNDS_GRACE = 80;

    public var result:Results;
    public var player:Player;
    var terrain:FlxGroup;
    var spikes:FlxGroup;
    public var end:FlxSprite;

    var flyEmitter:FlxEmitter;
    var deathEmitter:FlxEmitter;
    var winEmitter:FlxEmitter;
    var curtain:Curtain;

    var dingSound:FlxSound;
    var winSound:FlxSound;
    var deathSound:FlxSound;

    override public function create() {
        super.create();

        camera.pixelPerfectRender = true;

        // MD:
        final level = Game.levels[Game.state.level];
        var map = new TiledMap(level.path);

        FlxEcho.init(
            {
                width: map.fullWidth,
                height: map.fullHeight,
                gravity_y: 600
            },
            true
        );
        FlxG.worldBounds.set(0, 0, map.fullWidth, map.fullHeight);

        // each level moves bg left
        final bg = new FlxSprite(Game.state.level * -20, 0, AssetPaths.background_2__png);
        bg.scrollFactor.set(0, 0);
        add(bg);

        add(new CloudSet());

        terrain = new FlxGroup();
        add(terrain);

        spikes = new FlxGroup();
        add(spikes);

        createTriangles(map, SouthWest, terrain);
        createTriangles(map, SouthEast, terrain);
        createSquares(map, terrain);
        createEnd(map);
        createSpikes(map, spikes);
        // TODO: have anim in two parts
        add(end);

        add(createTileLayer(map, 'tiles'));

        flyEmitter = createEmitter(0xff8595a1, 16, 'disolve-2', 'fly');
        deathEmitter = createEmitter(0xff757161, 32, 'disolve', 'death');
        winEmitter = createEmitter(0xffdad45e, 32, 'shine', 'win');
        winEmitter.setPosition(end.x + end.width * 0.5, end.y + end.height * 0.5);
        add(flyEmitter);
        add(winEmitter);

        player = new Player(16, 4, this);
        add(player);

        add(deathEmitter);

        collisionListen();

        final hud = new Hud(this);
        add(hud);

        curtain = new Curtain();
        curtain.open(() -> {
            if (Game.state.seenLevel) { 
                seenLevel();
            } else {
                showLevel(Math.sqrt(Math.pow(player.x - end.x, 2) + Math.pow(player.x - end.x, 2)));
            }
        });
        add(curtain);

        FlxG.camera.setScrollBounds(0, map.fullWidth, 0, map.fullHeight);

        // TODO: put in menu state
        if (FlxG.sound.defaultMusicGroup.sounds.length < 2) {
            final envSound = FlxG.sound.play(AssetPaths.background__mp3, 1, true, FlxG.sound.defaultMusicGroup, false);
            final bgSound = FlxG.sound.play(AssetPaths.win__mp3, 0.5, true, FlxG.sound.defaultMusicGroup, false);
            envSound.persist = true;
            bgSound.persist = true;
        }

        dingSound = FlxG.sound.load(AssetPaths.ding__mp3, 0.75);
        winSound = FlxG.sound.load(AssetPaths.win_hit__mp3, 0.75);
        deathSound = FlxG.sound.load(AssetPaths.death__mp3, 0.75);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        final world = FlxEcho.instance.world;
        if (player.x > world.width || player.x < -16 || player.y > world.height + BELOW_BOUNDS_GRACE) {
            lostLevel('out');
        }

        if (FlxG.overlap(player, end)) {
            winLevel();
        }

        if (FlxG.keys.anyJustPressed([ESCAPE, R])) {
            lostLevel('restart');
        }

        flyEmitter.setPosition(player.getMidpoint().x, player.getMidpoint().y);
        if (player.canMove && player.state == Glide) {
            flyEmitter.emitting = true;
        } else {
            flyEmitter.emitting = false;
        }
    }

    public function collisionListen () {
        player.listen(terrain, { enter: (playerBody:Body, _:Body, d:Array<CollisionData>) -> {
            if (player.state == Glide) {
                lostLevel('collision');
            } else {
                final bounceVel = Math.abs(player.xVel - playerBody.velocity.x) + Math.abs(player.yVel - playerBody.velocity.y);
                dingSound.volume = clamp(0, 1, bounceVel / 1000);
                dingSound.play(true);
            }
        }});

        player.listen(spikes, { enter: (_:Body, _:Body, d:Array<CollisionData>) -> {
            lostLevel('collision');
        }});
    }

    function createEnd (map:TiledMap) {
        final endPos = cast(map.getLayer('end'), TiledObjectLayer).objects[0];
        end = new FlxSprite(endPos.x, endPos.y);
        end.loadGraphic(AssetPaths.end_ring__png, true, 16, 64);
        end.offset.set(0, 8);
        end.setSize(16, 48);
        end.animation.add('spin', [0, 1, 2, 3], 12);
        end.animation.add('spin-fast', [0, 1, 2, 3], 48);
        end.animation.play('spin');
    }

    function createSpikes (map:TiledMap, spikes:FlxGroup) {
        final spikesLayer = map.getLayer('spikes');
        if (spikesLayer != null) {
            final spikesObject = cast(spikesLayer, TiledObjectLayer).objects;
            spikesObject.map((t: TiledObject) -> {
                final spikeSquare = new Spikes(t.x, t.y, t.width, t.height);
                spikeSquare.add_to_group(spikes);
                return spikeSquare;
            });
        }
    }

    function createTriangles (map:TiledMap, dir:TriangleDir, terrain:FlxGroup) {
        final name:String = switch (dir:TriangleDir) {
            case NorthEast: 'ne-triangles';
            case NorthWest: 'nw-triangles';
            case SouthEast: 'se-triangles';
            case SouthWest: 'sw-triangles';
        }

        final tris = map.getLayer(name);
        if (tris != null) {
            final triObjects = cast(map.getLayer(name), TiledObjectLayer).objects;
            triObjects.map((t: TiledObject) -> {
                final tri = new Triangle(t.x, t.y, t.width, t.height, dir);
                tri.add_to_group(terrain);
                return tri; // needed to prevent "Cannot use Void as value"
            });
        }
    }

    function createSquares (map:TiledMap, terrain:FlxGroup) {
        final squares = map.getLayer('squares');
        if (squares != null) {
            final squareObject = cast(map.getLayer('squares'), TiledObjectLayer).objects;
            squareObject.map((t: TiledObject) -> {
                final square = new Box(t.x, t.y, t.width, t.height);
                square.add_to_group(terrain);
                return square;
            });
        }
    }

    function createTileLayer (map:TiledMap, layerName:String):Null<FlxTilemap> {
        var layerData = map.getLayer(layerName);
        if (layerData != null) {
            var layer = new FlxTilemap();
            layer.loadMapFromArray(cast(layerData, TiledTileLayer).tileArray, map.width, map.height,
                AssetPaths.tiles__png, map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);

            layer.useScaleHack = false;
            return layer;
        }
        return null;
    }

    function lostLevel (type) {
        if (result != null) {
            return;
        }

        result = Lose;
        FlxG.camera.follow(null);
        player.canMove = false;
        curtain.close(() -> {});
        new FlxTimer().start(1, (_:FlxTimer) -> {
            FlxG.switchState(new PlayState());
        });

        if (type == 'collision') {
            showPrompt('fail');
            deathSound.play();
            deathEmitter.start(true, 1, 0);
            deathEmitter.setPosition(player.getMidpoint().x, player.getMidpoint().y);
        } else if (type == 'out') {
            showPrompt('out');
            deathSound.play();
        }
    }

    function winLevel () {
        if (result != null) {
            return;
        }

        end.animation.play('spin-fast');

        result = Win;
        FlxG.camera.follow(null);
        Game.state.seenLevel = false;
        Game.state.level++;
        winEmitter.start(true, 1, 0);

        showPrompt('win');
        winSound.play();

        new FlxTimer().start(1, (_:FlxTimer) -> {
            curtain.close(() -> {});
        });

        new FlxTimer().start(2, (_:FlxTimer) -> {
            FlxG.switchState(new PlayState());
        });
    }

    function showPrompt (name:String) {
        var path = switch (name) {
            case 'out': AssetPaths.out_prompt__png;
            case 'fail': AssetPaths.fail_prompt__png;
            case 'win': AssetPaths.win_prompt__png;
            case _: null;
        }

        final promptSprite = new FlxSprite(0, 0, path);
        promptSprite.scale.set(4, 4);
        promptSprite.setGraphicSize();
        promptSprite.setPosition(
            -promptSprite.width,
            FlxG.camera.height * 0.5 - promptSprite.height * 0.5
        );
        promptSprite.scrollFactor.set(0, 0);
        add(promptSprite);

        FlxTween.tween(promptSprite, { x: FlxG.camera.width * 0.5 - promptSprite.width * 0.5 }, 0.125).then(
            // weird math vvv
            FlxTween.tween(promptSprite, { x: FlxG.camera.width + promptSprite.width * 2 }, 0.125, { startDelay: name == 'win' ? 1 : 0.5 })
        );
    }

    function showLevel (dist:Float) {
        new FlxTimer().start(0.5, (_:FlxTimer) -> {
            // FlxTween.tween(camera, { zoom: 0.5 }, 0.5).then(FlxTween.tween(camera, { zoom: 1 }, 0.5, { startDelay: dist / 2500 * 2 }));
            FlxTween.tween(
                camera,
                {
                    "scroll.x": end.x - (camera.width * 0.5),
                    "scroll.y": end.y - (camera.height * 0.5),
                },
                0.5 + dist / 2500,
                { ease: FlxEase.cubeInOut }
            ).then(FlxTween.tween(
                camera,
                {
                    "scroll.x": 0,
                    "scroll.y": 0,
                },
                0.5 + dist / 2500,
                {
                    ease: FlxEase.cubeInOut,
                    onComplete: (_:FlxTween) -> {
                        seenLevel();
                    }
                }
            ));
        });
    }

    function seenLevel () {
        FlxG.camera.follow(player.lead);
        player.canMove = true;
        Game.state.seenLevel = true;
    }

    function createEmitter (color:Int, size:Int, anim:String, type:String):FlxEmitter {
        final emitter = new FlxEmitter();
        emitter.lifespan.set(0.5, 1);

        switch (type) {
            case 'death':
                emitter.velocity.set(-60, -60, 60, 60);
                emitter.drag.set(90, 90, 90, 90);
            case 'win':
                emitter.velocity.set(-60, -240, 60, 240);
                emitter.drag.set(60, 60, 60, 60);
            case 'fly':
                emitter.velocity.set(-5, -5, 5, 5);
            case _: null;
        }
        emitter.launchMode = FlxEmitterMode.SQUARE;
        for (_ in 0...size) {
            var p = new FlxParticle();
            p.loadGraphic(AssetPaths.particles__png, true, 5, 5);
            p.animation.add('disolve', [0, 1, 2, 3, 3, 4, 5, 6], 12, false);
            p.animation.add('disolve-2', [1, 2, 3, 4, 5, 6], 30, false);
            p.animation.add('shine', [7, 8], 18);
            p.animation.play(anim);
            p.exists = false;
            emitter.add(p);
        }
        emitter.color.set(cast color);
        if (type == 'fly') {
            emitter.start(false, 0.125, 1);
        }
        emitter.emitting = false;
        return emitter;
    }
}
