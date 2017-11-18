package backeroids.extensions;

import flixel.math.FlxRandom;
import helix.GameTime;
import backeroids.model.IShooter;

class ShootProjectileExtension
{
    public static function shootPeriodically(sprite:IShooter, fireRatePerSecond, random:FlxRandom):Void
    {
        var now = GameTime.now();

        var timeBetweenBullets:Float = 1 / (fireRatePerSecond);
        if (now.elapsedSeconds - sprite.lastShot.elapsedSeconds > timeBetweenBullets) 
        {
            sprite.lastShot = now;
            
            var projectile = sprite.recycleProjectileCallback();
            projectile.x = sprite.x + ((sprite.width - projectile.width) / 2);
            projectile.y = sprite.y + ((sprite.height - projectile.height) / 2);

            var angle = random.int(30, 150) * (random.bool() == true ? -1 : 1);
            projectile.shoot(angle);
        }
    }
}