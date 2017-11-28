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
        FlxG.switchState(new SplashState("assets/images/ui/splash-mg.png", "", function()
        {
            FlxG.switchState(new SplashState("assets/images/ui/splash-dg.png", "", function()
            {
                FlxG.switchState(new LevelSelectState());
            }));
        }));
    }
}