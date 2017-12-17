package backeroids.model;

import backeroids.model.PlayStateMediator;
import flixel.util.FlxTimer;
import flixel.math.FlxRandom;
import helix.data.Config;

class Level
{
    public var num:Int = 0;
	public var waveTimer = new FlxTimer();
    public var random = new FlxRandom();

	public var waveNum = 0;
	public var waveArray = new Array<Wave>();
	public var currentWave:Wave;
	public var currentWaveIndex:Int = 0;

    private var mediator:PlayStateMediator;

	public var won = false;
    public var lost = false;

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
		}

		this.currentWave = this.waveArray[0];
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