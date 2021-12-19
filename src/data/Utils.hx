package data;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import openfl.utils.Assets;

inline function clamp (low:Float, high:Float, val:Float):Float
    return Math.max(low, Math.min(val, high));

inline function generateText ():FlxBitmapText {
    var textBytes = Assets.getText(AssetPaths.miniset__fnt);
    var XMLData = Xml.parse(textBytes);
    var fontAngelCode = FlxBitmapFont.fromAngelCode(AssetPaths.miniset__png, XMLData);

    return new FlxBitmapText(fontAngelCode);
}
