package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, backeroids.states.LevelSelectState, 1, 60, 60, true));
	}
}
