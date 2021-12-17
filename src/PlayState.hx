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
import flixel.group.FlxGroup;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import objects.Box;
import objects.Player;
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

    var result:Results;
    public var player:Player;
    var terrain:FlxGroup;
    public var end:FlxSprite;

    override public function create() {
        super.create();

        camera.pixelPerfectRender = true;

        // MD:
        var map = new TiledMap(AssetPaths.map_1__tmx);

        FlxEcho.init({
            width: map.fullWidth,	// Make the size of your Echo world equal the size of your play field
            height: map.fullHeight,
            gravity_y: 600
        });
        FlxG.worldBounds.set(0, 0, map.fullWidth, map.fullHeight);

        terrain = new FlxGroup();
        add(terrain);

        createTriangles(map, SouthWest, terrain);
        createTriangles(map, SouthEast, terrain);
        createSquares(map, terrain);
        createEnd(map);
        // TODO: have anim in two parts
        add(end);

        add(createTileLayer(map, 'tiles'));

        player = new Player(8, 4, this);
        add(player);

        collisionListen();

        final hud = new Hud(this);
        add(hud);

        FlxG.camera.setScrollBounds(0, map.fullWidth, 0, map.fullHeight);
        FlxG.camera.follow(player);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        final world = FlxEcho.instance.world;
        if (player.x > world.width || player.x < -16 || player.y > world.height + BELOW_BOUNDS_GRACE) {
            lostLevel();
        }

        if (FlxG.overlap(player, end)) {
            winLevel();
        }
    }

    public function collisionListen () {
        player.listen(terrain, { enter: (_:Body, _:Body, d:Array<CollisionData>) -> {
            if (player.state == Glide) {
                lostLevel();
            } else {
                // play sound
            }
        }});
    }

    function createEnd (map:TiledMap) {
        final endPos = cast(map.getLayer('end'), TiledObjectLayer).objects[0];
        end = new FlxSprite(endPos.x, endPos.y);
        end.loadGraphic(AssetPaths.end_ring__png, true, 16, 64);
        end.animation.add('spin', [0, 1, 2, 3], 12);
        end.animation.play('spin');
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

    function lostLevel () {
        if (result != null) {
            return;
        }

        // show lose prompt
        // transition

        result = Lose;
        FlxG.camera.follow(null);
        player.visible = false;
        new FlxTimer().start(1, (_:FlxTimer) -> {
            FlxG.switchState(new PlayState());
        });
    }

    function winLevel () {
        if (result != null) {
            return;
        }

        // show win prompt
        // transition

        trace('won!');

        result = Win;
        FlxG.camera.follow(null);
    }
}
