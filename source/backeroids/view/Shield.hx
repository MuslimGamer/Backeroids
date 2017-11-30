package backeroids.view;

import backeroids.SoundManager;
import helix.core.HelixSprite;
import helix.data.Config;
import helix.GameTime;

class Shield extends HelixSprite
{
    public var shieldHealth:Int;
    private var totalShieldHealth:Int;
    public var functional:Bool = true;
    public var isActivated = false;
    private var lastRecharge:GameTime = new GameTime(0);
    private var lastDamage:GameTime = new GameTime(0);
    private var indicatorCallback:Void->Void = null;

    override public function new():Void
    {
        super("assets/images/shield.png");
        this.immovable = true;
        
        var conf = Config.get('ship').shield;
        this.shieldHealth = conf.health;
        this.totalShieldHealth = conf.health;

        this.deactivate();
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
        SoundManager.shieldHit.play(true);
        var now = GameTime.now();
        if (now.elapsedSeconds - this.lastDamage.elapsedSeconds > Config.get('ship').shield.invincibleSeconds)
        {
            this.shieldHealth -= 1;
            if (this.indicatorCallback != null)
            {
                this.indicatorCallback();
            }
            if (this.shieldHealth <= 0)
            {
                this.kill();
                this.functional = false;
                this.deactivate();
            }
            this.lastDamage = now;
        }
    }

    public function activate():Void
    {
        this.isActivated = true;
        this.visible = true;
    }

    public function deactivate():Void
    {
        this.isActivated = false;
        this.visible = false;
    }

    public function resetShield():Void
    {
        this.revive();
        this.shieldHealth = Config.get('ship').shield.health;
        if (this.indicatorCallback != null)
        {
            this.indicatorCallback();
        }
        this.functional = true;
    }

    public function setIndicatorCallback(callback):Void
    {
        this.indicatorCallback = callback;
    }
}