package backeroids.view.controls;

import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.effects.FlxFlicker;
import flash.geom.Rectangle;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;
import helix.core.HelixSprite;
import helix.GameTime;
using helix.core.HelixSpriteFluentApi;

class MessageWindow extends FlxUI9SliceSprite
{
    private static inline var TUTORIAL_WINDOW_WIDTH:Int = 400;
    private static inline var TUTORIAL_WINDOW_HEIGHT:Int = 300;
    private static var NINE_SLICE_COORDINATES = [16, 16, 48, 48];
    private static inline var FONT_SIZE:Int = 24;
    private static inline var TEXT_PADDING:Int = 8; // 8px from corners of window

    private var avatar:HelixSprite;
    private var halfAvatar:HelixSprite;
    private var textField:FlxText;
    private var currentTextMessage:Int = 0;

    private var textArray:Array<String>;
    private var finishCallback:Void->Void;
    private var lastDialogSkip:GameTime = new GameTime(0);

    public function new(messages:Array<String>)
    {
        this.textArray = messages;
        var message = this.textArray[this.currentTextMessage];
        this.textField = new FlxText(0, 0, 0, message, FONT_SIZE);
        this.avatar = new HelixSprite("assets/images/ahmad-from-hq.png");
        this.avatar.onKeyDown(function(keys:Array<FlxKey>)
        {
            var now = GameTime.now();
            if (keys.length <= 0 || now.elapsedSeconds - this.lastDialogSkip.elapsedSeconds < 0.5)
            {
                return;
            }

            this.currentTextMessage += 1;
            if (this.currentTextMessage < this.textArray.length)
            {
                this.textField.text = this.textArray[this.currentTextMessage];
                this.lastDialogSkip = now;
            }
            else
            {
                this.kill();
                this.finishCallback();
            }
        });
        
        // Make the flickering intensity less ... we can't. But we can make a half-transparent
        // clone of the sprite underneath that looks like less.
        this.halfAvatar = new HelixSprite("assets/images/ahmad-from-hq.png");
        this.halfAvatar.alpha = 0.5;

        // super constructor calls set_x which blows up if the text field is null.
        // alternatively, in the setter, check if textField is non-null first.
        // ditto for avatar.
        super(0, 0, "assets/images/ui/message-window.png",
            new Rectangle(0, 0, TUTORIAL_WINDOW_WIDTH, TUTORIAL_WINDOW_HEIGHT), NINE_SLICE_COORDINATES);

        this.textField.text = message;

        FlxFlicker.flicker(avatar, 0);
    }

    public function updateTextFieldSize():Void
    {
        this.textField.fieldWidth = this.width - this.avatar.width - 3 * TEXT_PADDING;
    }

    override public function set_x(x:Float):Float
    {
        super.set_x(x);
        this.avatar.x = x + TEXT_PADDING;
        this.halfAvatar.x = this.avatar.x;
        this.textField.x = TEXT_PADDING + this.avatar.x + this.avatar.width + TEXT_PADDING;
        return x;
    }

    override public function set_y(y:Float):Float
    {
        super.set_y(y);
        this.avatar.y = y + TEXT_PADDING;
        this.halfAvatar.y = this.avatar.y;
        this.textField.y = this.avatar.y;
        return y;
    }

    override public function kill():Void
    {
        super.kill();
        this.avatar.kill();
        this.halfAvatar.kill();
        this.textField.kill();
    }

    public function setFinishCallback(callback:Void->Void):Void
    {
        this.finishCallback = callback;
    }

    public function getDrawables():FlxGroup
    {
        // Controls draw order
        var group = new FlxGroup();
        group.add(this);
        group.add(this.halfAvatar);
        group.add(this.avatar);
        group.add(this.textField);
        return group;
    }
}