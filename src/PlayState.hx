import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.group.FlxGroup;
import objects.Box;
import objects.Player;
import objects.Triangle;

using echo.FlxEcho;
using flixel.util.FlxSpriteUtil;
using hxmath.math.Vector2;

class PlayState extends FlxState {
    override public function create() {
        super.create();

        camera.pixelPerfectRender = true;

        // MD:
        var map = new TiledMap(AssetPaths.map_1__tmx);

        FlxEcho.init({
            width: map.fullWidth,	// Make the size of your Echo world equal the size of your play field
            height: map.fullHeight,
            gravity_y: 400
        });

        final player = new Player(8, 4);
        add(player);

        var terrain = new FlxGroup();
        add(terrain);

        // MD: ?
        createTriangles(map, SouthWest, terrain);
        createTriangles(map, SouthEast, terrain);
        createSquares(map, terrain);

        player.listen(terrain); // callback for crashing

        FlxG.camera.setScrollBounds(0, map.fullWidth, 0, map.fullHeight);
        FlxG.camera.follow(player);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
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
}
