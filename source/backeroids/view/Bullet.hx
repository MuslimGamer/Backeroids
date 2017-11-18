package backeroids.view;

import backeroids.model.IProjectile;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import helix.data.Config;
import helix.core.HelixSprite;

class Bullet extends HelixSprite implements IProjectile
{
    private var baseVelocity:Float;

    public function new():Void
    {
        super(null, {width: 2, height: 8, colour: FlxColor.fromString('white')});
        this.kill();
        this.baseVelocity = Config.get("gun").bulletVelocity;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (Config.get("features").wrapBullets) {
            FlxSpriteUtil.screenWrap(this);
        }
    }

    public function shoot(angle:Float):Void
    {
        this.revive();
        this.angle = angle;

        this.velocity.set(0, -this.baseVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle);
    }
}