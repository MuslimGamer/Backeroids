package backeroids.states;

import backeroids.model.AsteroidType;
import backeroids.tutorial.TutorialManager;
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
import backeroids.extensions.ShootProjectileExtension;
import backeroids.SoundManager;
import flixel.FlxG;
import flixel.addons.ui.FlxUI9SliceSprite;
import flash.geom.Rectangle;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
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

	private var knockbackableEnemies = new FlxTypedGroup<AbstractEnemy>();
	private var headstrongEnemies = new FlxTypedGroup<AbstractEnemy>();
	private var enemies = new FlxTypedGroup<FlxTypedGroup<AbstractEnemy>>();
	private var enemyBullets = new FlxTypedGroup<Bullet>();
	private var enemyMines = new FlxTypedGroup<Mine>();

	private var levelNum:Int = 0;
	private var waveTimer = new FlxTimer();

	private var itemsLeftToSpawn = 0;
	private var waveNum = 0;
	private var showingTutorial:Bool = false;

	override public function new(levelNum):Void
	{
		super();
		this.levelNum = levelNum;
		this.itemsLeftToSpawn = this.levelNum * Config.get('entitiesLevelMultiplier');
		this.waveNum = this.levelNum * Config.get('entitiesWaveMultiplier');
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

		this.waveTimer.start(1, this.spawnMoreItemsIfNeeded, 0);
		this.enemies.add(this.knockbackableEnemies);
		this.enemies.add(this.headstrongEnemies);

		this.showTutorialIfRequired();
	}

	private function spawnMoreItemsIfNeeded(timer):Void
	{
		if (!this.areItemsDead())
		{
			return;
		}
		
		if (this.itemsLeftToSpawn > 0)
		{
			this.startWave();
		}
		else if (this.itemsLeftToSpawn <= 0)
		{
			this.winLevel();
		}
	}

	private function areItemsDead():Bool
	{
		return (this.asteroids.countLiving() <= 0) && (this.headstrongEnemies.countLiving() <= 0) && (this.knockbackableEnemies.countLiving() <= 0);
	}

	private function startWave():Void
	{
		if (!Config.get("asteroids").enabled && !Config.get("enemies").enabled)
		{
			return;
		}

		var asteroidNum:Int, enemyNum:Int;
		var enemiesInWave = this.itemsLeftToSpawn >= this.waveNum ? this.waveNum : this.itemsLeftToSpawn;

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

		this.itemsLeftToSpawn -= asteroidNum + enemyNum;

		this.spawnEntities(this.addAsteroid, asteroidNum, Config.get("secondsToSpawnAsteroidsOver"));
		this.spawnEntities(this.addEnemy, enemyNum, Config.get("secondsToSpawnEnemiesOver"));
	}

	private function spawnEntities(entitySpawner, entityNum:Int, secondsToSpawnOver:Int):Void
	{
		for (i in 0...entityNum)
		{
			new FlxTimer().start(FlxG.random.float(0, secondsToSpawnOver), entitySpawner, 1);
		}
	}

	private function getEnemyCallbacks():Array<Void->Void>
	{
		var enemyConf = Config.get("enemies");
		var enemyCallbacks = new Array<Void->Void>();

		if (enemyConf.shooter.enabled && this.levelNum >= enemyConf.shooter.appearsOnLevel)
		{
			enemyCallbacks.push(this.addShooter);
		}
		if (enemyConf.tank.enabled && this.levelNum >= enemyConf.tank.appearsOnLevel)
		{
			enemyCallbacks.push(this.addTank);
		}
		if (enemyConf.kamikaze.enabled && this.levelNum >= enemyConf.kamikaze.appearsOnLevel)
		{
			enemyCallbacks.push(this.addKamikaze);
		}
		if (enemyConf.minedropper.enabled && this.levelNum >= enemyConf.minedropper.appearsOnLevel)
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
		if (save.data.currentLevel < this.levelNum + 1)
		{
			save.data.currentLevel = this.levelNum + 1;
			save.flush();
		}
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

		FlxG.collide(bullets, knockbackableEnemies, function(bullet:Bullet, enemy:AbstractEnemy)
		{
				bullet.kill();
				enemy.damage();
		});

		FlxG.overlap(bullets, headstrongEnemies, function(bullet:Bullet, enemy:AbstractEnemy) 
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
		if (!this.playerShip.isInvincible())
		{
			this.playerShip.die(this.resetShip);
			if (!Config.get('features').infiniteLives)
			{
				this.loseLevel();
			}
		}
	}
	
	private function addAsteroid(?timer):Asteroid
	{
		var asteroid = this.recycleAsteroid();
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
			SoundManager.asteroidSplit.play();
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
		this.headstrongEnemies.add(new Shooter(function():Bullet
		{
			return enemyBullets.recycle(Bullet);
		}));
	}

	private function addTank():Void
	{
		this.knockbackableEnemies.add(new Tank(this.playerShip));		
	}

	private function addKamikaze():Void
	{
		this.knockbackableEnemies.add(new Kamikaze(this.playerShip));
	}

	private function addMineDropper():Void
	{
		this.headstrongEnemies.add(new MineDropper(function():Mine
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
		if (callbacks.length > 0)
		{
			var choice = FlxG.random.int(0, callbacks.length - 1);
			callbacks[choice]();
		}
	}

	private function showTutorialIfRequired():Void
	{
		var tutorialTag = TutorialManager.isTutorialRequired(this.levelNum);
		if (tutorialTag != null)
		{
			var messageWindow = TutorialManager.createTutorialWindow(tutorialTag);
			messageWindow.x = (FlxG.width - messageWindow.width) / 2;
			messageWindow.y = (FlxG.height - messageWindow.height) / 2;

			var group = messageWindow.getDrawables();
			add(group);
		}	
	}
}
