package backeroids.view;

import backeroids.model.AsteroidType;
import backeroids.prototype.ICollidable;
import backeroids.SoundManager;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.util.FlxTimer;
import helix.core.HelixSprite;
import helix.data.Config;

class Asteroid extends HelixSprite implements ICollidable
{
    private static var random = new FlxRandom();
    private static var startingVelocity:Float;
    public var totalHealth(default, default):Int = 0;

    public var asteroidSize:Int = 0;
    public var type(default, null):AsteroidType = AsteroidType.Large;

    private var failSafeTimer = new FlxTimer();

    private var shouldWrap:Bool = false;

    public function new():Void
    {
        var type = random.bool() ? "1" : "2";
        var image = 'assets/images/asteroid-${type}.png';
        super(image);
        this.elasticity = Config.get("asteroids").collisionElasticity;
        startingVelocity = Config.get("asteroids").initialVelocity;
        this.kill();

        // TODO: Figure out how to deal with this in a non-hacky way.
        this.failSafeTimer.start(3, function(timer) 
        {
            if (!this.isOnScreen())
            {
                this.kill();
            } 
        }, 0);
        
        var maxVelocity = Config.get('asteroids').maxVelocity;
        this.maxVelocity.set(maxVelocity, maxVelocity);
    }

    public function setBackeroid():Asteroid
    {
        this.setHealth(Config.get("asteroids").backeroid.initialHealth);
        this.setScale(Config.get("asteroids").backeroid.scale, Config.get("asteroids").backeroid.scale);
        this.mass = Config.get("asteroids").backeroid.mass;
        this.type = AsteroidType.Backeroid;

        this.color = FlxColor.fromString('orange');

        return this;
    }

    public function setBigAsteroid():Asteroid
    {
        this.setHealth(Config.get("asteroids").big.initialHealth);
        this.setScale(Config.get("asteroids").big.scale, Config.get("asteroids").big.scale);
        this.mass = Config.get("asteroids").big.mass;
        this.type = AsteroidType.Large;

        this.color = FlxColor.fromString('gray');

        return this;
    }

    public function setMediumAsteroid():Asteroid
    {
        this.setHealth(Config.get("asteroids").medium.initialHealth);
        this.setScale(Config.get("asteroids").medium.scale, Config.get("asteroids").medium.scale);
        this.mass = Config.get("asteroids").medium.mass;
        this.type = AsteroidType.Medium;

        this.color = FlxColor.fromString('gray');

        return this;
    }

    public function setSmallAsteroid():Asteroid
    {
        this.setHealth(Config.get("asteroids").small.initialHealth);
        this.setScale(Config.get("asteroids").small.scale, Config.get("asteroids").small.scale);
        this.mass = Config.get("asteroids").small.mass;
        this.type = AsteroidType.Small;

        this.color = FlxColor.fromString('gray');

        return this;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        if (this.shouldWrap)
        {
            FlxSpriteUtil.screenWrap(this);
        }

        if (this.isOnScreen())
        {
            this.shouldWrap = true;
        }
    }

    public function respawn():Void
    {
        this.revive();
        this.shouldWrap = false;

        if (FlxG.random.float() < Config.get("asteroids").backeroidPercentage / 100)
		{
            this.setBackeroid();
        }
        else
        {
            this.setBigAsteroid();
        }
        this.processVelocity();
    }

    public function setHealth(health:Int):Void
    {
        this.health = health;
        this.totalHealth = health;
    }

    public function setScale(scaleX:Float, scaleY:Float):Void
    {
        this.scale.set(scaleX, scaleY);
        this.updateHitbox();
    }

    public function damage():Void
    {
        this.health -= 1;
        SoundManager.asteroidHit.play();
        if (this.health <= 0)
        {
            this.kill();
        }
    }

    public function splitOffFrom(asteroid:Asteroid, padding:Int):Void
    {
        var velocityMultiplier:Float = 1;

        if (asteroid.type == AsteroidType.Large)
        {
            this.setMediumAsteroid();	
            velocityMultiplier = Config.get('asteroids').medium.velocityMultiplier;
        }
        else if (asteroid.type == AsteroidType.Medium)
        {
            this.setSmallAsteroid();
            velocityMultiplier = Config.get('asteroids').small.velocityMultiplier / Config.get('asteroids').medium.velocityMultiplier;
        }
        else
        {
            this.kill();
        }

        this.x = asteroid.x;
        this.y = asteroid.y;

        var offsetX:Float = random.float(0, padding);
        var offsetY:Float = padding - offsetX;

        offsetX *= random.bool() ? -1 : 1;
        offsetY *= random.bool() ? -1 : 1;

        this.x += offsetX;
        this.y += offsetY;

        var velocityAngle = FlxPoint.weak(0, 0).angleBetween(FlxPoint.weak(offsetX, offsetY));
        this.velocity.rotate(FlxPoint.weak(0, 0), velocityAngle);
        this.velocity.x *= velocityMultiplier;
        this.velocity.y *= velocityMultiplier;
        this.velocity.addPoint(asteroid.velocity);
    }

    public function collide():Void 
    {
        // This is empty since asteroid collision proccessing happens in PlayState, not here.
        //TODO: Add low "thud" sound
    }

    private function processVelocity():Void
    {
        if (FlxG.random.bool())
		{
			this.processVelocityLeftRight();
		}
		else
		{
			this.processVelocityUpDown();
		}

        this.angularVelocity = (Math.abs(this.velocity.x) + Math.abs(this.velocity.y));
    }

    private function processVelocityUpDown():Void
    {
        if (FlxG.random.bool())
        {
            this.y = -this.height;
            this.velocity.y = startingVelocity / 2 + getVelocityRandomPercent();
        }
        else
        {
            this.y = FlxG.height + this.height;
            this.velocity.y = - startingVelocity / 2 + getVelocityRandomPercent();
        }
			
        this.x = FlxG.random.float() * (FlxG.width - width);
        this.velocity.x = getVelocityRandomPercent() * 2 - startingVelocity;
    }

    private function processVelocityLeftRight():Void
    {
        if (FlxG.random.bool())
        {
            this.x = -this.width;
            this.velocity.x = startingVelocity / 2 + getVelocityRandomPercent();
        }
        else
        {
            this.x = FlxG.width + this.width;
            this.velocity.x = - startingVelocity / 2 - getVelocityRandomPercent();
        }
			
        this.y = FlxG.random.float() * (FlxG.height - height);
        this.velocity.y = getVelocityRandomPercent() * 2 - startingVelocity;
    }

    private static function getVelocityRandomPercent():Float
    {
        return FlxG.random.float() * startingVelocity;
    }
}