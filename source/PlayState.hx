package;

import backeroids.model.AsteroidType;
import backeroids.view.Asteroid;
import backeroids.view.Bullet;
import backeroids.view.PlayerShip;
import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.enemies.Shooter;
import backeroids.view.enemies.Tank;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;
import helix.core.HelixState;
import helix.data.Config;

class PlayState extends HelixState
{
	private static var NUM_INITIAL_ASTEROIDS:Int = Config.get("asteroids").initialNumber;
	private static var SECONDS_PER_ASTEROID:Int = Config.get("asteroids").secondsToSpawn;
	private static var SECONDS_PER_ENEMY:Int = Config.get("enemies").secondsToSpawn;

	private var asteroids = new FlxTypedGroup<Asteroid>();
	private var asteroidTimer = new FlxTimer();

	private var playerShip:PlayerShip;
	private var bullets = new FlxTypedGroup<Bullet>();

	private var enemies = new FlxTypedGroup<AbstractEnemy>();
	private var enemyBullets = new FlxTypedGroup<Bullet>();
	private var enemyTimer = new FlxTimer();

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
			// Player hits asteroid.
			this.killPlayerShip();

			if (asteroid.type != AsteroidType.Backeroid) {
				this.damageAndSplit(asteroid);
			}
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

		this.enemyTimer.start(SECONDS_PER_ENEMY, function(timer)
		{
			this.addEnemy();
		}, 0);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		FlxG.collide(enemies, playerShip, function(e:AbstractEnemy, p:PlayerShip)
		{
			this.killPlayerShip();
		});
		
		FlxG.collide(bullets, asteroids, function(b:Bullet, asteroid:Asteroid)
		{
				b.kill();
				if (asteroid.type != AsteroidType.Backeroid) {
					this.damageAndSplit(asteroid);
				}
		});

		FlxG.collide(bullets, enemies, function(bullet:Bullet, enemy:AbstractEnemy)
		{
				bullet.kill();
				enemy.health -= 1;
				if (enemy.health <= 0)
				{
					enemy.kill();
				}
		});

		FlxG.collide(enemies, asteroids, function(enemy:AbstractEnemy, asteroid:Asteroid)
		{
				this.damageAndSplit(asteroid);
		});

		FlxG.collide(enemyBullets, asteroids, function(enemyBullet:Bullet, asteroid:Asteroid)
		{
				enemyBullet.kill();
				this.damageAndSplit(asteroid);
		});

		FlxG.collide(enemyBullets, playerShip, function(enemyBullet:Bullet, p:PlayerShip)
		{
				enemyBullet.kill();
				this.killPlayerShip();
		});

		if (Config.get("features").collideAsteroidsWithAsteroids)
		{
			FlxG.collide(asteroids, asteroids, function(a1:Asteroid, a2:Asteroid)
			{			
				this.damageAndSplit(a1);
				this.damageAndSplit(a2);
			});
		}
	}

	private function killPlayerShip():Void
	{
		this.playerShip.die(this.resetShip);
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

		if (Config.get("features").splitAsteroidsOnDeath == true && asteroid.health <= 0 &&
			 asteroid.totalHealth > 1 && (asteroid.type == AsteroidType.Large || asteroid.type == AsteroidType.Medium))
		{
			for (i in 0 ... 2)
			{
				// Respawn at half health
				// Sets velocity and position				
				var newAsteroid = addAsteroid();

				if (asteroid.type == AsteroidType.Large)
				{
					newAsteroid.setMediumAsteroid();					
				}
				else if (asteroid.type == AsteroidType.Medium)
				{
					newAsteroid.setSmallAsteroid();
				}
				else
				{
					newAsteroid.kill();
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

	private function addShooter():Void
	{
		this.enemies.add(new Shooter(function(eb:Bullet):Void
		{
			enemyBullets.add(eb);
		}));
	}

	private function addTank():Void
	{
		this.enemies.add(new Tank(this.playerShip));		
	}

	private function addEnemy():Void
	{
		if (FlxG.random.float() < 0.5)
		{
			this.addShooter();
		}
		else
		{
			this.addTank();
		}
	}
}
