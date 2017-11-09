package backeroids.view;

import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxPoint;
import backeroids.view.PlayerShip;
import backeroids.view.Asteroid;
import backeroids.model.Gun;
import helix.core.HelixSprite;
import helix.data.Config;
using helix.core.HelixSpriteFluentApi;

class Bullet extends HelixSprite
{
    private var playerShip:PlayerShip;

    public function new(ship:PlayerShip):Void
    {
        super(null, {width: 8, height: 8, colour: FlxColor.fromString('white')});
        this.kill();

        this.playerShip = ship;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (Config.get("features").wrapBullets) {
            FlxSpriteUtil.screenWrap(this);
        }
    }

    public function shoot(vector:Vector):Void
    {
        this.revive();
        this.move(vector.x + (vector.width - this.width) / 2, vector.y + (vector.height - this.height) / 2);
        this.angle = vector.angle;

        this.velocity.set(0, -Config.get("gun").bulletVelocity);
        this.velocity.rotate(FlxPoint.weak(0, 0), this.angle);
    }
}

typedef Vector ={
    x: Float,
    y: Float,
    angle: Float,
    width: Float,
    height: Float
}