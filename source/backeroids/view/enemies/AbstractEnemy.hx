package backeroids.view.enemies;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import helix.core.HelixSprite;
import helix.data.Config;

class AbstractEnemy extends HelixSprite
{
    private var hasAppearedOnscreen:Bool = false;
    private static var random = new FlxRandom();

    private function new(filename, colorDetails)
    {
        super(filename, colorDetails);
        this.elasticity = Config.get("enemies").elasticity;

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
        if (this.hasAppearedOnscreen && !this.isOnScreen())
        {
            this.kill();
        }

        if (this.isOnScreen())
        {
            this.hasAppearedOnscreen = true;
        }
    }

    public function damage():Void
    {
        this.health -= 1;
        if (this.health <= 0)
        {
            this.kill();
        }
    }
}