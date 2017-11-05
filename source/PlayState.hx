package;

import backeroids.view.PlayerShip;
import helix.core.HelixState;
import backeroids.view.Asteroid;
import flixel.group.FlxGroup;
using helix.core.HelixSpriteFluentApi;

class PlayState extends HelixState
{
	private var playerShip:PlayerShip;

	private static var asteroids:FlxTypedGroup<Asteroid>;
	private static var initialAsteroids = 3;

	override public function create():Void
	{
		super.create();
		
		this.playerShip = new PlayerShip();		
		this.playerShip.move((this.width - playerShip.width) / 2, (this.height - playerShip.height) / 2);

		asteroids = new FlxTypedGroup<Asteroid>();
		this.add(asteroids);

		for (i in 0...initialAsteroids) 
		{
			this.addAsteroid();
		}
	}
	
	private function addAsteroid():Void
	{
		var asteroid = asteroids.recycle(Asteroid);
		asteroid.respawn();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
