package backeroids.states;

import backeroids.model.AsteroidType;
import backeroids.view.Asteroid;
import backeroids.view.Bullet;
import backeroids.view.Mine;
import backeroids.view.PlayerShip;
import backeroids.view.Explosion;
import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.enemies.Shooter;
import backeroids.view.enemies.Tank;
import backeroids.view.enemies.Kamikaze;
import backeroids.view.enemies.MineDropper;
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

	private var explosions = new FlxTypedGroup<Explosion>();

	private var enemies = new FlxTypedGroup<AbstractEnemy>();
	private var enemyBullets = new FlxTypedGroup<Bullet>();
	private var enemyMines = new FlxTypedGroup<Mine>();
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

		if (Config.get("asteroids").enabled)
		{
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

		if (Config.get("enemies").enabled)
		{
			this.enemyTimer.start(SECONDS_PER_ENEMY, function(timer)
			{
				this.addEnemy();
			}, 0);
		}
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
				enemy.damage();
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

		FlxG.collide(enemyBullets, enemyMines, function(enemyBullet:Bullet, mine:Mine)
		{
				enemyBullet.kill();
				mine.explode();
		});

		FlxG.collide(enemyMines, asteroids, function(mine:Mine, asteroid:Asteroid)
		{
			mine.explode();
		});

		FlxG.collide(enemyMines, playerShip, function(mine:Mine, p:PlayerShip)
		{
			mine.explode();
		});

		FlxG.collide(enemyMines, bullets, function(mine:Mine, bullet:Bullet)
		{
			bullet.kill();
			mine.explode();
		});

		FlxG.collide(explosions, playerShip, function(explosion:Explosion, player:PlayerShip)
		{
			this.killPlayerShip();
		});

		FlxG.collide(explosions, asteroids, function(explosion:Explosion, asteroid:Asteroid)
		{
			this.damageAndSplit(asteroid);
		});

		FlxG.collide(explosions, enemies, function(explosion:Explosion, enemy:AbstractEnemy)
		{
			enemy.damage();
		});

		FlxG.collide(enemies);

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
		this.enemies.add(new Shooter(function():Bullet
		{
			return enemyBullets.recycle(Bullet);
		}));
	}

	private function addTank():Void
	{
		this.enemies.add(new Tank(this.playerShip));		
	}

	private function addKamikaze():Void
	{
		this.enemies.add(new Kamikaze(this.playerShip));
	}

	private function addMineDropper():Void
	{
		this.enemies.add(new MineDropper(function():Mine
		{
			var mine = enemyMines.recycle(Mine);
			mine.setRecycleExplosion(function():Explosion
			{
				return explosions.recycle(Explosion).resetView();
			});
			return mine;
		}));
	}

	private function addEnemy():Void
	{
		var callbacks = new Array<Void->Void>();
		var conf = Config.get("enemies");
		if (conf.shooter.enabled)
		{
			callbacks.push(this.addShooter);
		}
		if (conf.tank.enabled)
		{
			callbacks.push(this.addTank);
		}
		if (conf.kamikaze.enabled)
		{
			callbacks.push(this.addKamikaze);
		}
		if (conf.minedropper.enabled)
		{
			callbacks.push(this.addMineDropper);
		}
		var choice = FlxG.random.int(0, callbacks.length - 1);
		callbacks[choice]();
	}
}
