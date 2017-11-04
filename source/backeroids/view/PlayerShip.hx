package backeroids.view;
 
import helix.core.HelixSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;

class PlayerShip extends HelixSprite
{
    public function new():Void
    {
        super("assets/images/ship.png");

        super.addKeyBind(["LEFT", "A"], this.rotateLeft);
        super.addKeyBind(["RIGHT", "D"], this.rotateRight);
        super.addMovement(["UP", "W"], this.accelerateForward);
    }

    private function rotateLeft():Void
    {
        this.angle -= 2.5;
    }
    private function rotateRight():Void
    {
        this.angle += 2.5;
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