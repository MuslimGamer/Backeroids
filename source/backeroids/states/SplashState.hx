package backeroids.states;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import helix.core.HelixSprite;
import helix.core.HelixState;
import helix.data.Config;

class SplashState extends HelixState
{

    private var DISPLAY_TIME_SECONDS:Float;
    private var FADE_TIME_SECONDS:Float;
    private var image:HelixSprite;
    private var onComplete:Void->Void;
    private var imageFile:String;
    private var audioFile:FlxSound;

    public function new(imageFile:String, audioFile:FlxSound, onComplete:Void->Void)
    {
        super();
        this.imageFile = imageFile;
        this.audioFile = audioFile;
        this.onComplete = onComplete;
    }

    override public function create()
    {
        super.create();

        this.DISPLAY_TIME_SECONDS = Config.get("splashDisplayTimeSeconds");
        this.FADE_TIME_SECONDS = Config.get("splashFadeTimeSeconds");

        image = new HelixSprite(imageFile);
        image.x = (FlxG.width - image.width) / 2;
        image.y = (FlxG.height - image.height) / 2;
        image.alpha = 0;
        this.audioFile.play();

        var onComplete = function(tween):Void
        {
            this.onComplete();
        }
        
        FlxTween.tween(image, {alpha: 1}, this.FADE_TIME_SECONDS)
                .then(FlxTween.tween(image, {alpha: 0}, this.FADE_TIME_SECONDS, {onComplete: onComplete}));
    }
}