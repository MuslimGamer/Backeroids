package backeroids.view;
 
import helix.core.HelixSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;

class PlayerShip extends HelixSprite
{
    public function new():Void
    {
        super("assets/images/ship.png");
    }
    
    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        // TODO: refactor into HelixSprite.onKeyPress method
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
		{
			this.angle -= 2.5;
		}
		else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
		{
			this.angle += 2.5;
		}

		this.acceleration.set();
		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
		{
			this.acceleration.set(0, -90);
			this.acceleration.rotate(FlxPoint.weak(0, 0), this.angle);
		}

        FlxSpriteUtil.screenWrap(this);
    }
}