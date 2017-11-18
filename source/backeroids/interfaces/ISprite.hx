package backeroids.interfaces;

import flixel.FlxSprite;

interface ISprite extends IFlxSprite
{
    public var height(get, set):Float;
    public var width(get, set):Float;
}