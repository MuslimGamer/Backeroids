package backeroids.states;

import backeroids.SoundManager;
import flixel.FlxG;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;
import helix.core.HelixState;
import helix.data.Config;
import helix.GameTime;

class SplashState extends HelixState
{

    private var DISPLAY_TIME_SECONDS:Float = Config.get("splashDisplayTimeSeconds");
    private var FADE_TIME_SECONDS:Float = Config.get("splashFadeTimeSeconds");
    private var start:GameTime;
    private var image:HelixSprite;
    private var onComplete:Void->Void;
    private var isDone:Bool = false;
    private var imageFile:String;
    private var audioFile:String;

    public function new(imageFile:String, audioFile:String, onComplete:Void->Void)
    {
        super();
        this.imageFile = imageFile;
        this.audioFile = audioFile;
        this.onComplete = onComplete;
        // TODO: play audio
    }

    override public function create()
    {
        super.create();

        image = new HelixSprite(imageFile);
        image.x = (FlxG.width - image.width) / 2;
        image.y = (FlxG.height - image.height) / 2;
        image.alpha = 0;
        start = GameTime.now();
    }

    override public function update(elapsedSeconds:Float):Void
    {
        super.update(elapsedSeconds);
        var time = GameTime.now().elapsedSeconds - start.elapsedSeconds;
        // Poor man's state machine
        if (time <= FADE_TIME_SECONDS)
        {
            // image fading in
            image.alpha += (1 / FADE_TIME_SECONDS * elapsedSeconds);
        }
        else if (time > FADE_TIME_SECONDS && time <= FADE_TIME_SECONDS + DISPLAY_TIME_SECONDS)
        {
            // image showing; do nothing
        }
        else if (time > FADE_TIME_SECONDS + DISPLAY_TIME_SECONDS && time <= FADE_TIME_SECONDS + DISPLAY_TIME_SECONDS + FADE_TIME_SECONDS)
        {
            // image fading out
            image.alpha -= (FADE_TIME_SECONDS * elapsedSeconds);
        }
        else if (!isDone)
        {
            isDone = true;
            this.onComplete();
        }
    }
}