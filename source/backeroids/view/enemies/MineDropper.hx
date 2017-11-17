package backeroids.view.enemies;

import backeroids.view.enemies.AbstractEnemy;
import flixel.math.FlxRandom;
import flixel.FlxG;
import helix.data.Config;
import helix.GameTime;

class MineDropper extends AbstractEnemy
{
    private static var random = new FlxRandom();
    private var lastShot:GameTime = GameTime.now();
    private var recycleMineCallback:Void->Mine;

    public function new(mineCallback:Void->Mine):Void
    {
        super(null, {{width: 40, height: 50, colour: 0xFF730077 }});

        this.recycleMineCallback = mineCallback;
        this.elasticity = Config.get("enemies").elasticity;

        var config:Dynamic = Config.get("enemies").minedropper;
        this.elasticity = Config.get("enemies").elasticity;
        this.velocity.x = config.velocity.x;
        this.health = config.health;

        this.velocity.y = (random.bool() == true ? -1 : 1) * (Config.get("enemies").minedropper.velocity.y);

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

        var timeBetweenBullets:Float = 1 / (Config.get("enemies").minedropper.fireRatePerSecond);
        if (now.elapsedSeconds - this.lastShot.elapsedSeconds > timeBetweenBullets) 
        {
            this.lastShot = now;
            
            var mine = this.recycleMineCallback();
            mine.x = this.x + ((this.width - mine.width) / 2);
            mine.y = this.y + ((this.height - mine.height) / 2);

            var angle = random.int(30, 150) * (random.bool() == true ? -1 : 1);
            mine.shoot(angle);
        }
    }
}