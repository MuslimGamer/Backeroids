package backeroids.view.enemies;

import helix.core.HelixSprite;
import helix.data.Config;

class AbstractEnemy extends HelixSprite
{
    private var hasAppearedOnscreen:Bool = false;

    private function new(filename, colorDetails)
    {
        super(filename, colorDetails);
        this.elasticity = Config.get("enemies").elasticity;
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        if (this.hasAppearedOnscreen && !this.isOnScreen())
        {
            this.kill();
        }

        if (this.isOnScreen())
        {
            this.hasAppearedOnscreen = true;
        }
    }
}