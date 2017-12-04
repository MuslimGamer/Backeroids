package backeroids.view;

import backeroids.interfaces.IProjectile;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import helix.data.Config;
import helix.core.HelixSprite;

class Bullet extends HelixSprite implements IProjectile
{
    public var baseVelocity:Float;
    private var hasAppearedOnscreen:Bool = false;
    private var expireTimer = new FlxTimer();

    public function new():Void
    {
        super(null, {width: 2, height: 8, colour: FlxColor.fromString('white')});
        this.width = 8;
        this.kill();
        this.baseVelocity = Config.get("gun").bulletVelocity;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (Config.get("features").wrapBullets) {
            FlxSpriteUtil.screenWrap(this);
        }
        else if (this.hasAppearedOnscreen && !this.isOnScreen())
        {
            this.kill();
        }

        if (this.isOnScreen())
        {
            this.hasAppearedOnscreen = true;
        }
    }

    public function shoot(angle:Float):Void
    {
        this.revive();
        this.angle = angle;

        this.velocity.set(0, -this.baseVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle);

        this.expireTimer.start(Config.get('gun').bulletExpireSeconds, function(timer)
        {
            this.kill();
        });
    }

    public function collide():Void
    {
        this.kill();
    }
}