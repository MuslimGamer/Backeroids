package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import backeroids.interfaces.IShooter;
import backeroids.interfaces.IProjectile;
import flixel.math.FlxRandom;
import helix.data.Config;
import helix.GameTime;
using backeroids.extensions.AbstractEnemyExtension;
using backeroids.extensions.ShootProjectileExtension;

class MineDropper extends AbstractEnemy implements IShooter
{
    private static var random = new FlxRandom();
    public var lastShot:GameTime = GameTime.now();
    public var recycleProjectileCallback:Void->IProjectile;

    public function new(mineCallback:Void->IProjectile):Void
    {
        super(null, {{width: 40, height: 50, colour: 0xFF730077 }});

        this.recycleProjectileCallback = mineCallback;
        this.elasticity = Config.get("enemies").elasticity;

        var config:Dynamic = Config.get("enemies").minedropper;
        this.elasticity = Config.get("enemies").elasticity;
        this.velocity.x = config.velocity.x;
        this.health = config.health;

        this.moveSideways(Config.get("enemies").minedropper.velocity.y, random);
    }

     override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        this.shootPeriodically(Config.get("enemies").minedropper.fireRatePerSecond, random);
    }
}