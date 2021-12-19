package data;

class Game {
    public static final levels = [
        { path: AssetPaths.small_jump__tmx, name: 'Jump one' },
        { path: AssetPaths.small_jump_with_spikes__tmx, name: 'Up and Over' },
        { path: AssetPaths.jump_with_bounces__tmx, name: 'Bouncing OK' },
        // fastball
        { path: AssetPaths.plink_on_through__tmx, name: 'Plink on Through' },
        { path: AssetPaths.longshot__tmx, name: 'Longshot' },
        { path: AssetPaths.tricky__tmx, name: 'Tricky' },
        { path: AssetPaths.gallows__tmx, name: 'Gallows' }
    ];

    public static final state:State = new State();

    public function new () {}
}

class State {
    public var level:Int = 0;
    public var seenLevel:Bool = false;

    public function new () {}
}
