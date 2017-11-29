package backeroids.view;

import backeroids.interfaces.IProjectile;
import backeroids.view.Explosion;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import helix.core.HelixSprite;
import helix.data.Config;

class Mine extends HelixSprite implements IProjectile
{
    private var fuseTimer = new FlxTimer();
    private var recycleExplosion:Void->Explosion;

    public function new():Void
    {
        super("assets/images/mine.png");
        this.kill();
        this.immovable = true;
    }

    public function shoot(angle:Float):Void
    {
        this.revive();
        this.fuseTimer.start(Config.get("enemies").minedropper.mineFuseSeconds, function(timer)
        {
            if (this.exists)
            {
                this.explode();
            }
        }, 1);
    }

    public function setRecycleExplosion(callback):Void
    {
        this.recycleExplosion = callback;
    }

    public function explode():Void
    {
        this.kill();
        var explosion = this.recycleExplosion();
        explosion.x = this.x + (this.width / 2 - Config.get("enemies").minedropper.explosionWidth / 2);
        explosion.y = this.y + (this.height / 2 - Config.get("enemies").minedropper.explosionHeight / 2);
        explosion.explode();
    }
}