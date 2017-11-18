package backeroids.view;

import backeroids.model.IProjectile;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import helix.core.HelixSprite;
import helix.data.Config;

class Mine extends HelixSprite implements IProjectile
{
    private var fuseTimer = new FlxTimer();

    public function new():Void
    {
        super(null, {width: 20, height: 20, colour: FlxColor.fromString('red')});
        this.kill();
        this.immovable = true;
    }

    public function shoot(angle:Float):Void
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