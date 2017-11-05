package backeroids.view;
 
import helix.core.HelixSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
using helix.core.HelixSpriteFluentApi;

class PlayerShip extends HelixSprite
{
    public function new():Void
    {
        super("assets/images/ship.png");

        this.addKeyBind(["LEFT", "A"], this.rotateLeft);
        this.addKeyBind(["RIGHT", "D"], this.rotateRight);
        this.addKeyBind(["UP", "W"], this.accelerateForward);
    }

    private function rotateLeft():Void
    {
        this.angularVelocity -= 200;
    }
    private function rotateRight():Void
    {
        this.angularVelocity += 200;
    }
    private function accelerateForward():Void
    {
        this.acceleration.set(0, -90); 
        this.acceleration.rotate(FlxPoint.weak(0, 0), this.angle);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        FlxSpriteUtil.screenWrap(this);
    }
}