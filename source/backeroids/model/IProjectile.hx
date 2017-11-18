package backeroids.model;

import flixel.FlxSprite;

interface IProjectile extends IFlxSprite
{
    public var height(get, set):Float;
    public var width(get, set):Float;
    public function shoot(angle:Float):Void;
}