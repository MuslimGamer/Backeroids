package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.Bullet;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import helix.GameTime;
import helix.data.Config;
using backeroids.extensions.AbstractEnemyExtension;

class Shooter extends AbstractEnemy
{
    private static var random = new FlxRandom();
    private var lastVyChange:GameTime = GameTime.now();
    private var lastShot:GameTime = GameTime.now();
    private var recycleBulletCallback:Void->Bullet;

    public function new(recycleBulletCallback:Void->Bullet)
    {
        super(null, {width: 60, height: 30, colour: FlxColor.GREEN });
        this.recycleBulletCallback = recycleBulletCallback;

        var config:Dynamic = Config.get("enemies").shooter;
        this.elasticity = Config.get("enemies").elasticity;
        this.velocity.x = config.velocity.x;
        this.health = config.health;

        this.moveSideways(Config.get("enemies").shooter.velocity.y, random);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        var now = GameTime.now();

        if (now.elapsedSeconds - lastVyChange.elapsedSeconds >= Config.get("enemies").shooter.sustainVyForSeconds)
        {
            lastVyChange = now;
            this.velocity.y *= -1;   
        }

        var timeBetweenBullets:Float = 1 / (Config.get("enemies").shooter.fireRatePerSecond);
        if (now.elapsedSeconds - this.lastShot.elapsedSeconds > timeBetweenBullets) 
        {
            this.lastShot = now;
            
            var bullet = this.recycleBulletCallback();            
            bullet.x = this.x + ((this.width - bullet.width) / 2);
            bullet.y = this.y + ((this.height - bullet.height) / 2);

            var angle = random.int(30, 150) * (random.bool() == true ? -1 : 1);
            bullet.shoot(angle);
        }
    }
}