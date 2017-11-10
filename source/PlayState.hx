package;

import backeroids.view.Asteroid;
import backeroids.view.PlayerShip;
import backeroids.view.Bullet;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.FlxG;
import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.data.Config;
using helix.core.HelixSpriteFluentApi;

class PlayState extends HelixState
{
	private var playerShip:PlayerShip;

	private static var NUM_INITIAL_ASTEROIDS:Int = Config.get("asteroids").initialNumber;
	private static var SECONDS_PER_ASTEROID:Int = Config.get("asteroids").secondsToSpawn;
	private static var SECONDS_TO_REVIVE:Int = Config.get("ship").secondsToRevive;

	private var asteroids = new FlxTypedGroup<Asteroid>();
	private var asteroidTimer = new FlxTimer();

	private var bullets = new FlxTypedGroup<Bullet>();

	override public function create():Void
	{
		super.create();
		
		this.playerShip = new PlayerShip();
		this.playerShip.setRecycleBulletCallback(function():Bullet
		{
			return bullets.recycle(Bullet);
		});
		resetShip();

		this.playerShip.collideResolve(this.asteroids, function(player:PlayerShip, asteroid:Asteroid)
		{
			// Player hits asteroid. Yay!
			this.playerShip.kill();
			new FlxTimer().start(SECONDS_TO_REVIVE, function(timer) {
				playerShip.revive();
				resetShip();
			});

			this.damageAndSplit(asteroid);
		});

		this.asteroidTimer.start(SECONDS_PER_ASTEROID, function(timer)
		{
			this.addAsteroid().respawn();
		}, 0);

		var asteroidsToCreate = NUM_INITIAL_ASTEROIDS;
		while (asteroidsToCreate-- > 0)
		{
			this.addAsteroid().respawn();
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.collide(bullets, asteroids, function(b:Bullet, asteroid:Asteroid) {
				b.kill();
				this.damageAndSplit(asteroid);
		});

		if (Config.get("features").collideAsteroidsWithAsteroids) {
		FlxG.collide(asteroids, asteroids, function(a1:Asteroid, a2:Asteroid)
		{			
			this.damageAndSplit(a1);
			this.damageAndSplit(a2);
		});
	}
	}
	
	private function addAsteroid():Asteroid
	{
		var asteroid = asteroids.recycle(Asteroid);
		return asteroid;
	}

	private function resetShip():Void
	{
		this.playerShip.move((this.width - playerShip.width) / 2, (this.height - playerShip.height) / 2);		
	}

	private function damageAndSplit(asteroid:Asteroid):Void
	{
		asteroid.damage();

		if (Config.get("features").splitAsteroidsOnDeath == true && asteroid.health <= 0 && asteroid.totalHealth > 1 && asteroid.type!= 'small')
		{
			for (i in 0 ... 2)
			{
				// Respawn at half health
				// Sets velocity and position				
				var newAsteroid = addAsteroid();

				switch asteroid.type {
					case "big":
						newAsteroid.setMediumAsteroid();
					case "medium":
						newAsteroid.setSmallAsteroid();
				}

				// Reset (move) to current destroyed position, offset so they don't
				// immediately destroy each other
				newAsteroid.x = asteroid.x;
				if (i == 0)
				{
					newAsteroid.x -=  (asteroid.width / 2);
				}
				else
				{
					 newAsteroid.x += (asteroid.width / 2);
				}
				newAsteroid.y = asteroid.y;
			}
		}
	}
}
