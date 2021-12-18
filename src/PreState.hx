import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.text.FlxBitmapText;
import openfl.Assets;

class PreState extends FlxState {
    override public function create () {
        super.create();

        // PROD: remove this vvv
        // requires `-debug` flag
        FlxG.debugger.visible = true;
        FlxG.debugger.drawDebug = true;

        FlxG.mouse.visible = false;

        camera.pixelPerfectRender = true;
        FlxG.scaleMode = new PixelPerfectScaleMode();

        var textBytes = Assets.getText(AssetPaths.miniset__fnt);
        var XMLData = Xml.parse(textBytes);
        var fontAngelCode = FlxBitmapFont.fromAngelCode(AssetPaths.miniset__png, XMLData);

        var text = new FlxBitmapText(fontAngelCode);
        text.text = 'Click to focus window';
        text.letterSpacing = -1;
        text.setPosition((FlxG.width - text.width) / 2, (FlxG.height - text.height) / 2);

        add(text);
    }
    
    override public function update (elapsed:Float) {
        if (FlxG.keys.justPressed.SPACE || (FlxG.mouse != null && FlxG.mouse.justPressed)) {
            startGame();
        }
    }

    function startGame () {
        FlxG.switchState(new PlayState());
    }
}
