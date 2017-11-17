package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.PlayerShip;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import helix.data.Config;

class Kamikaze extends AbstractEnemy
{
    private static var random = new FlxRandom();
    private var player:PlayerShip;
    private var baseVelocity:Int;

    public function new(player:PlayerShip)
    {
        super(null, {width: 30, height: 30, colour: 0xFFc10000 });

        this.elasticity = Config.get("enemies").elasticity;
        var config:Dynamic = Config.get("enemies").kamikaze;

        this.baseVelocity = config.velocity;
        this.health = config.health;

        this.player = player;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        var me = FlxPoint.weak(this.x, this.y);
        var player = FlxPoint.weak(this.player.x, this.player.y);
        
        this.angle = me.angleBetween(player);
        this.velocity.set(0, -this.baseVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle); 
    }
}