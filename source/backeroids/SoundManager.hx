package backeroids;

import flixel.system.FlxSound;

class SoundManager
{
    public static var playerShoot = new FlxSound();
    public static var playerExplode = new FlxSound();

    public static var asteroidHit = new FlxSound();
    public static var asteroidSplit = new FlxSound();

    public static var buttonClick = new FlxSound();

    public static var enemyShoot = new FlxSound();
    public static var enemyHit = new FlxSound();
    public static var enemyExplode = new FlxSound();

    public static var shooterAmbient = new FlxSound();

    public static function init():Void
    {
        playerShoot.loadEmbedded(AssetPaths.Laser_Shoot_0__wav);
        playerExplode.loadEmbedded(AssetPaths.Explosion__wav);

        asteroidHit.loadEmbedded(AssetPaths.Hit_Asteroid__wav);
        asteroidSplit.loadEmbedded(AssetPaths.Asteroid_Split_Explode__wav);

        enemyShoot.loadEmbedded(AssetPaths.Laser_Shoot_1__wav);
        enemyHit.loadEmbedded(AssetPaths.Hit_Enemy__wav);
        enemyExplode.loadEmbedded(AssetPaths.Enemy_Explode__wav);

        buttonClick.loadEmbedded(AssetPaths.Button_Click__wav);

        shooterAmbient.loadEmbedded(AssetPaths.Shooter_Ambient__wav);
    }
}