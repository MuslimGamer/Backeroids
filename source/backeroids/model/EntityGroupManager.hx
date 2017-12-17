package backeroids.model;

import backeroids.view.Asteroid;
import backeroids.view.Mine;
import backeroids.view.Bullet;
import backeroids.view.PlayerShip;
import backeroids.view.Shield;
import backeroids.view.Explosion;
import backeroids.view.enemies.Shooter;
import backeroids.view.enemies.Tank;
import backeroids.view.enemies.Kamikaze;
import backeroids.view.enemies.MineDropper;
import backeroids.view.enemies.AbstractEnemy;
import backeroids.prototype.ICollidable;
import backeroids.prototype.Collision;
import backeroids.model.PlayStateMediator;
import helix.data.Config;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.FlxG;
import flixel.util.FlxTimer;
using helix.core.HelixSpriteFluentApi;

class EntityGroupManager
{
    private var random = new FlxRandom();
	public var explosions = new FlxTypedGroup<Explosion>();

	public var knockbackableEnemies = new FlxTypedGroup<AbstractEnemy>();
	public var headstrongEnemies = new FlxTypedGroup<AbstractEnemy>();
	public var enemies = new FlxTypedGroup<FlxTypedGroup<AbstractEnemy>>();
	public var enemyBullets = new FlxTypedGroup<Bullet>();
	public var enemyMines = new FlxTypedGroup<Mine>();

    public var asteroids = new FlxTypedGroup<Asteroid>();

	public var playerShip:PlayerShip;
	public var playerShield:Shield;
	public var bullets = new FlxTypedGroup<Bullet>();

    private var mediator:PlayStateMediator;

    public function new(mediator) 
    {
        this.mediator = mediator;
    }

    public function create():Void
    {
        this.playerShip = new PlayerShip();
		this.playerShip.setRecycleBulletCallback(function():Bullet
		{
			return this.bullets.recycle(Bullet);
		});
		this.resetShip();

		this.enemies.add(this.knockbackableEnemies);
		this.enemies.add(this.headstrongEnemies);
    }

    public function spawnWaveEntities(numAsteroid, numEnemy, levelNum):Void
    {
        var asteroidSeconds = numAsteroid * Config.get("secondsPerAsteroidToSpawnOver");
		var enemySeconds = numEnemy * Config.get("secondsPerEnemyToSpawnOver");

		this.spawnEntities(function(timer) { this.addAsteroid(); }, numAsteroid, asteroidSeconds);
		this.spawnEntities(function(timer) { this.addEnemy(levelNum); }, numEnemy, enemySeconds);
    }

    public function spawnEntities(entitySpawner, entityNum:Int, secondsToSpawnOver:Int):Void
	{
		for (i in 0...entityNum)
		{
			new FlxTimer().start(random.float(0, secondsToSpawnOver), entitySpawner, 1);
		}
	}

    public function recycleAsteroid():Asteroid
	{
		var asteroid = this.asteroids.recycle(Asteroid);
		return asteroid;
	}

    public function resetShip():Void
	{
		this.playerShip.move((FlxG.width - this.playerShip.width) / 2, (FlxG.height - this.playerShip.height) / 2);		
	}

    public function killPlayerShip():Void
    {
        this.playerShip.die(this.resetShip);
    }

    public function makeShield():Void
    {
        this.playerShield = new Shield();
    }

    private function addAsteroid():Asteroid
	{
		var asteroid = this.recycleAsteroid();
		asteroid.respawn();
		this.mediator.addAsteroid();
		return asteroid;
	}

	private function addEnemy(levelNum:Int):Void
	{
		var callbacks = this.getEnemyCallbacks(levelNum);
		if (callbacks.length > 0)
		{
			var choice = random.int(0, callbacks.length - 1);
			callbacks[choice]();
			this.mediator.addEnemy();
		}
	}

    private function addShooter():Void
	{
		this.headstrongEnemies.add(new Shooter(function():Bullet
		{
			var bullet = this.enemyBullets.recycle(Bullet);
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
			var mine = this.enemyMines.recycle(Mine);
			mine.setRecycleExplosion(function():Explosion
			{
				return this.explosions.recycle(Explosion).resetView();
			});
			return mine;
		}));
	}

    public function getEnemyCallbacks(levelNum:Int):Array<Void->Void>
	{
		var enemyConf = Config.get("enemies");
		var enemyCallbacks = new Array<Void->Void>();

		if (enemyConf.shooter.enabled && levelNum >= enemyConf.shooter.appearsOnLevel)
		{
			enemyCallbacks.push(this.addShooter);
		}
		if (enemyConf.tank.enabled && levelNum >= enemyConf.tank.appearsOnLevel)
		{
			enemyCallbacks.push(this.addTank);
		}
		if (enemyConf.kamikaze.enabled && levelNum >= enemyConf.kamikaze.appearsOnLevel)
		{
			enemyCallbacks.push(this.addKamikaze);
		}
		if (enemyConf.minedropper.enabled && levelNum >= enemyConf.minedropper.appearsOnLevel)
		{
			enemyCallbacks.push(this.addMineDropper);
		}

		return enemyCallbacks;
	}

    public function areEnemiesInLevel(levelNum:Int):Bool
	{
		return this.getEnemyCallbacks(levelNum).length != 0;
	}

    private function damageAndSplit(asteroid:Asteroid):Void
	{
		asteroid.health -= 1;
        SoundManager.asteroidHit.play();
		if (asteroid.health > 0)
		{
			return;
		}

		if (Config.get("features").splitAsteroidsOnDeath == true && asteroid.totalHealth >= 1 
		    && (asteroid.type == AsteroidType.Large || asteroid.type == AsteroidType.Medium))
		{
			SoundManager.asteroidSplit.play(true);
			var padding = Math.floor(asteroid.width / 4);
			var numChunks = random.int(Config.get('asteroids').minChunks, Config.get('asteroids').maxChunks);

			for (i in 0 ... numChunks)
			{			
				var newAsteroid = this.recycleAsteroid();
				newAsteroid.splitOffFrom(asteroid, padding);
			}
		}
		asteroid.kill();
	}

    public function setCollisions(collisionManager:Collision):Void
	{

		collisionManager.collideResolve(this.playerShip, this.enemies)
                        .collideResolve(this.playerShip, this.enemyMines)
                        .collideResolve(this.playerShip, this.enemyBullets)
                        .collideResolve(this.playerShip, this.explosions);

		if (Config.get('ship').shield.enabled)
		{
            collisionManager.collideResolve(this.playerShield, this.enemies)
                            .collideResolve(this.playerShield, this.enemyMines)
                            .collideResolve(this.playerShield, this.enemyBullets)
                            .collideResolve(this.playerShield, this.explosions);
		}

		var asteroidCollisionCallback = function(asteroid:Asteroid, thing:ICollidable):Void
		{
			thing.collide();
			this.damageAndSplit(asteroid);
		}

		collisionManager.collideResolve(this.asteroids, this.bullets, asteroidCollisionCallback)
                        .collideResolve(this.asteroids, this.enemies, asteroidCollisionCallback)
                        .collideResolve(this.asteroids, this.enemyBullets, asteroidCollisionCallback)
                        .collideResolve(this.asteroids, this.enemyMines, asteroidCollisionCallback)
                        .collideResolve(this.asteroids, this.explosions, asteroidCollisionCallback)
                        .collideResolve(this.asteroids, this.playerShip, asteroidCollisionCallback)
                        .collideResolve(this.asteroids, this.playerShield, asteroidCollisionCallback)
                        .collideResolve(this.asteroids);

		collisionManager.collideResolve(this.bullets, this.knockbackableEnemies)
                        .collide(this.bullets, this.headstrongEnemies);

		collisionManager.collideResolve(this.enemyBullets, this.enemyMines)
                        .collideResolve(this.bullets, this.enemyMines);

		collisionManager.collideResolve(this.enemies, this.explosions)
                        .collideResolve(this.enemies);
	}
}