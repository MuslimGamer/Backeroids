package backeroids.view;
 
import backeroids.SoundManager;
import backeroids.model.Gun;
import backeroids.states.PlayState;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.FlxG;
import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;
using helix.core.HelixSpriteFluentApi;
using Lambda;

class PlayerShip extends HelixSprite
{
    public var lives:Int;
    
    private static var ACCELERATION:Int;
    private static var DECELERATION_MULTIPLIER:Float;
    private static var DEADSTOP_VELOCITY:Float;
    private static var ROTATION_VELOCITY:Int;
    private static var SECONDS_TO_REVIVE:Int;
    private static var INVINCIBLE_SECONDS:Float;

    private var currentState:PlayState;
    private var isTurning:Bool = false;
    private var recycleBulletCallback:Void->Bullet;
    private var spawnedOn:GameTime;
    private var gun:Gun;
    private var shield:Shield;

    public function new(currentState:PlayState):Void
    {
        this.currentState = currentState;
        this.gun = new Gun();
        this.spawnedOn = GameTime.now();

        super("assets/images/ship.png");
        this.onKeyDown(this.processControls);

        // Max velocity should really consider total velocity as a circle with radius r
        // But, HaxeFlixel doesn't work like that, so we use an approximation. This doesn't
        // work quite as well, since your max is (200, 200) if you're going diagonally.
        var maxVelocity:Int = Config.get("ship").maxVelocity;
        this.maxVelocity.set(maxVelocity, maxVelocity);

        var conf = Config.get('ship');
        this.lives = conf.lives;

        ACCELERATION = conf.acceleration;
        DECELERATION_MULTIPLIER = conf.decelerationMultiplier;
        DEADSTOP_VELOCITY = conf.deadstopVelocity;
        ROTATION_VELOCITY = conf.rotationVelocity;
        SECONDS_TO_REVIVE = conf.secondsToRevive;
        INVINCIBLE_SECONDS = conf.invincibleAfterSpawnSeconds;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        FlxSpriteUtil.screenWrap(this);
    }

    override public function revive():Void
    {
        super.revive();
        this.resetAcceleration();
        this.velocity.set(0, 0);
        this.gun = new Gun();
        this.spawnedOn = GameTime.now();
        this.shield.resetShield();
    }

    private function resetAcceleration():Void
    {
        this.acceleration.set(0, 0);
        this.angularVelocity = 0;
    }

    private function processControls(keys:Array<FlxKey>):Void
    {
        if (this.currentState.isShowingTutorial)
        {
            return;
        }
        
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
            this.decelerate();
        }

        if (keys.has(FlxKey.SPACE) && this.gun.canFire())
        {
            this.shootBullet(this.angle);
        }

        if (FlxG.mouse.pressed && this.gun.canFire())
        {
            var mouseAngle = FlxPoint.weak(this.x, this.y).angleBetween(FlxG.mouse.getPosition());
            this.shootBullet(mouseAngle);
        }

        if (Config.get('ship').shield.enabled && this.shield.functional)
        {
            this.shield.move(this.x - this.width/2, this.y - this.height/2);
            if (FlxG.keys.justPressed.SHIFT)
            {
                this.shield.isActivated = !this.shield.isActivated;
                this.shield.visible = !this.shield.visible;
            }
        }
    }

    private function shootBullet(angle:Float):Void
    {
        var bullet = this.recycleBulletCallback();
        bullet.move(this.x + ((this.width - bullet.width) / 2), this.y + ((this.height - bullet.height) / 2));
        bullet.shoot(angle);
        SoundManager.playerShoot.play(true);
    }

    public function setRecycleBulletCallback(callback):Void
    {
        this.recycleBulletCallback = callback;
    }

    private function accelerateForward(acceleration:Int):Void
    {
        this.acceleration.set(0, -acceleration); 
        this.acceleration.rotate(FlxPoint.weak(0, 0), this.angle);
    }

    private function decelerate():Void
    {
        if (!this.velocity.equals(FlxPoint.weak(0, 0)))
        {
            if (Math.abs(this.velocity.x) + Math.abs(this.velocity.y) < DEADSTOP_VELOCITY * DECELERATION_MULTIPLIER)
            {
                this.velocity.x = 0;
                this.velocity.y = 0;
                return;
            }

            if (this.velocity.x != 0)
            {
                var velocityXDirection = -(Math.abs(this.velocity.x) / this.velocity.x);
                this.acceleration.x = velocityXDirection * Math.abs(this.velocity.x) * DECELERATION_MULTIPLIER;
            }

            if (this.velocity.y != 0)
            {
                var velocityYDirection = -(Math.abs(this.velocity.y) / this.velocity.y);
                this.acceleration.y = velocityYDirection * Math.abs(this.velocity.y) * DECELERATION_MULTIPLIER;
            }
        }
    }

    public function die(onReviveCallback:Void->Void):Void
    {
        this.lives -= 1;
        this.kill();
        SoundManager.playerExplode.play();
        if (this.lives > 0)
        {
            new FlxTimer().start(SECONDS_TO_REVIVE, function(timer) {
                this.revive();
                onReviveCallback();
                FlxFlicker.flicker(this, INVINCIBLE_SECONDS);
            });
        }
    }

    public function isInvincible():Bool
    {
        return (GameTime.now().elapsedSeconds - this.spawnedOn.elapsedSeconds <= INVINCIBLE_SECONDS);
    }

    public function setShield(shield:Shield):Void
    {
        this.shield = shield;
    }
}