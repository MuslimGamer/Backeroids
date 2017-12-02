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
import backeroids.prototype.Collision;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;
import helix.core.HelixState;
import helix.data.Config;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;

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

	private var levelWon = false;

	private var waveCounter:HelixSprite;
	private var livesCounter:HelixSprite;
	private var shieldCounter:HelixSprite;

	private var pauseSubState = new PauseSubState();

	private var collisionManager = new Collision();

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
		FlxG.mouse.load(AssetPaths.crosshairs__png);

		NUM_INITIAL_ASTEROIDS = Config.get("asteroids").initialNumber;
		SECONDS_PER_ASTEROID = Config.get("asteroids").secondsToSpawn;
		SECONDS_PER_ENEMY = Config.get("enemies").secondsToSpawn;
		
		this.playerShip = new PlayerShip(this);
		this.playerShip.setRecycleBulletCallback(function():Bullet
		{
			return bullets.recycle(Bullet);
		});
		resetShip();

		this.enemies.add(this.knockbackableEnemies);
		this.enemies.add(this.headstrongEnemies);

		this.playerShip.collideResolve(this.asteroids, this.collidePlayerShipWithAnything);
		this.playerShip.collideResolve(this.enemies, this.collidePlayerShipWithAnything);
		this.playerShip.collideResolve(this.enemyMines, this.collidePlayerShipWithAnything);
		this.playerShip.collideResolve(this.enemyBullets, this.collidePlayerShipWithAnything);
		this.playerShip.collideResolve(this.explosions, this.collidePlayerShipWithAnything);

		this.collisionManager.collideResolve(this.bullets, this.knockbackableEnemies)
							.collide(this.bullets, this.headstrongEnemies);

		this.collisionManager.collideResolve(this.enemyBullets, this.enemyMines)
							.collideResolve(this.bullets, this.enemyMines);

		this.collisionManager.collideResolve(this.explosions, this.enemies);

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
			this.playerShield.damage();
			return;
		}
		this.killPlayerShip();
	}

	private function spawnMoreItemsIfNeeded():Void
	{
		if (this.hasNextWave())
		{
			this.nextWave();
			this.waveTimer.start(1, this.startWave, 1);
		}
		else if (!this.levelWon)
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
			SoundManager.waveComplete.play();
			var waveCompleteText = this.makeText('Wave ${this.currentWave.waveNumber} complete!');
			FlxTween.tween(waveCompleteText, {alpha: 1}, 1)
				.then(FlxTween.tween(waveCompleteText, {alpha: 1}, 1, {onComplete: function(tween)
				{
					waveCompleteText.kill();
				}}));

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

	private function startWave(?timer):Void
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
		FlxG.mouse.unload();
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
		this.levelWon = true;
		SoundManager.levelComplete.play();
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
		
		if (this.isCurrentWaveComplete())
		{
			this.spawnMoreItemsIfNeeded();
		}

		this.collisionManager.update(elapsed);

		
		FlxG.collide(bullets, asteroids, function(b:Bullet, asteroid:Asteroid)
		{
				b.kill();
				if (asteroid.type != AsteroidType.Backeroid) {
					this.damageAndSplit(asteroid);
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

		FlxG.collide(enemyMines, asteroids, function(mine:Mine, asteroid:Asteroid)
		{
			mine.explode();
		});

		FlxG.collide(explosions, asteroids, function(explosion:Explosion, asteroid:Asteroid)
		{
			this.damageAndSplit(asteroid);
		});

		FlxG.collide(enemies);

		if (Config.get("features").collideAsteroidsWithAsteroids)
		{
			FlxG.collide(asteroids);
		}

		if (this.playerShield.isActivated)
		{
			FlxG.collide(this.playerShield, this.asteroids, this.collidePlayerShipWithAnything);
			FlxG.collide(this.playerShield, this.enemies, this.collidePlayerShipWithAnything);
			FlxG.collide(this.playerShield, this.enemyMines, this.collidePlayerShipWithAnything);
			FlxG.collide(this.playerShield, this.explosions, this.collidePlayerShipWithAnything);
			FlxG.collide(this.playerShield, this.enemyBullets, this.collidePlayerShipWithAnything);
		}
	}

	private function makeText(text:String):FlxText
	{
		var textField = new FlxText(1, 1, FlxG.width, text);
		textField.setFormat(null, 32, 0x00FFFFFF);
		textField.alpha = 0;

		add(textField);
		textField.x = FlxG.width / 2 - textField.textField.textWidth / 2;
		textField.y = FlxG.height / 2 - textField.textField.textHeight / 3;

		return textField;
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
		asteroid.health -= 1;
        SoundManager.asteroidHit.play();

		if (Config.get("features").splitAsteroidsOnDeath == true && asteroid.health <= 0 &&
			 asteroid.totalHealth >= 1 && (asteroid.type == AsteroidType.Large || asteroid.type == AsteroidType.Medium))
		{
			SoundManager.asteroidSplit.play(true);

			var padding = Math.floor(asteroid.width / 4);

			var numChunks = random.int(Config.get('asteroids').minChunks, Config.get('asteroids').maxChunks);

			for (i in 0 ... numChunks)
			{
				// Respawn at half health
				// Sets velocity and position				
				var newAsteroid = recycleAsteroid();
				var velocityMultiplier:Float = 1;

				if (asteroid.type == AsteroidType.Large)
				{
					newAsteroid.setMediumAsteroid();	
					velocityMultiplier = Config.get('asteroids').medium.velocityMultiplier;
				}
				else if (asteroid.type == AsteroidType.Medium)
				{
					newAsteroid.setSmallAsteroid();
					velocityMultiplier = Config.get('asteroids').small.velocityMultiplier;
				}
				else
				{
					newAsteroid.kill();
				}

				newAsteroid.x = asteroid.x;
				newAsteroid.y = asteroid.y;

				var offsetX:Float = random.float(0, padding);
				var offsetY:Float = padding - offsetX;

				offsetX *= random.bool() ? -1 : 1;
				offsetY *= random.bool() ? -1 : 1;

				newAsteroid.x += offsetX;
				newAsteroid.y += offsetY;

				var velocityAngle = FlxPoint.weak(0, 0).angleBetween(FlxPoint.weak(offsetX, offsetY));
				newAsteroid.velocity.rotate(FlxPoint.weak(0, 0), velocityAngle);
				newAsteroid.velocity.x *= velocityMultiplier;
				newAsteroid.velocity.y *= velocityMultiplier;
				newAsteroid.velocity.addPoint(asteroid.velocity);
			}
		}

		if (asteroid.health <= 0)
        {
            asteroid.kill();
        }
	}

	private function addShooter():Void
	{
		this.headstrongEnemies.add(new Shooter(function():Bullet
		{
			var bullet = enemyBullets.recycle(Bullet);
			bullet.baseVelocity = Config.get('enemies').shooter.bulletVelocity;
			return bullet;
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
					this.startWave();
			});

			var group = messageWindow.getDrawables();
			add(group);
		}
		else
		{
				this.startWave();
		}
	}
}
