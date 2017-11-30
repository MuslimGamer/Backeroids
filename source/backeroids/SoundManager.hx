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
    public static var mineExplode = new FlxSound();

    public static var heartBeatLogoSound = new FlxSound();
    public static var nightingaleLogoSound = new FlxSound();

    public static function init():Void
    {
        playerShoot.loadEmbedded(AssetPaths.Laser_Shoot_0__ogg);
        playerExplode.loadEmbedded(AssetPaths.Player_Explode__ogg);

        asteroidHit.loadEmbedded(AssetPaths.Hit_Asteroid__ogg);
        asteroidSplit.loadEmbedded(AssetPaths.Asteroid_Split_Explode__ogg);

        enemyShoot.loadEmbedded(AssetPaths.Laser_Shoot_1__ogg);
        enemyHit.loadEmbedded(AssetPaths.Hit_Enemy__ogg);
        enemyExplode.loadEmbedded(AssetPaths.Enemy_Explode__ogg);

        buttonClick.loadEmbedded(AssetPaths.Button_Click__ogg);

        shooterAmbient.loadEmbedded(AssetPaths.Shooter_Ambient__ogg);
        mineExplode.loadEmbedded(AssetPaths.Explosion__ogg);

        heartBeatLogoSound.loadEmbedded(AssetPaths.heartbeat__ogg);
        nightingaleLogoSound.loadEmbedded(AssetPaths.nightingale__ogg);
    }
}