package backeroids.view;
 
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.input.FlxInput;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import backeroids.model.Gun;
import helix.core.HelixSprite;
import helix.data.Config;
using helix.core.HelixSpriteFluentApi;
using Lambda;

class PlayerShip extends HelixSprite
{
    // TODO: should be in config.json
    private static var ROTATION_VELOCITY:Int = Config.get("ship").rotationVelocity;
    private static var ACCELERATION:Int = Config.get("ship").acceleration;
    private static var DECELERATION_MULTIPLIER:Float = Config.get("ship").decelerationMultiplier;

    private var isTurning:Bool = false;

    private var gun:Gun;

    public function new():Void
    {
        this.gun = new Gun();

        super("assets/images/ship.png");
        this.onKeyDown(this.processControls);

        // Max velocity should really consider total velocity as a circle with radius r
        // But, HaxeFlixel doesn't work like that, so we use an approximation. This doesn't
        // work quite as well, since your max is (200, 200) if you're going diagonally.
        var maxVelocity:Int = Config.get("ship").maxVelocity;
        this.maxVelocity.set(maxVelocity, maxVelocity);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (!this.isTurning)
        {
            this.angularVelocity = 0;
        }

        FlxSpriteUtil.screenWrap(this);
        isTurning = false;
    }

    override public function revive():Void
    {
        super.revive();
        this.resetAcceleration();
        this.velocity.set(0, 0);
        this.gun = new Gun();
    }

    private function resetAcceleration():Void
    {
        this.acceleration.set(0, 0);
        this.angularVelocity = 0;
    }

    private function processControls(keys:Array<FlxKey>):Void
    {
        this.resetAcceleration();

        if (keys.has(FlxKey.LEFT) || keys.has(FlxKey.A))
        { 
            this.angularVelocity = -ROTATION_VELOCITY;
            isTurning = true;
        }
        else if (keys.has(FlxKey.RIGHT) || keys.has(FlxKey.D))
        { 
            this.angularVelocity = ROTATION_VELOCITY;
            isTurning = true;
        }

        if (keys.has(FlxKey.UP) || keys.has(FlxKey.W))
        { 
            this.accelerateForward(ACCELERATION); 
        }
        else if (keys.has(FlxKey.DOWN) || keys.has(FlxKey.S))
        {
            this.accelerateForward(Std.int(-ACCELERATION * DECELERATION_MULTIPLIER));
        }

        if (keys.has(FlxKey.SPACE) && this.gun.canFire()) {
            var bullet = new Bullet(this);
            this.onFireBullet(bullet);
            bullet.shoot();
        }
    }

    dynamic private function onFireBullet(bullet:Bullet):Void {}

    public function setOnFireBulletCallback(callback):Void
    {
        this.onFireBullet = callback;
    }

    private function accelerateForward(acceleration:Int):Void
    {
        this.acceleration.set(0, -acceleration); 
        this.acceleration.rotate(FlxPoint.weak(0, 0), this.angle);
    }
}