package backeroids.view;

import flixel.math.FlxPoint;
import helix.core.HelixSprite;

class Projectile extends HelixSprite
{
    private var baseVelocity:Float;

    private function new(filename, colorDetails, v:Float):Void
    {
        super(filename, colorDetails);
        this.kill();
        this.baseVelocity = v;
    }

    public function shoot(angle:Float):Void
    {
        this.revive();
        this.angle = angle;

        this.velocity.set(0, -this.baseVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle);
    }
}