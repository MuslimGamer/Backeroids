package backeroids.model;

import helix.GameTime;
import backeroids.model.Projectile;
import flixel.FlxSprite;

interface IShooter extends IFlxSprite
{
    public var height(get, set):Float;
    public var width(get, set):Float;
    public var lastShot:GameTime;
    public var recycleProjectileCallback:Void->Projectile;
}