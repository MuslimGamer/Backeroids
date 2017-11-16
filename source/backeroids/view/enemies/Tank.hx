package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.PlayerShip;
import backeroids.view.Bullet;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import helix.GameTime;
import helix.core.HelixSprite;
import helix.core.HelixSpriteFluentApi;
import helix.data.Config;

class Tank extends AbstractEnemy
{
    private static var random = new FlxRandom();
    private var player:PlayerShip;
    private var baseVelocity:Int;

    public function new(player:PlayerShip)
    {
        super(null, {width: 80, height: 80, colour: 0xFFbbbbbb });

        this.elasticity = Config.get("enemies").elasticity;
        var config:Dynamic = Config.get("enemies").tank;        
        // set either component, velocity is rotated later
        this.baseVelocity = config.velocity;
        this.health = config.health;

        this.player = player;

        if (random.bool() == true)
        {
            // Place beside the stage
            this.x = random.bool() == true ? FlxG.width : -this.width;
            this.y = random.int(0, Std.int(FlxG.height - this.height));
        }
        else
        {
            // Place above/below the stage
            this.x = random.int(0, Std.int(FlxG.width - this.width));
            this.y = random.bool() == true ? FlxG.height : -this.height;
        }
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        var me = FlxPoint.weak(this.x, this.y);
        var player = FlxPoint.weak(this.player.x, this.player.y);
        trace('Pre: v=${this.velocity} and a=${this.angle}');
        this.angle = me.angleBetween(player);
        this.velocity.set(0, -this.baseVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle);
        trace('Post: v=${this.velocity} and a=${this.angle}');        
    }
}