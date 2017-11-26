package backeroids.states;

import backeroids.states.LevelSelectState;
import backeroids.SoundManager;
import helix.core.HelixState;
import flixel.FlxG;

class LoadingState extends HelixState
{
    override public function create():Void
    {
        SoundManager.init();
        FlxG.switchState(new LevelSelectState());
    }
}