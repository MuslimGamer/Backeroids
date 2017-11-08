package;

import backeroids.view.Asteroid;
import backeroids.view.PlayerShip;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;
import helix.core.HelixState;

class PlayState extends HelixState
{
	private var playerShip:PlayerShip;

	private static inline var NUM_INITIAL_ASTEROIDS:Int = 3;
	private static inline var SECONDS_PER_ASTEROID:Int = 5;
	private static inline var SECONDS_TO_REVIVE:Int = 3;

	private var asteroids = new FlxTypedGroup<Asteroid>();
	private var asteroidTimer = new FlxTimer();

	override public function create():Void
	{
		super.create();
		
		this.playerShip = new PlayerShip();
		resetShip();

		this.playerShip.collideResolve(this.asteroids, function(player:PlayerShip, asteroid:Asteroid)
		{
			// Player hits asteroid. Yay!
			this.playerShip.kill();
			new FlxTimer().start(SECONDS_TO_REVIVE, function(timer) {
				playerShip.revive();
				resetShip();
			});
			asteroid.damage();
		});

		this.asteroidTimer.start(SECONDS_PER_ASTEROID, function(timer)
		{
			var asteroid = this.addAsteroid();

			asteroid.collideResolve(this.asteroids, function(a1:Asteroid, a2:Asteroid)
			{			
				trace("BAM!");
			});
		}, 0);

		var asteroidsToCreate = NUM_INITIAL_ASTEROIDS;
		while (asteroidsToCreate-- > 0)
		{
			this.addAsteroid();
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	private function addAsteroid():Asteroid
	{
		var asteroid = asteroids.recycle(Asteroid);
		asteroid.respawn();
		return asteroid;
	}

	private function resetShip():Void
	{
		this.playerShip.move((this.width - playerShip.width) / 2, (this.height - playerShip.height) / 2);		
	}
}
