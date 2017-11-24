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
import backeroids.states.LevelSelectState;
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

	private var playerShip:PlayerShip;
	private var bullets = new FlxTypedGroup<Bullet>();

	private var explosions = new FlxTypedGroup<Explosion>();

	private var enemies = new FlxTypedGroup<AbstractEnemy>();
	private var enemyBullets = new FlxTypedGroup<Bullet>();
	private var enemyMines = new FlxTypedGroup<Mine>();

	private var levelNum:Int = 0;
	private var waveTimer = new FlxTimer();

	private var itemNum = 0;
	private var waveNum = 0;

	override public function new(levelNum):Void
	{
		super();
		this.levelNum = levelNum;
		this.itemNum = this.levelNum * Config.get('entitiesLevelMult');
		this.waveNum = this.levelNum * Config.get('entitiesWaveMult');
	}

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

		this.waveTimer.start(1, this.processWaves, 0);
	}

	private function processWaves(timer):Void
	{
		if (!this.isEverythingDead())
		{
			return;
		}
		
		if (this.itemNum > 0)
		{
			this.startWave();
		}
		else if (this.itemNum <= 0)
		{
			this.winLevel();
		}
	}

	private function isEverythingDead():Bool
	{
		return (this.asteroids.countLiving() == -1 && this.enemies.countLiving() == -1) || (this.asteroids.countLiving() == 0 && this.enemies.countLiving() == 0);
	}

	private function startWave():Void
	{
		trace('starting a wave!');
		if (!Config.get("asteroids").enabled && !Config.get("enemies").enabled)
		{
			return;
		}

		var asteroidNum:Int, enemyNum:Int;
		var enemiesInWave = (this.itemNum - this.waveNum) >= 0 ? this.waveNum : this.itemNum;

		if (Config.get("asteroids").enabled && Config.get("enemies").enabled)
		{
			asteroidNum = Math.round(enemiesInWave / 2);
			enemyNum = enemiesInWave - asteroidNum;
		}
		else if (Config.get("asteroids").enabled)
		{
			asteroidNum = enemiesInWave;
			enemyNum = 0;
		}
		else { return; }

		this.itemNum -= asteroidNum + enemyNum;

		this.spawnAsteroids(asteroidNum);
		this.spawnEnemies(enemyNum);
	}

	private function spawnAsteroids(asteroidNum:Int):Void
	{
		var sleepSeconds = 3;
		for (i in 0...asteroidNum)
		{
			new FlxTimer().start(FlxG.random.float(0, sleepSeconds), this.addAsteroid, 1);
		}
	}

	private function spawnEnemies(enemyNum:Int):Void
		{
		var sleepSeconds = 3;
		for (i in 0...enemyNum)
		{
			new FlxTimer().start(FlxG.random.float(0, sleepSeconds), this.addEnemy, 1);
		}
	}

	private function enemiesWillSpawn():Bool
	{
		return getEnemyCallbacks().length != 0;
	}

	private function getEnemyCallbacks():Array<Void->Void>
	{
		var enemyConf = Config.get("enemies");
		var enemyCallbacks = new Array<Void->Void>();

		if (enemyConf.shooter.enabled && enemyConf.shooter.appearsOnLevel >= this.levelNum)
		{
			enemyCallbacks.push(this.addShooter);
		}
		if (enemyConf.tank.enabled && enemyConf.tank.appearsOnLevel >= this.levelNum)
		{
			enemyCallbacks.push(this.addTank);
		}
		if (enemyConf.kamikaze.enabled && enemyConf.kamikaze.appearsOnLevel >= this.levelNum)
		{
			enemyCallbacks.push(this.addKamikaze);
		}
		if (enemyConf.minedropper.enabled && enemyConf.minedropper.appearsOnLevel >= this.levelNum)
		{
			enemyCallbacks.push(this.addMineDropper);
		}

		return enemyCallbacks;
	}

	private function exitState():Void
	{
		this.waveTimer.cancel();
		FlxG.switchState(new LevelSelectState());
	}
	
	private function winLevel():Void
	{
		trace("Horray! You won.");
		var save = FlxG.save;
		save.data.currentLevel = this.levelNum + 1;
		save.flush();
		this.exitState();
	}

	private function loseLevel():Void
	{
		trace('Oh no! You lost.');
		this.exitState();
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
		if (!Config.get('features').infiniteLives)
		{
			this.loseLevel();
		}
	}
	
	private function addAsteroid(?timer):Asteroid
	{
		var asteroid = asteroids.recycle(Asteroid);
		asteroid.respawn();
		return asteroid;
	}

	private function recycleAsteroid():Asteroid
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
				var newAsteroid = recycleAsteroid();

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

	private function addEnemy(?timer):Void
	{
		var callbacks = this.getEnemyCallbacks();
		var choice = FlxG.random.int(0, callbacks.length - 1);
		callbacks[choice]();
	}
}
