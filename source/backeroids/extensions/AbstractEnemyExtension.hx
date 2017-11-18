package backeroids.extensions;

import flixel.FlxG;
import flixel.math.FlxRandom;
import backeroids.view.enemies.AbstractEnemy;

class AbstractEnemyExtension
{
    public static function moveSideways(sprite:AbstractEnemy, yVelocity, random:FlxRandom):Void
    {
        sprite.velocity.y = (random.bool() == true ? -1 : 1) * yVelocity;

        var isGoingRight = random.bool();
        if (isGoingRight)
        {
            sprite.x = -sprite.width;
        }
        else
        {
            sprite.x = FlxG.width;
            sprite.velocity.x *= -1;
        }

        sprite.y = random.int(Std.int(FlxG.height / 4), Std.int(3 * FlxG.height / 4));
    }
}