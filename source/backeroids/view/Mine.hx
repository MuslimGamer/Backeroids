package backeroids.view;

import backeroids.view.Projectile;
import flixel.util.FlxColor;
import helix.data.Config;

class Mine extends Projectile
{
    public function new():Void
    {
        super(null, {width: 10, height: 10, colour: FlxColor.fromString('red')}, Config.get("enemies").minedropper.mineVelocity);
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