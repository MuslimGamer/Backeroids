package backeroids.view.enemies;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import helix.GameTime;
import helix.core.HelixSprite;
import helix.data.Config;

class Shooter extends HelixSprite
{
    private static var random = new FlxRandom();
    private var lastVyChange:GameTime;
    private var lastShot:Float;

    public function new()
    {
        super(null, {width: 80, height: 30, colour: FlxColor.GREEN });
        this.elasticity = Config.get("enemies").shooter.elasticity;
        this.velocity.x = Config.get("enemies").shooter.velocity.x;
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
        this.lastVyChange = GameTime.now();
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        var perturbance = Config.get("enemies").shooter.perturbance;
        var now = GameTime.now();
        if (now.elapsedSeconds - lastVyChange.elapsedSeconds >= Config.get("enemies").shooter.sustainVyForSeconds)
        {
            lastVyChange = now;
            this.velocity.y *= -1;   
        }
    }
}