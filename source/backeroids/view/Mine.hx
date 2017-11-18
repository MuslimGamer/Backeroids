package backeroids.view;

import flixel.util.FlxColor;
import helix.data.Config;
import helix.core.HelixSprite;

class Mine extends HelixSprite
{
    public function new():Void
    {
        super(null, {width: 20, height: 20, colour: FlxColor.fromString('red')});
        this.kill();
        this.immovable = true;
    }

    public function explode():Void
    {
        if (this.exists)
        {
            trace("BOOM!");
            this.kill();
        }
    }
}