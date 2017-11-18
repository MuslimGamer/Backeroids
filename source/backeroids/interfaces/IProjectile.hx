package backeroids.interfaces;

import backeroids.interfaces.ISprite;

interface IProjectile extends ISprite
{
    public function shoot(angle:Float):Void;
}