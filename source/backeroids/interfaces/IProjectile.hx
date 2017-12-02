package backeroids.interfaces;

import backeroids.interfaces.ISprite;
import backeroids.prototype.ICollidable;

interface IProjectile extends ISprite extends ICollidable
{
    public function shoot(angle:Float):Void;
}