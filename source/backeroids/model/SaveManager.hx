package backeroids.model;

import flixel.FlxG;

class SaveManager
{
    public static function save(levelNum)
    {
        var save = FlxG.save;
		if (save.data.currentLevel < levelNum + 1)
		{
			save.data.currentLevel = levelNum + 1;
			save.flush();
		}
    }
}