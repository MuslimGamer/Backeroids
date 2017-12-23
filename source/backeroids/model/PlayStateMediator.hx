package backeroids.model;

import backeroids.model.Level;
import backeroids.model.EntityGroupManager;
import backeroids.model.SaveManager;
import backeroids.states.PlayState;
import backeroids.SoundManager;
import backeroids.prototype.Collision;
import backeroids.tutorial.TutorialManager;
import flixel.util.FlxTimer;
import flixel.math.FlxRandom;
import flixel.input.keyboard.FlxKey;
import helix.data.Config;

class PlayStateMediator
{
	private var random = new FlxRandom();
	private var collisionManager = new Collision();

	private var level:Level;
	private var playState:PlayState;
	private var entities:EntityGroupManager;

	public function new(playState:PlayState, levelNum)
	{
		this.playState = playState;
		this.entities = new EntityGroupManager(this);
		this.level = new Level(levelNum, this);
	}

	public function update(elapsed):Void
	{
		if (this.playState.isKeyPressed(FlxKey.ESCAPE) || (this.level.state == LevelState.Lost && this.playState.isKeyPressed(FlxKey.ANY)))
		{
			this.playState.exitState();
			return;
		}

		if (this.playState.wasJustPressed(FlxKey.P))
		{
			this.pause();
		}
		
		if (this.level.isCurrentWaveComplete())
		{
			this.spawnMoreItemsIfNeeded();
		}

		this.collisionManager.update(elapsed);
	}

	public function create():Void
	{
		this.showTutorialIfRequired();
	}

	private function createEntities():Void
	{
		this.entities.create();
		this.entities.playerShip.setKillCallback(this.killPlayerShip);

		this.playState.makeWaveCounter(this.level.waveNum);
		this.playState.makeLivesCounter(this.entities.playerShip.lives);

		if (Config.get('ship').shield.enabled)
		{
			this.entities.makeShield();
			this.playState.makeShieldCounter(this.entities.playerShield.shieldHealth);
			this.entities.playerShield.setIndicatorCallback(function():Void
			{
				this.playState.updateShieldCounter(this.entities.playerShield.shieldHealth);
			});
			this.entities.playerShip.setShield(this.entities.playerShield);
		}

		this.entities.setCollisions(this.collisionManager);
	}

	private function startLevel():Void
	{
		this.createEntities();
		this.startWave();
	}

	private function killPlayerShip():Void
	{
		if (!this.entities.playerShip.isInvincible())
		{
			this.entities.killPlayerShip();
			this.playState.updateLivesCounter(this.entities.playerShip.lives);
			if (!Config.get('features').infiniteLives && this.entities.playerShip.lives <= 0)
			{
				this.loseLevel();
			}
		}
	}

	private function loseLevel():Void
	{
		this.playState.showGameOverText();
		new FlxTimer().start(1, function(timer) { this.level.state == LevelState.Lost; }, 1);
	}

	private function winLevel():Void
	{
		SaveManager.save(this.level.num);
		SoundManager.levelComplete.play();
		this.level.state = LevelState.Won;
		this.playState.showGameWinText();
	}

	private function showTutorialIfRequired():Void
	{
		var tutorialTag = TutorialManager.isTutorialRequired(this.level.num);
		if (tutorialTag != null)
		{
			var messageWindow = this.playState.createTutorialMessage(tutorialTag);
			messageWindow.setFinishCallback(function() {
				this.startLevel();
			});
		}
		else
		{
			this.startLevel();
		}
	}

	public function pause():Void
	{
		FlxTimer.globalManager.forEach(function(timer:FlxTimer)
		{
			timer.active = false;
		});
		this.playState.pause();
	}

	public function addAsteroid():Void
	{
		this.level.currentWave.spawnedAsteroids++;
	}

	public function addEnemy():Void
	{
		this.level.currentWave.spawnedEnemies++;
	}

	public function startWave():Void
	{
		if (!Config.get("asteroids").enabled && !Config.get("enemies").enabled)
		{
			return;
		}
		this.playState.updateWaveCounter(this.level.currentWave.waveNumber, this.level.waveNum);
		this.entities.spawnWaveEntities(this.level.currentWave.numAsteroid, this.level.currentWave.numEnemy, this.level.num);
	}

	private function spawnMoreItemsIfNeeded():Void
	{
		if (this.level.hasNextWave())
		{
			this.level.nextWave();
			this.level.startWaveTimer(function(?timer) { this.startWave(); });
		}
		else if (this.level.state == LevelState.InProgress)
		{
			this.winLevel();
		}
	}

	public function areEnemiesInLevel(num):Bool
	{
		return this.entities.areEnemiesInLevel(num);
	}

	public function areEntitiesDead():Bool
	{
		return (this.entities.asteroids.countLiving() <= 0) && (this.entities.headstrongEnemies.countLiving() <= 0) && (this.entities.knockbackableEnemies.countLiving() <= 0);
	}

	public function showWaveCompleteText():Void
	{
		this.playState.showWaveCompleteText(this.level.currentWave.waveNumber);
	}
}