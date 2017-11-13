package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import backeroids.view.Bullet;
import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import helix.GameTime;
import helix.core.HelixSprite;
import helix.core.HelixSpriteFluentApi;
import helix.data.Config;

class Shooter extends AbstractEnemy
{
    private static var random = new FlxRandom();
    private var lastVyChange:GameTime = GameTime.now();
    private var lastShot:GameTime = GameTime.now();
    private var onFireCallback:Bullet->Void;

    public function new(onFireCallback:Bullet->Void)
    {
        super(null, {width: 60, height: 30, colour: FlxColor.GREEN });
        this.onFireCallback = onFireCallback;

        var config:Dynamic = Config.get("enemies").shooter;
        this.elasticity = config.elasticity;
        this.velocity.x = config.velocity.x;
        this.health = config.health;

        this.velocity.y = (random.bool() == true ? -1 : 1) * (Config.get("enemies").shooter.velocity.y);

        var isGoingRight = random.bool();
        if (isGoingRight)
        {
            this.x = -this.width;
        }
        else
        {
            this.x = FlxG.width;
            this.velocity.x *= -1;
        }

        this.y = random.int(Std.int(FlxG.height / 4), Std.int(3 * FlxG.height / 4));
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        var now = GameTime.now();

        if (now.elapsedSeconds - lastVyChange.elapsedSeconds >= Config.get("enemies").shooter.sustainVyForSeconds)
        {
            lastVyChange = now;
            this.velocity.y *= -1;   
        }

        var timeBetweenBullets:Float = 1 / (Config.get("enemies").shooter.fireRatePerSecond);
        if (now.elapsedSeconds - this.lastShot.elapsedSeconds > timeBetweenBullets) 
        {
            this.lastShot = now;
            
            var bullet = new Bullet();            
            bullet.x = this.x + ((this.width - bullet.width) / 2);
            bullet.y = this.y + ((this.height - bullet.height) / 2);

            var angle = random.int(30, 150) * (random.bool() == true ? -1 : 1);
            bullet.shoot(angle);
            
            this.onFireCallback(bullet);
        }
    }
}