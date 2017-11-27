package backeroids.tutorial;

import backeroids.view.controls.MessageWindow;
import helix.data.Config;

// static class
class TutorialManager
{
    private static var tutorialData:Map<String, String> = [
        "introduction" => "WASD",
        "shooter" => "shoot the shooter!",
        "kamikaze" => "KAMIKAZE!!!",
        "tank" => "TANKY!!!",
        "mines" => "MINE?!!?!?!"
    ];

    // Returns the enemy name, or "introduction" for level 1
    public static function isTutorialRequired(levelNum:Int):String
    {
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
		var messageWindow:MessageWindow = new MessageWindow(tutorialText);
        messageWindow.updateTextFieldSize();
        return messageWindow;
    }
}