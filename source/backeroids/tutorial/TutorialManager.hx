package backeroids.tutorial;

import backeroids.view.controls.MessageWindow;
import helix.data.Config;

// static class
class TutorialManager
{
    private static var tutorialData:Map<String, String> = null;

    private static function getTutorialMap():Map<String, String>
    {
        var values = new Map<String, String>();
        var text = openfl.Assets.getText(AssetPaths.tutorial__json);
        var regex = new EReg("//.*", "g");
        text = regex.replace(text, "");

        var json = haxe.Json.parse(text);
        var fields = Reflect.fields(json);
        for (i in 0 ... fields.length)
        {
            var name:String = fields[i];
			var value = Reflect.field(json, name);
            values.set(name, value);
        }
        return values;
    }

    // Returns the enemy name, or "introduction" for level 1
    public static function isTutorialRequired(levelNum:Int):String
    {
        if (tutorialData == null)
        {
           tutorialData = getTutorialMap();
        }

        if (levelNum == 1)
        {
            return "introduction";
        }

        var enemies = Config.get("enemies");
        for (n in Reflect.fields(enemies))
        {
            // Some are objects and some are simple ints/etc.
            var enemy:Dynamic = Reflect.field(enemies, n);
            // Assumes every enemy has "appearsOnLevel"
            if ((Type.typeof(enemy) == Type.ValueType.TObject) && Std.int(enemy.appearsOnLevel) == levelNum)
            {
                return enemy.name;
            }
        }
        return null;
    }

    public static function createTutorialWindow(tutorialName:String):MessageWindow
    {
        var tutorialText:String = tutorialData[tutorialName];
        var tutorialTextArray:Array<String> = tutorialText.split('@@@');
		var messageWindow:MessageWindow = new MessageWindow(tutorialTextArray);
        messageWindow.updateTextFieldSize();
        return messageWindow;
    }
}