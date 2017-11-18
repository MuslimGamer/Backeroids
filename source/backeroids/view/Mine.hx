package backeroids.view;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import helix.core.HelixSprite;
import helix.data.Config;

class Mine extends HelixSprite
{
    private var fuseTimer = new FlxTimer();

    public function new():Void
    {
        super(null, {width: 20, height: 20, colour: FlxColor.fromString('red')});
        this.kill();
        this.immovable = true;
    }

    public function lightFuse():Void
    {
        this.revive();
        this.fuseTimer.start(Config.get("enemies").minedropper.mineFuseSeconds, function(timer)
        {
            if (this.exists)
            {
                this.explode();
            }
        }, 1);
    }

    public function explode():Void
    {
        trace("BOOM!");
        this.kill();
    }
}