package backeroids.view;

import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import backeroids.view.PlayerShip;
import backeroids.view.Asteroid;
import helix.core.HelixSprite;
import helix.data.Config;
using helix.core.HelixSpriteFluentApi;

class Bullet extends HelixSprite
{
    public function new():Void
    {
        super(null, {width: 8, height: 8, colour: FlxColor.fromString('white')});
        this.move(-100, -100);
        this.exists = false;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (Config.get("features").wrapBullets) {
            FlxSpriteUtil.screenWrap(this);
        }
    }
}