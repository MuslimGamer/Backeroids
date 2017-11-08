package backeroids.model;

import helix.GameTime;
import backeroids.view.PlayerShip;
import backeroids.view.Bullet;
import flixel.util.FlxTimer;

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
        if (GameTime.totalGameTimeSeconds - this.secondsSinceFire > Config.get("gun".timeBetweenShots)) 
        {
            bullet.shoot(this.playerShip);
            this.secondsSinceFire = GameTime.totalGameTimeSeconds;
        }
    }
}