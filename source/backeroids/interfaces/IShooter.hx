package backeroids.interfaces;

import helix.GameTime;
import backeroids.interfaces.IProjectile;
import backeroids.interfaces.ISprite;

interface IShooter extends ISprite
{
    public var lastShot:GameTime;
    public var recycleProjectileCallback:Void->IProjectile;
}