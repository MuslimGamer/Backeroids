package backeroids;

import helix.GameTime;
import backeroids.view.PlayerShip;
import backeroids.view.Bullet;
import flixel.util.FlxTimer;

class Gun
{
    private var playerShip:PlayerShip;
    private var timeSinceFire:Float = 0;

    public function new(ship:PlayerShip):Void
    {
        this.playerShip = ship;
    }

    public function fire(bullet:Bullet):Void
    {
        if (GameTime.totalGameTimeSeconds - this.timeSinceFire > 1) 
        {
            trace("PEW!");
            bullet.shoot(this.playerShip);
            this.timeSinceFire = GameTime.totalGameTimeSeconds;
        }
    }
}