package backeroids.view;
 
import helix.core.HelixSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
using helix.core.HelixSpriteFluentApi;
using Lambda;

class PlayerShip extends HelixSprite
{
    public function new():Void
    {
        super("assets/images/ship.png");

        this.onKeyDown(this.processControls);
    }

    private function resetAcceleration():Void
    {
        this.acceleration.set();
        this.angularVelocity = 0;
    }

    private function processControls(keys:Array<FlxKey>):Void
    {
        this.resetAcceleration();
        if (keys.has(FlxKey.LEFT) || keys.has(FlxKey.A)) { 
            this.rotateLeft(); 
        }
        if (keys.has(FlxKey.RIGHT) || keys.has(FlxKey.D)) { 
            this.rotateRight(); 
        }
        if (keys.has(FlxKey.UP) || keys.has(FlxKey.W)) { 
            this.accelerateForward(); 
        }
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