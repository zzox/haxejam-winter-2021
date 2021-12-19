package objects;

import echo.Body;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import hxmath.math.Vector2;

using echo.FlxEcho;
using flixel.util.FlxSpriteUtil;

class Triangle extends FlxSprite {
    public function new(x:Float, y:Float, w:Int, h:Int, d:TriangleDir) {
        super(x, y);
        makeGraphic(w, h, 0x00FFFFFF);
        var verts = [ [0, 0], [w, 0], [w, h], [0, h] ];
        switch d {
            case NorthEast: verts.splice(3, 1);
            case NorthWest: verts.splice(2, 1);
            case SouthEast: verts.splice(0, 1);
            case SouthWest: verts.splice(1, 1);
        }
        this.drawPolygon([ for (v in verts) FlxPoint.get(v[0], v[1]) ], 0xff8595a1);
        this.add_body({
            mass: 0,
            shape: {
                type: POLYGON,
                vertices: [ for (v in verts) new Vector2(v[0] - w * 0.5, v[1] - h * 0.5) ],
            }
        });
    }
}

enum TriangleDir {
    NorthEast;
    NorthWest;
    SouthEast;
    SouthWest;
}
