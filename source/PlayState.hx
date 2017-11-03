package;

import backeroids.view.PlayerShip;
import flixel.FlxG;
import helix.core.HelixState;
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
			this.playerShip.angle -= 1;
		}
		else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
		{
			this.playerShip.angle += 1;
		}
	}
}
