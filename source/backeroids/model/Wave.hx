package backeroids.model;

import flixel.math.FlxRandom;
import helix.data.Config;

class Wave
{
    private static var random = new FlxRandom();
    private var entityCount:Int;
    public var waveNumber:Int;

    public var numAsteroid:Int = 0;
    public var spawnedAsteroids:Int = 0;
    public var numEnemy:Int = 0;
    public var spawnedEnemies:Int = 0;

    public function new(entityCount:Int, waveNumber:Int, enemiesInWave:Bool = true):Void
    {
        this.entityCount = entityCount;
        this.waveNumber = waveNumber;

        var enemiesConf = Config.get('enemies');
        var asteroidConf = Config.get("asteroids");

        for (i in 0 ... this.entityCount)
        {
            if (!asteroidConf.enabled && !enemiesConf.enabled)
		    {
                return;
            }

            if (asteroidConf.enabled && !enemiesConf.enabled)
            {
                this.numAsteroid++;
                continue;
            }
            else if (enemiesConf.enabled && !asteroidConf.enabled)
            {
                this.numEnemy++;
                continue;
            }

            // If both enemies and asteroids are enabled
            else if (!enemiesInWave)
            {
                this.numAsteroid++;
                continue;
            }
            else if (random.bool())
            {
                this.numAsteroid++;
                continue;
            }
            else
            {
                this.numEnemy++;
                continue;
            }
        }
    }
}