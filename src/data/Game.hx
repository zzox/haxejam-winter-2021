package data;



class Game {
    public static final levels = [{
        path: AssetPaths.map_1__tmx
    }];

    public static final state:State = new State();

    public function new () {}
}

class State {
    public var level:Int = 0;
    public var seenLevel:Bool = false;

    public function new () {}
}
