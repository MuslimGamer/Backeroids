package backeroids.states;

import backeroids.states.PlayState;
import flixel.FlxG;
import flixel.util.FlxSave;
import helix.core.HelixSprite;
using helix.core.HelixSpriteFluentApi;
import helix.core.HelixState;
import helix.data.Config;

class LevelSelectState extends HelixState
{
    private static inline var PADDING:Int = 32;

    override public function create()
    {
        super.create();

        var numLevels = Config.get("totalLevels");
        var save = FlxG.save;
        if (save.data.currentLevel == null)
        {
            save.data.currentLevel = 1;
            save.flush();
        }

        var selectLevel  = new HelixSprite("assets/images/ui/select-level.png");
        selectLevel.x = (FlxG.width - selectLevel.width) / 2;
        selectLevel.y = PADDING;

        for (i in 0 ... numLevels)
        {
            // two rows of 3-4 buttons each
            var levelNum = i + 1;
            var filename = "level-button";
            if (levelNum > save.data.currentLevel)
            {
                filename += "-disabled";
            }

            var sprite = new HelixSprite('assets/images/ui/${filename}.png');
            var xOffset = (FlxG.width - (2 * PADDING) - (numLevels / 2 * sprite.width)) / 2;
            
            sprite.x = xOffset + ((i % (numLevels / 2)) * sprite.width * 2);
            sprite.y = selectLevel.y + selectLevel.height + (2 * PADDING) + (i >= numLevels / 2 ? 2 * sprite.height : 0);

            sprite.onClick(function()
            {
                if (levelNum <= save.data.currentLevel)
                {
                    FlxG.switchState(new PlayState());
                }
                // else, play "denied" sfx
            });
        }
    }    
}