package;

import backeroids.view.Asteroid;
import backeroids.view.PlayerShip;
import backeroids.view.Bullet;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;
import helix.core.HelixState;
import helix.data.Config;

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
		
		this.playerShip = new PlayerShip(this);
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
			this.addAsteroid();
		}, 0);

		var asteroidsToCreate = NUM_INITIAL_ASTEROIDS;
		while (asteroidsToCreate-- > 0)
		{
			this.addAsteroid();
		}

		var numBullets:Int = 16;
		while (numBullets-- > 0)
		{
			bullets.add(this.addBullet());
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	public function addBullet():Bullet
	{
		var bullet = bullets.recycle(Bullet);
		bullet.collideResolve(this.asteroids, function(b:Bullet, asteroid:Asteroid)
		{
			trace("POW!");
			b.kill();
			asteroid.damage();
		});
		return bullet;
	}
	
	private function addAsteroid():Asteroid
	{
		var asteroid = asteroids.recycle(Asteroid);
		asteroid.collideResolve(this.asteroids, function(a1:Asteroid, a2:Asteroid)
		{			
			trace("BAM!");
		});
		asteroid.respawn();
		return asteroid;
	}

	private function resetShip():Void
	{
		this.playerShip.move((this.width - playerShip.width) / 2, (this.height - playerShip.height) / 2);		
	}
}
