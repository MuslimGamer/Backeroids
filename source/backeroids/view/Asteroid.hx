package backeroids.view;

import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import helix.core.HelixSprite;
import helix.data.Config;
using helix.core.HelixSpriteFluentApi;

class Asteroid extends HelixSprite
{
    private static var startingVelocity = Config.get("asteroids").initialVelocity;

    public function new():Void
    {
        super(null, {width: 60, height: 60, colour: FlxColor.fromString('gray')});
        this.elasticity = Config.get("asteroids").collisionElasticity;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        FlxSpriteUtil.screenWrap(this);
    }

    public function respawn():Void
    {
        if (FlxG.random.float() < 0.5)
		{
			this.processVelocityLeftRight();
		}
		else
		{
			this.processVelocityUpDown();
		}
		
		this.angularVelocity = (Math.abs(this.velocity.x) + Math.abs(this.velocity.y));
    }

    public function damage():Void
    {
        // Deduct "health", split in two, disintegrate, etc.
    }

    private function processVelocityUpDown():Void
    {
        if (FlxG.random.float() < 0.5)
        {
            this.processVelocityUp();
        }
        else
        {
            this.processVelocityDown();
        }
			
        this.x = FlxG.random.float() * (FlxG.width - width);
        this.velocity.x = getVelocityRandomPercent() * 2 - startingVelocity;
    }

    private function processVelocityLeftRight():Void
    {
        if (FlxG.random.float() < 0.5)
        {
            this.processVelocityLeft();
        }
        else
        {
            this.processVelocityRight();
        }
			
        this.y = FlxG.random.float() * (FlxG.height - height);
        this.velocity.y = getVelocityRandomPercent() * 2 - startingVelocity;
    }

    private function processVelocityUp():Void
    {
        this.y = -this.height;
        this.velocity.y = startingVelocity / 2 + getVelocityRandomPercent();
    }

    private function processVelocityDown():Void
    {
        this.y = FlxG.height + this.height;
        this.velocity.y = - startingVelocity / 2 + getVelocityRandomPercent();
    }

    private function processVelocityLeft():Void
    {
        this.x = -this.width;
        this.velocity.x = startingVelocity / 2 + getVelocityRandomPercent();
    }

    private function processVelocityRight():Void
    {
        this.x = FlxG.width + this.width;
        this.velocity.x = - startingVelocity / 2 - getVelocityRandomPercent();
    }

    private static function getVelocityRandomPercent():Float
    {
        return FlxG.random.float() * startingVelocity;
    }
}