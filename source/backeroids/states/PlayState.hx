package backeroids.states;

import backeroids.model.AsteroidType;
import backeroids.model.Wave;
import backeroids.tutorial.TutorialManager;
import backeroids.view.Asteroid;
import backeroids.view.Bullet;
import backeroids.view.Mine;
import backeroids.view.PlayerShip;
import backeroids.view.Shield;
import backeroids.view.Explosion;
import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.enemies.Shooter;
import backeroids.view.enemies.Tank;
import backeroids.view.enemies.Kamikaze;
import backeroids.view.enemies.MineDropper;
import backeroids.states.LevelSelectState;
import backeroids.states.PauseSubState;
import backeroids.SoundManager;
import flixel.FlxG;
import flixel.addons.ui.FlxUI9SliceSprite;
import flash.geom.Rectangle;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.math.FlxRandom;
import flixel.input.keyboard.FlxKey;
using helix.core.HelixSpriteFluentApi;
import helix.core.HelixState;
import helix.core.HelixSprite;
import helix.data.Config;
import helix.core.HelixSprite;

class PlayState extends HelixState
{
	private static var NUM_INITIAL_ASTEROIDS:Int;
	private static var SECONDS_PER_ASTEROID:Int;
	private static var SECONDS_PER_ENEMY:Int;

	public var isShowingTutorial(default, null):Bool = false;
	private var asteroids = new FlxTypedGroup<Asteroid>();

	private var playerShip:PlayerShip;
	private var playerShield:Shield;
	private var bullets = new FlxTypedGroup<Bullet>();

	private var random = new FlxRandom();

	private var explosions = new FlxTypedGroup<Explosion>();

	private var knockbackableEnemies = new FlxTypedGroup<AbstractEnemy>();
	private var headstrongEnemies = new FlxTypedGroup<AbstractEnemy>();
	private var enemies = new FlxTypedGroup<FlxTypedGroup<AbstractEnemy>>();
	private var enemyBullets = new FlxTypedGroup<Bullet>();
	private var enemyMines = new FlxTypedGroup<Mine>();

	private var levelNum:Int = 0;
	private var waveTimer = new FlxTimer();

	private var waveNum = 0;
	private var waveArray = new Array<Wave>();
	private var currentWave:Wave;
	private var currentWaveIndex:Int = 0;
	private var waveCounter:HelixSprite;
	private var livesCounter:HelixSprite;
	private var shieldCounter:HelixSprite;

	private var pauseSubState = new PauseSubState();

	override public function new(levelNum):Void
	{
		super();
		this.levelNum = levelNum;
		var totalEntitiesToSpawn = this.levelNum * Config.get('entitiesLevelMultiplier');
		var entitiesPerWave = this.levelNum * Config.get('entitiesWaveMultiplier');
		this.waveNum = Math.floor(totalEntitiesToSpawn / entitiesPerWave);

		for (i in 1 ... this.waveNum + 1)
		{
			var wave = new Wave(entitiesPerWave, i, this.areEnemiesInLevel());
			this.waveArray.push(wave);
		}

		this.currentWave = this.waveArray[0];
	}

	override public function create():Void
	{
		super.create();

		this.destroySubStates = false;

		NUM_INITIAL_ASTEROIDS = Config.get("asteroids").initialNumber;
		SECONDS_PER_ASTEROID = Config.get("asteroids").secondsToSpawn;
		SECONDS_PER_ENEMY = Config.get("enemies").secondsToSpawn;
		
		this.playerShip = new PlayerShip(this);
		this.playerShip.setRecycleBulletCallback(function():Bullet
		{
			return bullets.recycle(Bullet);
		});
		resetShip();

		this.playerShip.collideResolve(this.asteroids, this.collidePlayerShipWithAnything);
		this.playerShip.collideResolve(this.enemies, this.collidePlayerShipWithAnything);
		this.playerShip.collideResolve(this.enemyMines, this.collidePlayerShipWithAnything);
		this.playerShip.collideResolve(this.enemyBullets, this.collidePlayerShipWithAnything);
		this.playerShip.collideResolve(this.explosions, this.collidePlayerShipWithAnything);

		this.enemies.add(this.knockbackableEnemies);
		this.enemies.add(this.headstrongEnemies);

		this.waveCounter = new HelixSprite(null, {width: 1, height: 1, colour: 0xFF000000});
		this.waveCounter.alpha = 0;
		this.waveCounter.text('Wave: 0/${this.waveNum}');

		this.livesCounter = new HelixSprite(null, {width: 1, height: 1, colour: 0xFF000000});
		this.livesCounter.alpha = 0;
		this.livesCounter.text('Lives: ${this.playerShip.lives}');
		this.livesCounter.x = FlxG.width - this.livesCounter.width - this.livesCounter.textField.textField.textWidth;

		if (Config.get('ship').shield.enabled)
		{
			this.playerShield = new Shield();
	
			this.shieldCounter = new HelixSprite(null, {width: 1, height: 1, colour: 0xFF000000});
			this.shieldCounter.alpha = 0;
			this.shieldCounter.text('Shield: ${this.playerShield.shieldHealth}');
			this.shieldCounter.x = FlxG.width - this.shieldCounter.width - this.shieldCounter.textField.textField.textWidth;
			this.shieldCounter.y = this.livesCounter.textField.textField.textHeight;

			this.playerShield.setIndicatorCallback(function():Void
			{
				this.shieldCounter.text('Shield: ${this.playerShield.shieldHealth}');
			});

			var damageShieldCallback = function(shield:Shield, thing:HelixSprite)
			{
				if (this.playerShip.alive)
				{
					shield.damage();
					this.collidePlayerShipWithAnything(this.playerShip, thing);
				}
			}
			this.playerShield.collideResolve(this.asteroids, damageShieldCallback);
			this.playerShield.collideResolve(this.enemies, damageShieldCallback);
			this.playerShield.collideResolve(this.enemyMines, damageShieldCallback);
			this.playerShield.collideResolve(this.explosions, damageShieldCallback);
			this.playerShield.collide(this.enemyBullets, damageShieldCallback);

			this.playerShip.setShield(this.playerShield);
		}

		this.showTutorialIfRequired();
	}

	private function collidePlayerShipWithAnything(player:PlayerShip, thing:HelixSprite):Void
	{
		var thingType = Type.getClassName(Type.getClass(thing));
		if (thingType == 'backeroids.view.Bullet')
		{
			thing.kill();
		}
		else if (thingType == 'backeroids.view.Mine')
		{
			var mine:Mine = cast thing;
			mine.explode();
		}
		else if (thingType == 'backeroids.view.Asteroid')
		{
			var asteroid:Asteroid = cast(thing, Asteroid);

			if (asteroid.type != AsteroidType.Backeroid) 
			{
				this.damageAndSplit(asteroid);
			}
		}

		if (Config.get('ship').shield.enabled && this.playerShield.isActivated)
		{
			return;
		}
		this.killPlayerShip();
	}

	private function spawnMoreItemsIfNeeded(timer):Void
	{
		if (!this.isCurrentWaveComplete())
		{
			return;
		}
		
		if (this.hasNextWave())
		{
			this.nextWave();
			this.startWave();
		}
		else
		{
			this.winLevel();
		}
	}

	private function hasNextWave():Bool
	{
		return this.waveArray[this.currentWaveIndex + 1] != null;
	}

	private function nextWave():Void
	{
		if (this.hasNextWave())
		{
			this.currentWaveIndex++;
			this.currentWave = this.waveArray[this.currentWaveIndex];
		}
	}

	private function isCurrentWaveComplete():Bool
	{
		return this.areAllEntitiesSpawned() && this.areEntitiesDead();
	}

	private function areEntitiesDead():Bool
	{
		return (this.asteroids.countLiving() <= 0) && (this.headstrongEnemies.countLiving() <= 0) && (this.knockbackableEnemies.countLiving() <= 0);
	}

	private function areAllEntitiesSpawned():Bool
	{
		return (this.currentWave.spawnedAsteroids == this.currentWave.numAsteroid) && (this.currentWave.spawnedEnemies == this.currentWave.numEnemy);
	}

	private function startWave():Void
	{
		if (!Config.get("asteroids").enabled && !Config.get("enemies").enabled)
		{
			return;
		}

		this.waveCounter.text('Wave: ${this.currentWave.waveNumber}/${this.waveNum}');

		var asteroidSeconds = this.currentWave.numAsteroid * Config.get("secondsPerAsteroidToSpawnOver");
		var enemySeconds = this.currentWave.numEnemy * Config.get("secondsPerEnemyToSpawnOver");

		this.spawnEntities(this.addAsteroid, this.currentWave.numAsteroid, asteroidSeconds);
		this.spawnEntities(this.addEnemy, this.currentWave.numEnemy, enemySeconds);
	}

	private function spawnEntities(entitySpawner, entityNum:Int, secondsToSpawnOver:Int):Void
	{
		for (i in 0...entityNum)
		{
			new FlxTimer().start(random.float(0, secondsToSpawnOver), entitySpawner, 1);
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

	private function areEnemiesInLevel():Bool
	{
		return this.getEnemyCallbacks().length != 0;
	}

	private function exitState():Void
	{
		this.waveTimer.cancel();
		FlxG.switchState(new LevelSelectState());
	}
	
	private function winLevel():Void
	{
		var save = FlxG.save;
		if (save.data.currentLevel < this.levelNum + 1)
		{
			save.data.currentLevel = this.levelNum + 1;
			save.flush();
		}
		var gameWinText = new HelixSprite(null, {height: 1, width: 1, colour: 0xFF000000});
		gameWinText.alpha = 0;
		gameWinText.text('YOU WIN!\nPress anything to exit.');
		gameWinText.move((FlxG.width / 2) - (gameWinText.textField.textField.textWidth / 2), (FlxG.height / 2) - (gameWinText.textField.textField.textHeight / 2));
		new FlxTimer().start(1, function(timer)
		{
			gameWinText.onKeyDown(function (keys:Array<FlxKey>)
			{
				if (keys.length != 0)
				{
					this.exitState();
				}
			});
		});
	}

	private function loseLevel():Void
	{
		var gameWinText = new HelixSprite(null, {height: 1, width: 1, colour: 0xFF000000});
		gameWinText.alpha = 0;
		gameWinText.text('GAME OVER!\nPress anything to exit.');
		gameWinText.move((FlxG.width / 2) - (gameWinText.textField.textField.textWidth / 2), (FlxG.height / 2) - (gameWinText.textField.textField.textHeight / 2));
		new FlxTimer().start(1, function(timer)
		{
			gameWinText.onKeyDown(function (keys:Array<FlxKey>)
			{
				if (keys.length != 0)
				{
					this.exitState();
				}
			});
		});
	}

	override public function update(elapsed:Float):Void
	{
		if (this.isKeyPressed(FlxKey.ESCAPE))
		{
			this.exitState();
			return;
		}
		if (this.wasJustPressed(FlxKey.P))
		{
			FlxTimer.globalManager.forEach(function(timer:FlxTimer)
			{
				timer.active = false;
			});
			this.openSubState(this.pauseSubState);
		}

		super.update(elapsed);
		
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

		FlxG.collide(enemyBullets, enemyMines, function(enemyBullet:Bullet, mine:Mine)
		{
				enemyBullet.kill();
				mine.explode();
		});

		FlxG.collide(enemyMines, asteroids, function(mine:Mine, asteroid:Asteroid)
		{
			mine.explode();
		});

		FlxG.collide(enemyMines, bullets, function(mine:Mine, bullet:Bullet)
		{
			bullet.kill();
			mine.explode();
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
			FlxG.collide(asteroids);
		}
	}

	private function killPlayerShip():Void
	{
		if (!this.playerShip.isInvincible())
		{
			this.playerShip.die(this.resetShip);
			this.livesCounter.text('Lives: ${this.playerShip.lives}');
			if (!Config.get('features').infiniteLives && this.playerShip.lives <= 0)
			{
				this.loseLevel();
			}
		}
	}
	
	private function addAsteroid(?timer):Asteroid
	{
		var asteroid = this.recycleAsteroid();
		asteroid.respawn();
		this.currentWave.spawnedAsteroids++;
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
			SoundManager.asteroidSplit.play(true);
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
			var choice = random.int(0, callbacks.length - 1);
			callbacks[choice]();
			this.currentWave.spawnedEnemies++;
		}
	}

	private function showTutorialIfRequired():Void
	{
		var tutorialTag = TutorialManager.isTutorialRequired(this.levelNum);
		if (tutorialTag != null)
		{
			this.isShowingTutorial = true;
			var messageWindow = TutorialManager.createTutorialWindow(tutorialTag);
			messageWindow.x = (FlxG.width - messageWindow.width) / 2;
			messageWindow.y = (FlxG.height - messageWindow.height) / 2;
			messageWindow.setFinishCallback(function() {
				this.isShowingTutorial = false;
				this.waveTimer.start(1, function(timer) 
				{
					this.startWave();
					this.waveTimer.reset();
					this.waveTimer.start(1, this.spawnMoreItemsIfNeeded, 0);
				}, 1);
			});

			var group = messageWindow.getDrawables();
			add(group);
		}
		else
		{
			this.waveTimer.start(1, function(timer) 
			{
				this.startWave();
				this.waveTimer.reset();
				this.waveTimer.start(1, this.spawnMoreItemsIfNeeded, 0);
			}, 1);
		}
	}
}
