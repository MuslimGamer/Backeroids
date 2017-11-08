package backeroids.model;

import helix.GameTime;
import helix.data.Config;
import backeroids.view.PlayerShip;
import backeroids.view.Bullet;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
using helix.core.HelixSpriteFluentApi;

class Gun
{
    private var playerShip:PlayerShip;
    private var secondsSinceFire:Float = 0;

    public function new(ship:PlayerShip):Void
    {
        this.playerShip = ship;
    }

    public function fire(bullet:Bullet):Void
    {
        if (GameTime.totalGameTimeSeconds - this.secondsSinceFire > Config.get("gun").timeBetweenShots) 
        {
            bullet.revive();
            bullet.move(this.playerShip.x + (this.playerShip.width - bullet.width) / 2, this.playerShip.y + (this.playerShip.height - bullet.height) / 2);
            bullet.angle = this.playerShip.angle;

            bullet.velocity.set(0, -Config.get("gun").bulletVelocity);
            bullet.velocity.rotate(FlxPoint.weak(0, 0), bullet.angle);

            this.secondsSinceFire = GameTime.totalGameTimeSeconds;
        }
    }
}