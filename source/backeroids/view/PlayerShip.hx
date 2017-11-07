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
    // TODO: should be in config.json
    private static inline var ROTATION_VELOCITY:Int = 200;
    private static inline var ACCELERATION:Int = 90;
    private static inline var DECELERATION_MULTIPLIER:Float = 2;

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

        if (keys.has(FlxKey.LEFT) || keys.has(FlxKey.A))
        { 
            this.angularVelocity = -ROTATION_VELOCITY;            
        }
        else if (keys.has(FlxKey.RIGHT) || keys.has(FlxKey.D))
        { 
            this.angularVelocity = ROTATION_VELOCITY;
        }
        else if (keys.has(FlxKey.UP) || keys.has(FlxKey.W))
        { 
            this.accelerateForward(ACCELERATION); 
        }
        else if (keys.has(FlxKey.DOWN) || keys.has(FlxKey.S))
        {
            this.accelerateForward(-ACCELERATION * DECELERATION_MULTIPLIER); 
        }
    }

    private function accelerateForward(acceleration:Int):Void
    {
        this.acceleration.set(0, -acceleration); 
        this.acceleration.rotate(FlxPoint.weak(0, 0), this.angle);
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        if (FlxG.keys.getIsDown().length == 0)
        {
            this.angularVelocity = 0;
        }
        
        FlxSpriteUtil.screenWrap(this);
    }
}