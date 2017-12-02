package backeroids.prototype;

import flixel.FlxBasic;
import flixel.FlxG;

class Collision
{
    // collide
    public var collisionTargets = new Array<CollisionMetadata>();
    // collideResolve
    public var collideAndResolveTargets = new Array<CollisionMetadata>();

    public function new():Void
    {

    }

    public function collideResolve(objectOrGroup1:FlxBasic, objectOrGroup2:FlxBasic, ?callback:Dynamic->Dynamic->Void = null):Collision
    {
        return this.genericCollide(objectOrGroup1, objectOrGroup2, callback, this.collideAndResolveTargets);
    }

    public function collide(objectOrGroup1:FlxBasic, objectOrGroup2:FlxBasic, ?callback:Dynamic->Dynamic->Void):Collision
    {
        return this.genericCollide(objectOrGroup1, objectOrGroup2, callback, this.collisionTargets);
    }

    private function genericCollide(objectOrGroup1:FlxBasic, objectOrGroup2:FlxBasic, ?callback:Dynamic->Dynamic->Void = null, collisionArray:Array<CollisionMetadata>):Collision
    {
        if (callback == null)
        {
            callback = function(obj1:ICollidable, obj2:ICollidable):Void
            {
                obj1.collide();
                obj2.collide();
            }
        }
        collisionArray.push({obj1: objectOrGroup1, obj2: objectOrGroup2, callback: callback});

        return this;
    }

    public function update(elapsedSeconds:Float):Void
    {
        for (collision in collisionTargets)
        {
            FlxG.overlap(collision.obj1, collision.obj2, collision.callback);
        }

        // Collide with specified targets
        for (collision in collideAndResolveTargets)
        {
            FlxG.collide(collision.obj1, collision.obj2, collision.callback);
        }
    }

}

typedef CollisionMetadata ={
    obj1: FlxBasic,
    obj2: FlxBasic,
    callback: Dynamic->Dynamic->Void
}