package;

import backeroids.view.PlayerShip;
import flixel.FlxG;
import helix.core.HelixState;
import flixel.math.FlxPoint;
using helix.core.HelixSpriteFluentApi;

class PlayState extends HelixState
{
	private var playerShip:PlayerShip;

	override public function create():Void
	{
		super.create();
		
		this.playerShip = new PlayerShip();		
		this.playerShip.move((this.width - playerShip.width) / 2, (this.height - playerShip.height) / 2);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// TODO: refactor into HelixSprite.onKeyPress method
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
		{
			this.playerShip.angle -= 2.5;
		}
		else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
		{
			this.playerShip.angle += 2.5;
		}

		this.playerShip.acceleration.set();
		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
		{
			this.playerShip.acceleration.set(0, -90);
			this.playerShip.acceleration.rotate(FlxPoint.weak(0, 0), this.playerShip.angle);
		}
	}
}
