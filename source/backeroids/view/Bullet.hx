package backeroids.view;

import backeroids.view.Projectile;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import helix.data.Config;

class Bullet extends Projectile
{
    public function new():Void
    {
        super(null, {width: 2, height: 8, colour: FlxColor.fromString('white')}, Config.get("gun").bulletVelocity);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (Config.get("features").wrapBullets) {
            FlxSpriteUtil.screenWrap(this);
        }
    }
}