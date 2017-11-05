package backeroids.view;

import helix.core.HelixSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxRandom;

class Asteroid extends HelixSprite
{
    public function new():Void
    {
        super(null, {width: 60, height: 60, colour: FlxColor.fromString('gray')});
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        FlxSpriteUtil.screenWrap(this);
    }

    public function respawn():Void
    {
        var random = new FlxRandom();
        this.velocity.set(random.int(-60, 60, [0]), random.int(-60, 60, [0]));
    }
}