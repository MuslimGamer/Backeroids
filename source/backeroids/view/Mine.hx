package backeroids.view;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import helix.core.HelixSprite;
import helix.data.Config;

class Mine extends HelixSprite
{
    public function new():Void
    {
        super(null, {width: 10, height: 10, colour: FlxColor.fromString('red')});
        this.kill();
    }

    public function shoot(angle:Float):Void
    {
        this.revive();
        this.angle = angle;

        this.velocity.set(0, -Config.get("enemies").minedropper.mineVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle);
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