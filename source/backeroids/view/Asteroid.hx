package backeroids.view;

import helix.core.HelixSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
using helix.core.HelixSpriteFluentApi;

class Asteroid extends HelixSprite
{
    public function new():Void
    {
        super(null, {width: 60, height: 60, colour: FlxColor.fromString('gray')});
        this.elasticity = 1;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        FlxSpriteUtil.screenWrap(this);
    }

    public function respawn():Void
    {
        this.velocity.set(FlxG.random.int(-60, 60, [0]), FlxG.random.int(-60, 60, [0]));
    }
}