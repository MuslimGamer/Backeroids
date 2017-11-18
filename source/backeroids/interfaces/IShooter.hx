package backeroids.interfaces;

import helix.GameTime;
import backeroids.interfaces.IProjectile;
import flixel.FlxSprite;

interface IShooter extends IFlxSprite
{
    public var height(get, set):Float;
    public var width(get, set):Float;
    public var lastShot:GameTime;
    public var recycleProjectileCallback:Void->IProjectile;
}