package;

import flixel.FlxObject;
import flixel.util.FlxAxes;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;
import flxanimate.FlxAnimate;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import funkin.vis.dsp.SpectralAnalyzer;

class ABotSpeaker extends FlxTypedSpriteGroup<FlxSprite>
{
	public var bg:FlxSprite;
	public var vizSprites:Array<FlxSprite> = [];
	public var eyeBg:FlxSprite;
	public var eyes:FlxAnimate;
	public var speaker:FlxAnimate;

	final VIZ_MAX = 7;
	final VIZ_POS_X:Array<Float> = [0, 59, 56, 66, 54, 52, 51];
	final VIZ_POS_Y:Array<Float> = [0, -8, -3.5, -0.4, 0.5, 4.7, 7];

	var analyzer:SpectralAnalyzer;

	public var snd(default, set):FlxSound;
	function set_snd(changed:FlxSound)
	{
		snd = changed;
		initAnalyzer();
		return snd;
	}

	public function new(x:Float, y:Float) {
		super(x, y);

		bg = new FlxSprite(-100 + 150, 216 + 30).loadGraphic(Paths.image('abot/stereoBG'));
		bg.antialiasing = true;
		add(bg);

		var vizX:Float = 0;
		var vizY:Float = 0;
		var vizFrames = Paths.getSparrowAtlas('aBotViz');
		for (i in 1...VIZ_MAX+1)
		{
			vizX += VIZ_POS_X[i-1];
			vizY += VIZ_POS_Y[i-1];
			var viz:FlxSprite = new FlxSprite(vizX, vizY);
			viz.frames = vizFrames;
			viz.animation.addByPrefix('VIZ', 'viz$i', 0);
			viz.animation.play('VIZ', true);
			viz.animation.curAnim.finish();
			viz.antialiasing = true;
			vizSprites.push(viz);
			viz.updateHitbox();
			viz.centerOffsets();
			add(viz);
			viz.visible = false;
			viz.x += -100 + 200;
			viz.y += 216 + 84;
		}

		eyeBg = new FlxSprite(-100 + 40, 216 + 250).makeGraphic(1, 1, FlxColor.WHITE);
		eyeBg.scale.set(160, 60);
		eyeBg.updateHitbox();
		add(eyeBg);

		eyes = new FlxAnimate(-100 - 507, 216 - 492);
		Paths.loadAnimateAtlas(eyes, 'abot/systemEyes');
		eyes.anim.addBySymbolIndices('lookleft', 'a bot eyes lookin', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], 24, false);
		eyes.anim.addBySymbolIndices('lookright', 'a bot eyes lookin', [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35], 24, false);
		eyes.anim.play('lookright', true);
		eyes.anim.curInstance.matrix.tx = 562.9;
		eyes.anim.curInstance.matrix.ty = 731.2;
		eyes.anim.curFrame = eyes.anim.length - 1;
		add(eyes);

		speaker = new FlxAnimate(-100, 216);
		Paths.loadAnimateAtlas(speaker, 'abot/abotSystem');
		speaker.anim.addBySymbol('anim', 'Abot System', 24, false);
		speaker.anim.play('anim', true);
		speaker.anim.curFrame = speaker.anim.length - 1;
		speaker.antialiasing = true;
		add(speaker);
	}

	var lookingAtRight:Bool = true;
	public function lookLeft()
	{
		if(lookingAtRight) eyes.anim.play('lookleft', true);
		eyes.anim.curInstance.matrix.tx = 562.9;
		eyes.anim.curInstance.matrix.ty = 731.2;
		lookingAtRight = false;
	}
	public function lookRight()
	{
		if(!lookingAtRight) eyes.anim.play('lookright', true);
		eyes.anim.curInstance.matrix.tx = 562.9;
		eyes.anim.curInstance.matrix.ty = 731.2;
		lookingAtRight = true;
	}

	public function initAnalyzer()
	{
		@:privateAccess
		analyzer = new SpectralAnalyzer(snd._channel.__source, 7, 0.1, 40);
		analyzer.minDb = -65;
		analyzer.maxDb = -25;
		analyzer.maxFreq = 22000;
		analyzer.minFreq = 10;
	
		#if desktop
		analyzer.fftN = 256;
		#end
	}

	var levelMax:Int = 0;
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var levels = (analyzer != null) ? analyzer.getLevels() : getDefaultLevels();
		var oldLevelMax = levelMax;
		levelMax = 0;
		for (i in 0...Std.int(Math.min(vizSprites.length, levels.length)))
		{
			var animFrame:Int = Math.round(levels[i].value * 6);

			vizSprites[i].visible = animFrame > 0;

			animFrame -= 1;

			animFrame = Std.int(Math.abs(FlxMath.bound(animFrame, 0, 5) - 5));
		
			vizSprites[i].animation.curAnim.curFrame = animFrame;

			levelMax = Std.int(Math.max(levelMax, 5 - animFrame));
		}
	}

  static final BAR_COUNT:Int = 7;

  static function getDefaultLevels():Array<Bar>
  {
    var result:Array<Bar> = [];

    for (i in 0...BAR_COUNT)
    {
      result.push({value: 0, peak: 0.0});
    }

    return result;
  }
}