package backeroids.model;

import backeroids.model.Level;
import backeroids.model.EntityGroupManager;
import backeroids.model.TutorialDisplayer;
import backeroids.view.controls.MessageWindow;
import backeroids.states.PlayState;

class PlayStateMediator
{
	private var level:Level;
	private var playState:PlayState;
	private var entities:EntityGroupManager;
	private var tutorial:TutorialDisplayer;
	public var counters:CounterMediator;

	public function new(playState:PlayState, levelNum)
	{
		this.playState = playState;
		this.entities = new EntityGroupManager(this);
		this.level = new Level(levelNum, this);
		this.tutorial = new TutorialDisplayer(this);
		this.counters = new CounterMediator(this.playState);
	}

	public function update(elapsed):Void
	{
		this.level.update(elapsed);
		this.entities.update(elapsed);
	}

	public function create():Void
	{
		this.tutorial.showIfRequired();
	}

	public function startLevel():Void
	{
		this.entities.createEntities();
		this.level.startWave();
	}

	public function loseLevel():Void
	{
		this.playState.showGameOverText();
		this.level.lose();
	}

	public function addAsteroid():Void
	{
		this.level.currentWave.spawnedAsteroids++;
	}

	public function addEnemy():Void
	{
		this.level.currentWave.spawnedEnemies++;
	}

	public function areEnemiesInLevel(num):Bool
	{
		return this.entities.areEnemiesInLevel(num);
	}

	public function areEntitiesDead():Bool
	{
		return this.entities.areEnemiesDead();
	}

	public function levelLost():Bool
	{
		return this.level.state == LevelState.Lost;
	}

	public function showWaveCompleteText():Void
	{
		this.playState.showWaveCompleteText(this.level.currentWave.waveNumber);
	}

	public function getLevelNum():Int
	{
		return this.level.num;
	}

	public function getWaveNum():Int
	{
		return this.level.waveNum;
	}

	public function createTutorialMessage(tutorialTag):MessageWindow
	{
		return this.playState.createTutorialMessage(tutorialTag);
	}

	public function showGameWinText():Void
	{
		this.playState.showGameWinText();
	}

	public function spawnWaveEntities(numAsteroid, numEnemy, levelNum):Void
	{
		this.entities.spawnWaveEntities(numAsteroid, numEnemy, levelNum);
	}
}

class CounterMediator
{
	private var playState:PlayState;

	public function new(playState)
	{
		this.playState = playState;
	}

	public function updateWave(currentWaveNumber, totalWaveNum):Void
	{
		this.playState.updateWaveCounter(currentWaveNumber, totalWaveNum);
	}

	public function updateLives(lives):Void
	{
		this.playState.updateLivesCounter(lives);
	}

	public function updateShield(shieldHealth):Void
	{
		this.playState.updateShieldCounter(shieldHealth);
	}

	public function makeWave(waveNum):Void
	{
		this.playState.makeWaveCounter(waveNum);
	}

	public function makeLives(lives):Void
	{
		this.playState.makeLivesCounter(lives);
	}

	public function makeShield(shieldHealth):Void
	{
		this.playState.makeShieldCounter(shieldHealth);
	}
}