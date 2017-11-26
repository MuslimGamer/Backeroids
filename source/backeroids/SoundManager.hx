package backeroids;

import flixel.system.FlxSound;

class SoundManager
{
    public static var playerShootSound:FlxSound = new FlxSound();
    public static var playerExplodeSound:FlxSound = new FlxSound();

    public static var asteroidDamageSound = new FlxSound();
    public static var asteroidSplitSound = new FlxSound();
    public static var enemyShootSound = new FlxSound();

    public static function init():Void
    {
        playerShootSound.loadEmbedded(AssetPaths.Laser_Shoot_0__wav);
        playerExplodeSound.loadEmbedded(AssetPaths.Explosion__wav);

        asteroidDamageSound.loadEmbedded(AssetPaths.Hit_Asteroid__wav);
        asteroidSplitSound.loadEmbedded(AssetPaths.Asteroid_Split_Explode__wav);

        enemyShootSound.loadEmbedded(AssetPaths.Laser_Shoot_1__wav);
    }
}