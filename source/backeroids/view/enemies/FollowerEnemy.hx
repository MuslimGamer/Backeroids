package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.PlayerShip;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import helix.data.Config;
import helix.GameTime;

class FollowerEnemy extends AbstractEnemy
{
    private static var random = new FlxRandom();
    private var player:PlayerShip;
    private var baseVelocity:Int;
    private var lastPinpoint:GameTime = new GameTime(0);

    public function new(filename, colorDetails, player:PlayerShip)
    {
        super(filename, colorDetails);
        this.player = player;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        if (this.player.exists) 
        {
            var now = GameTime.now();

            if (now.elapsedSeconds - this.lastPinpoint.elapsedSeconds > 1) 
            {
                var me = FlxPoint.weak(this.x, this.y);
                var player = FlxPoint.weak(this.player.x, this.player.y);
                this.angle = me.angleBetween(player);
                this.lastPinpoint = now;
            }

            this.velocity.set(0, -this.baseVelocity);
            this.velocity.rotate(FlxPoint.weak(0, 0), this.angle); 
        }
    }
}