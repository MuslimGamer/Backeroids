package backeroids.view.enemies;

import backeroids.view.enemies.FollowerEnemy;
import backeroids.view.PlayerShip;
import helix.data.Config;

class Kamikaze extends FollowerEnemy
{
    public function new(player:PlayerShip)
    {
        super(player, {width: 30, height: 30, colour: 0xFFc10000 });

        var config:Dynamic = Config.get("enemies").kamikaze;
        this.baseVelocity = config.velocity;
        this.health = config.health;
    }
}