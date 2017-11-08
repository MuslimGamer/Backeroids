package backeroids.view;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import backeroids.view.PlayerShip;
import backeroids.view.Asteroid;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;

class Bullet extends HelixSprite
{
    public function new():Void
    {
        super(null, {width: 8, height: 8, colour: FlxColor.fromString('white')});
        this.move(-100, -100);
        this.exists = false;
    }

    public function shoot(ship:PlayerShip):Void
    {
        this.reset(ship.x + (ship.width - this.width) / 2, ship.y + (ship.height - this.height) / 2);
        this.angle = ship.angle;

        this.velocity.set(0, -150);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        FlxSpriteUtil.screenWrap(this);
    }
}