package backeroids;

import flixel.system.FlxSound;

class SoundManager
{
    public static var playerShootSound:FlxSound = new FlxSound();
    public static var playerExplodeSound:FlxSound = new FlxSound();

    public static var asteroidHitSound = new FlxSound();
    public static var asteroidSplitSound = new FlxSound();

    public static var buttonClickSound = new FlxSound();

    public static var enemyShootSound = new FlxSound();
    public static var enemyHitSound = new FlxSound();
    public static var enemyExplodeSound = new FlxSound();

    public static function init():Void
    {
        playerShootSound.loadEmbedded(AssetPaths.Laser_Shoot_0__wav);
        playerExplodeSound.loadEmbedded(AssetPaths.Explosion__wav);

        asteroidHitSound.loadEmbedded(AssetPaths.Hit_Asteroid__wav);
        asteroidSplitSound.loadEmbedded(AssetPaths.Asteroid_Split_Explode__wav);

        enemyShootSound.loadEmbedded(AssetPaths.Laser_Shoot_1__wav);
        enemyHitSound.loadEmbedded(AssetPaths.Hit_Enemy__wav);
        enemyExplodeSound.loadEmbedded(AssetPaths.Enemy_Explode__wav);

        buttonClickSound.loadEmbedded(AssetPaths.Button_Click__wav);
    }
}