package backeroids.view.enemies;

import backeroids.view.enemies.FollowerEnemy;
import backeroids.view.PlayerShip;
import helix.data.Config;

class Tank extends FollowerEnemy
{
    public function new(player:PlayerShip)
    {
        super(player, {width: 80, height: 80, colour: 0xFFbbbbbb });

        var config:Dynamic = Config.get("enemies").tank;   
        // set either component, velocity is rotated later
        this.baseVelocity = config.velocity;
        this.health = config.health;
    }
}