package backeroids.view;
 
import helix.core.HelixSprite;

class PlayerShip extends HelixSprite
{
    public function new():Void
    {
        super("assets/images/ship.png");
    }
    
    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
    }
}