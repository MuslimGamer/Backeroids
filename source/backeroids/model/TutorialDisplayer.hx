package backeroids.model;

import backeroids.tutorial.TutorialManager;
import backeroids.model.PlayStateMediator;

class TutorialDisplayer
{
    private var mediator:PlayStateMediator;

    public function new(mediator)
    {
        this.mediator = mediator;
    }

    public function showIfRequired():Void
	{
		var tutorialTag = TutorialManager.isTutorialRequired(this.mediator.getLevelNum());
		if (tutorialTag != null)
		{
			var messageWindow = this.mediator.createTutorialMessage(tutorialTag);
			messageWindow.setFinishCallback(function() {
				this.mediator.startLevel();
			});
		}
		else
		{
			this.mediator.startLevel();
		}
	}
}