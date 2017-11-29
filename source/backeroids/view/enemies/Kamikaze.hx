package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.PlayerShip;
import flixel.math.FlxPoint;
import helix.data.Config;

class Kamikaze extends AbstractEnemy
{
    public function new(player:PlayerShip)
    {
        super("assets/images/kamikaze.png");

        var config:Dynamic = Config.get("enemies").kamikaze;
        var baseVelocity = config.velocity;
        this.health = config.health;
        this.angularVelocity = 360 * 2; // spin 2x/s

        // Aim toward the player
        var me = FlxPoint.weak(this.x, this.y);
        var playerPoint = FlxPoint.weak(player.x, player.y);
        
        this.angle = me.angleBetween(playerPoint);
        this.velocity.set(0, -baseVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle); 
    }
}