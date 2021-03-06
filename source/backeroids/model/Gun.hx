package backeroids.model;

import helix.GameTime;
import helix.data.Config;

class Gun
{
    private var lastShotAt:GameTime = GameTime.now();
    private var fireCooldownSeconds:Float;

    public function new():Void
    {
        this.fireCooldownSeconds = Config.get("gun").fireCooldownSeconds;
    }

    public function canFire():Bool
    {
        var now = GameTime.now();
        if (now.elapsedSeconds - this.lastShotAt.elapsedSeconds > this.fireCooldownSeconds) 
        {
            this.lastShotAt = now;
            return true;
        }
        else
        {
            return false;
        }
    }
}