package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import backeroids.interfaces.IShooter;
import backeroids.interfaces.IProjectile;
import backeroids.SoundManager;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import helix.GameTime;
import helix.data.Config;
using backeroids.extensions.AbstractEnemyExtension;
using backeroids.extensions.ShootProjectileExtension;

class Shooter extends AbstractEnemy implements IShooter
{
    private static var random = new FlxRandom();
    private var lastVyChange:GameTime = GameTime.now();
    public var lastShot:GameTime = GameTime.now();
    public var recycleProjectileCallback:Void->IProjectile;

    public function new(recycleBulletCallback:Void->IProjectile)
    {
        super("assets/images/shooter.png");
        this.recycleProjectileCallback = recycleBulletCallback;

        var config:Dynamic = Config.get("enemies").shooter;
        this.elasticity = Config.get("enemies").elasticity;
        this.velocity.x = config.velocity.x;
        this.health = config.health;
        this.moveSideways(Config.get("enemies").shooter.velocity.y, random);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        SoundManager.shooterAmbient.play();
        var now = GameTime.now();

        if (now.elapsedSeconds - lastVyChange.elapsedSeconds >= Config.get("enemies").shooter.sustainVyForSeconds)
        {
            lastVyChange = now;
            this.velocity.y *= -1;
        }

        this.shootPeriodically(Config.get("enemies").shooter.fireRatePerSecond, random);
    }
}