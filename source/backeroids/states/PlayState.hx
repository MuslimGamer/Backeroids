package backeroids.states;

import backeroids.model.PlayStateMediator;
import backeroids.states.PauseSubState;
import backeroids.tutorial.TutorialManager;
import backeroids.view.controls.MessageWindow;
import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import helix.core.HelixState;
import helix.data.Config;

class PlayState extends HelixState
{
	private static var NUM_INITIAL_ASTEROIDS:Int;
	private static var SECONDS_PER_ASTEROID:Int;
	private static var SECONDS_PER_ENEMY:Int;

	private var random = new FlxRandom();

	private var mediator:PlayStateMediator;
	private var pauseSubState = new PauseSubState();

	private var waveCounter:FlxText = null;
	private var livesCounter:FlxText = null;
	private var shieldCounter:FlxText = null;

	override public function new(levelNum):Void
	{
		super();
		this.mediator = new PlayStateMediator(this, levelNum);
	}

	override public function create():Void
	{
		super.create();
		
		this.destroySubStates = false;
		FlxG.mouse.load(AssetPaths.crosshairs__png);

		NUM_INITIAL_ASTEROIDS = Config.get("asteroids").initialNumber;
		SECONDS_PER_ASTEROID = Config.get("asteroids").secondsToSpawn;
		SECONDS_PER_ENEMY = Config.get("enemies").secondsToSpawn;

		this.mediator.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (this.isKeyPressed(FlxKey.ESCAPE) || (this.mediator.levelLost() && this.isKeyPressed(FlxKey.ANY)))
		{
			this.exitState();
			return;
		}
		if (this.wasJustPressed(FlxKey.P))
		{
			this.pause();
		}
		this.mediator.update(elapsed);
	}

	public function makeShieldCounter(shieldHealth:Int):Void
	{
		this.shieldCounter = this.makeText('Shield: ${shieldHealth}', 16);
		this.shieldCounter.x = FlxG.width - this.shieldCounter.textField.textWidth;
		this.shieldCounter.y = this.livesCounter.textField.textHeight;
	}
	
	public function updateShieldCounter(shieldHealth:Int):Void
	{
		this.shieldCounter.text = 'Shield: ${shieldHealth}';
	}

	public function makeLivesCounter(lives:Int):Void
	{
		this.livesCounter = this.makeText('Lives: ${lives}', 16);
		this.livesCounter.x = FlxG.width - this.livesCounter.textField.textWidth;
	}

	public function updateLivesCounter(lives:Int):Void
	{
		this.livesCounter.text = 'Lives: ${lives}';
	}

	public function makeWaveCounter(waveNum:Int):Void
	{
		this.waveCounter = this.makeText('Wave: 0/${waveNum}', 16);
	}

	public function updateWaveCounter(currentWaveNumber:Int, waveNum:Int):Void
	{
		this.waveCounter.text = 'Wave: ${currentWaveNumber}/${waveNum}';
	}

	public function makeText(text:String, textSize:Int = 16):FlxText
	{
		var textField = new FlxText(1, 1, FlxG.width, text);
		textField.setFormat(null, textSize, 0xFFFFFFFF);
		add(textField);
		return textField;
	}

	public function showGameOverText():Void
	{
		var gameOverText = this.makeText('GAME OVER!\nPress anything to exit.');
		gameOverText.x = (FlxG.width / 2) - (gameOverText.textField.textWidth / 2);
		gameOverText.y = (FlxG.height / 2) - (gameOverText.textField.textHeight / 2);
	}

	public function showGameWinText():Void
	{
		var gameWinText = this.makeText('YOU WIN!\nPress anything to exit.');
		gameWinText.x = (FlxG.width / 2) - (gameWinText.textField.textWidth / 2);
		gameWinText.y = (FlxG.height / 2) - (gameWinText.textField.textHeight / 2);
		
	}
	
	public function showWaveCompleteText(waveNumber:Int):Void
	{
		var waveCompleteText = this.makeText('Wave ${waveNumber} complete!', 32);
		waveCompleteText.alpha = 0;
		waveCompleteText.x = FlxG.width / 2 - waveCompleteText.textField.textWidth / 2;
		waveCompleteText.y = FlxG.height / 2 - waveCompleteText.textField.textHeight / 3;

		FlxTween.tween(waveCompleteText, {alpha: 1}, 0.5)
				.then(FlxTween.tween(waveCompleteText, {alpha: 1}, 0.5)
					.then(FlxTween.tween(waveCompleteText, {alpha: 0}, 0.5, {
						onComplete: function(tween)
						{
							waveCompleteText.kill();
						}
					}
				)
			)
		);
	}

	public function createTutorialMessage(tutorialTag:String):MessageWindow
	{
		var messageWindow = TutorialManager.createTutorialWindow(tutorialTag);
		messageWindow.x = (FlxG.width - messageWindow.width) / 2;
		messageWindow.y = (FlxG.height - messageWindow.height) / 2;

		var group = messageWindow.getDrawables();
		this.add(group);

		return messageWindow;
	}

	public function pause():Void
	{
		FlxTimer.globalManager.forEach(function(timer:FlxTimer)
		{
			timer.active = false;
		});
		this.openSubState(this.pauseSubState);
	}

	public function exitState():Void
	{
		FlxG.mouse.unload();
		FlxG.switchState(new LevelSelectState());
	}
}
