import data.Game;
import display.Curtain;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import objects.CloudSet;
import openfl.Assets;

class MenuState extends FlxState {
    var canStart:Bool = true;
    var curtain:Curtain;

    override public function create () {
        super.create();

        // PROD: remove this vvv
        // requires `-debug` flag
        FlxG.debugger.visible = true;
        FlxG.debugger.drawDebug = true;

        FlxG.mouse.visible = false;

        camera.pixelPerfectRender = true;
        FlxG.scaleMode = new PixelPerfectScaleMode();

        final bg = new FlxSprite(0, 0, AssetPaths.background_2__png);
        bg.scrollFactor.set(0, 0);
        add(bg);

        var textBytes = Assets.getText(AssetPaths.miniset__fnt);
        var XMLData = Xml.parse(textBytes);
        var fontAngelCode = FlxBitmapFont.fromAngelCode(AssetPaths.miniset__png, XMLData);
        
        var text = new FlxBitmapText(fontAngelCode);
        text.text = 'Press SPACE or Z to Start';
        text.letterSpacing = -1;
        text.setPosition((FlxG.width - text.width) / 2, 770);
        text.visible = false;
        add(text);

        final logo = new FlxSprite(0, 0, AssetPaths.logo_transparent__png);
        logo.setPosition((FlxG.width - logo.width) * 0.5, 586);
        add(logo);

        add(new CloudSet());

        curtain = new Curtain();
        curtain.open(() -> {});
        add(curtain);

        FlxG.sound.defaultMusicGroup.sounds = [];

        Game.state.level = 0;
        Game.state.seenLevel = false;

        final envSound = FlxG.sound.play(AssetPaths.background__mp3, 0.75, true, FlxG.sound.defaultMusicGroup, false);
        envSound.persist = true;

        new FlxTimer().start(3.0, (_:FlxTimer) -> {
            text.visible = true;
            canStart = true;
        });

        FlxTween.tween(FlxG.camera, { "scroll.y": 570 }, 3);
    }
    
    override public function update (elapsed:Float) {
        super.update(elapsed);
        if (FlxG.keys.anyJustPressed([SPACE, Z]) && canStart) {
            startGame();
        }
    }

    function startGame () {
        curtain.close(() -> {
            FlxG.switchState(new PlayState());
        });
    }
}
