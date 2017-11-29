package backeroids.view;

import helix.core.HelixSprite;
import helix.data.Config;
import helix.GameTime;

class Shield extends HelixSprite
{
    public var shieldHealth:Int = Config.get('ship').shield.health;
    private var totalShieldHealth:Int = Config.get('ship').shield.health;
    public var working:Bool = true;
    public var isOn = false;
    private var lastRecharge:GameTime = new GameTime(0);
    private var lastDamage:GameTime = new GameTime(0);
    private var indicatorCallback:Void->Void = null;

    override public function new():Void
    {
        super("assets/images/shield.png");
        this.immovable = true;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);

        var now = GameTime.now();
        if (now.elapsedSeconds - this.lastRecharge.elapsedSeconds > Config.get('ship').shield.secondsPerRecharge)
        {
            if (this.shieldHealth < this.totalShieldHealth)
            {
                this.shieldHealth += 1;
                if (this.indicatorCallback != null)
                {
                    this.indicatorCallback();
                }
            }
            this.lastRecharge = now;
        }
    }

    public function damage():Void
    {
        var now = GameTime.now();
        if (now.elapsedSeconds - this.lastDamage.elapsedSeconds > 0.4)
        {
            this.shieldHealth -= 1;
            if (this.indicatorCallback != null)
                {
                    this.indicatorCallback();
                }
            if (this.shieldHealth <= 0)
            {
                this.kill();
                this.working = false;
                this.deactivate();
            }
            this.lastDamage = now;
        }
    }

    public function activate():Void
    {
        this.isOn = true;
        this.visible = true;
    }

    public function deactivate():Void
    {
        this.isOn = false;
        this.visible = false;
    }

    public function resetShield():Void
    {
        this.revive();
        this.shieldHealth = Config.get('ship').shield.health;
        this.working = true;
    }

    public function setIndicatorCallback(callback):Void
    {
        this.indicatorCallback = callback;
    }
}