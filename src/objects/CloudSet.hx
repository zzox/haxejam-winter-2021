package objects;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

class CloudSet extends FlxGroup {
    static inline final SMALL_CLOUDS = 128;
    static inline final BIG_CLOUDS = 64;
    static inline final SMALL_CLOUD_MAX = 5000;
    static inline final BIG_CLOUD_MAX = 10000;

    var smallClouds:FlxTypedGroup<Cloud>;
    var bigClouds:FlxTypedGroup<Cloud>;

    public function new () {
        super();

        smallClouds = new FlxTypedGroup<Cloud>();
        for (_ in 0...SMALL_CLOUDS) {
            final cloud = new Cloud(
                Math.random() * SMALL_CLOUD_MAX,
                Math.random() * 125 + 62,
                AssetPaths.small_clouds__png,
                32,
                16
            );
            cloud.velocity.set(Math.random() * -10 - 10);
            cloud.scrollFactor.set(0.25, 0.25);
            smallClouds.add(cloud);
        }

        bigClouds = new FlxTypedGroup<Cloud>();
        for (_ in 0...BIG_CLOUDS) {
            final cloud = new Cloud(
                Math.random() * BIG_CLOUD_MAX,
                Math.random() * 250 + 125,
                AssetPaths.big_clouds__png,
                64,
                32
            );
            cloud.velocity.set(Math.random() * -20 - 20);
            cloud.scrollFactor.set(0.50, 0.50);
            bigClouds.add(cloud);
        }

        add(smallClouds);
        add(bigClouds);
    }

    override public function update (elapsed:Float) {
        super.update(elapsed);

        smallClouds.forEach((cloud:Cloud) -> {
            if (cloud.x < -cloud.width) {
                cloud.x += SMALL_CLOUD_MAX;
            }
        });

        bigClouds.forEach((cloud:Cloud) -> {
            if (cloud.x < -cloud.width) {
                cloud.x += BIG_CLOUD_MAX;
            }
        });
    }
}

class Cloud extends FlxSprite {
    static final anims = ['one', 'two', 'three'];
    public function new (x:Float, y:Float, path:String, width:Int, height:Int) {
        super(x, y);
        loadGraphic(path, true, width, height);
        animation.add('one', [0]);
        animation.add('two', [1]);
        animation.add('three', [2]);
        animation.play(anims[Math.floor(Math.random() * 3)]);
    }
}
