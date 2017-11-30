package backeroids.states;

import flixel.FlxSubState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;

class PauseSubState extends FlxSubState
{
    override function create():Void
    {
        super.create();

        var pauseText = new HelixSprite(null, {height: 1, width: 1, colour: 0x00000000});
        pauseText.alpha = 0;

        pauseText.textField = new FlxText(pauseText.x, pauseText.y, FlxG.width, 'PAUSED');
        pauseText.textField.setFormat(null, 36, 0xFFFFFFFF);
        add(pauseText.textField);

        pauseText.move(FlxG.width / 2 - pauseText.textField.textField.textWidth / 2, FlxG.height / 2 - pauseText.textField.textField.textHeight / 2);
    }

    override function update(elapsedSeconds):Void
    {
        super.update(elapsedSeconds);

        if (FlxG.keys.justPressed.P)
        {
            FlxTimer.globalManager.forEach(function(timer)
            {
                timer.active = true;
            });
            this.close();
        }
    }
}