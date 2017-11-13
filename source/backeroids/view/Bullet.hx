package backeroids.view;

import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxPoint;
import backeroids.view.Asteroid;
import backeroids.model.Gun;
import helix.core.HelixSprite;
import helix.data.Config;
using helix.core.HelixSpriteFluentApi;

class Bullet extends HelixSprite
{
    public function new():Void
    {
        super(null, {width: 2, height: 8, colour: FlxColor.fromString('white')});
        this.kill();
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

        this.velocity.set(0, -Config.get("gun").bulletVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle);
    }
}