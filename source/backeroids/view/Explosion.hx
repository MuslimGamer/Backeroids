package backeroids.view;

import helix.core.HelixSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class Explosion extends HelixSprite
{
    private var killTimer = new FlxTimer();

    public function new():Void
    {
        super("assets/images/explosion.png");
        this.immovable = true;
        this.kill();
    }

    public function resetView():Explosion
    {
        this.alpha = 1;
        this.scale.set(1, 1);
        this.color = 0xFFff8000;
        this.revive();

        return this;
    }

    public function explode():Void
    {
        FlxTween.tween(this, {alpha: 0}, 0.5);
        this.scale.set(0.5, 0.5);
        FlxTween.tween(this.scale, {x: 1.2, y: 1.2}, 0.5);
        this.killTimer.start(0.5, function(timer):Void
        {
            this.kill();
        }, 1);
    }
}