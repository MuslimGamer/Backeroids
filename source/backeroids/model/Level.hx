package backeroids.model;

import backeroids.model.PlayStateMediator;
import flixel.util.FlxTimer;
import helix.data.Config;

enum LevelState {
	Won;
	Lost;
	InProgress;
}

class Level
{
    public var num:Int = 0;
	private var waveTimer = new FlxTimer();

	public var waveNum = 0;
	public var currentWave:Wave;
	private var waveArray = new Array<Wave>();
	private var currentWaveIndex:Int = 0;

    private var mediator:PlayStateMediator;

	public var state = InProgress;

    public function new(num, mediator:PlayStateMediator):Void
    {
        this.num = num;
        this.mediator = mediator;

		var totalEntitiesToSpawn = this.num * Config.get('entitiesLevelMultiplier');
		var entitiesPerWave = this.num * Config.get('entitiesWaveMultiplier');
		this.waveNum = Math.floor(totalEntitiesToSpawn / entitiesPerWave);

		var delta:Int = -Math.floor(this.waveNum / 2);

		for (i in 1 ... this.waveNum + 1)
		{
			var wave = new Wave(entitiesPerWave + delta, i, this.mediator.areEnemiesInLevel(this.num));
			this.waveArray.push(wave);
			delta++;
			if (this.waveNum % 2 == 0 && i == this.waveNum)
			{
				delta++;
			}
		}

		this.currentWave = this.waveArray[0];
    }

	public function update(elapsed):Void
	{
		if (this.isCurrentWaveComplete())
		{
			this.spawnMoreItemsIfNeeded();
		}
	}

	public function startWave():Void
	{
		if (!Config.get("asteroids").enabled && !Config.get("enemies").enabled)
		{
			return;
		}
		this.mediator.counters.updateWave(this.currentWave.waveNumber, this.waveNum);
		this.mediator.spawnWaveEntities(this.currentWave.numAsteroid, this.currentWave.numEnemy, this.num);
	}

	public function spawnMoreItemsIfNeeded():Void
	{
		if (this.hasNextWave())
		{
			this.nextWave();
			this.startWaveTimer(function(?timer) { this.startWave(); });
		}
		else if (this.state == LevelState.InProgress)
		{
			this.win();
		}
	}

	private function win():Void
	{
		SaveManager.save(this.num);
		SoundManager.levelComplete.play();
		this.state = LevelState.Won;
		this.mediator.showGameWinText();
	}

	public function lose():Void
	{
		new FlxTimer().start(1, function(timer) { this.state = LevelState.Lost; }, 1);
	}

	public function hasNextWave():Bool
	{
		return this.waveArray[this.currentWaveIndex + 1] != null;
	}

	public function nextWave():Void
	{
		if (this.hasNextWave())
		{
			SoundManager.waveComplete.play();
            this.mediator.showWaveCompleteText();
			this.currentWaveIndex++;
			this.currentWave = this.waveArray[this.currentWaveIndex];
		}
	}

    public function startWaveTimer(callback:FlxTimer->Void):Void
    {
        this.waveTimer.start(1, callback, 1);
    }

	public function isCurrentWaveComplete():Bool
	{
		return this.areAllEntitiesSpawned() && this.areEntitiesDead();
	}

	public function areEntitiesDead():Bool
	{
		return this.mediator.areEntitiesDead();
	}

	public function areAllEntitiesSpawned():Bool
	{
		return (this.currentWave.spawnedAsteroids == this.currentWave.numAsteroid) && (this.currentWave.spawnedEnemies == this.currentWave.numEnemy);
	}
}