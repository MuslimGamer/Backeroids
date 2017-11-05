package;

import backeroids.view.PlayerShip;
import helix.core.HelixState;
import backeroids.view.Asteroid;
import flixel.group.FlxGroup;
import flixel.FlxObject;
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
			var asteroid = this.addAsteroid();
			asteroid.collideResolve(asteroids);
			asteroid.collideResolve(this, this.asteroidHitsShip);
		}
	}
	
	private function addAsteroid():Asteroid
	{
		var asteroid = asteroids.recycle(Asteroid);
		asteroid.respawn();
		return asteroid;
	}

	private function asteroidHitsShip(asteroid:FlxObject, ship:FlxObject):Void
	{
		ship.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
