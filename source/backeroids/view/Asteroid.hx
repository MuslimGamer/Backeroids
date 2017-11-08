package backeroids.view;

import helix.core.HelixSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
using helix.core.HelixSpriteFluentApi;

class Asteroid extends HelixSprite
{
    private static var startingVelocity = 90;

    public function new():Void
    {
        super(null, {width: 60, height: 60, colour: FlxColor.fromString('gray')});
        this.elasticity = 1;
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
        this.y = - 64 + this.offset.y;
        this.velocity.y = getHalfStartVelocity() + getVelocityRandomPercent();
    }

    private function processVelocityDown():Void
    {
        this.y = FlxG.height + this.offset.y;
        this.velocity.y = - getHalfStartVelocity() + getVelocityRandomPercent();
    }

    private function processVelocityLeft():Void
    {
        this.x = - 64 + this.offset.x;
        this.velocity.x = getHalfStartVelocity() + getVelocityRandomPercent();
    }

    private function processVelocityRight():Void
    {
        this.x = FlxG.width + this.offset.x;
        this.velocity.x = - getHalfStartVelocity() - getVelocityRandomPercent();
    }

    private static function getVelocityRandomPercent():Float
    {
        return FlxG.random.float() * startingVelocity;
    }

    private static function getHalfStartVelocity():Float
    {
        return startingVelocity / 2;
    }
}