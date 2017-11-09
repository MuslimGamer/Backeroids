package backeroids.model;

import helix.GameTime;
import helix.data.Config;

class Gun
{
    private var timeSinceLastShot:Float = 0;
    private var fireCooldownSeconds = Config.get("gun").fireCooldownSeconds;

    public function new():Void
    {
    }

    public function canFire():Bool
    {
        if (GameTime.totalGameTimeSeconds - this.timeSinceLastShot > this.fireCooldownSeconds) 
        {
            this.timeSinceLastShot = GameTime.totalGameTimeSeconds;
            return true;
        }
        else
        {
            return false;
        }
    }
}