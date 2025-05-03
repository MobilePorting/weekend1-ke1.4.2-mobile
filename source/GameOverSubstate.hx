package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flxanimate.FlxAnimate;
import flixel.system.FlxSound;
import lime.app.Application;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var deathSpriteRetry:FlxSprite;
	var deathSpriteNene:FlxSprite;

	var picoBlazin:FlxAnimate;

	static final CAMERA_ZOOM_DURATION:Float = 0.5;

	var targetCameraZoom:Float = 1.0;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'pico-playable';
		}

		super();

		Conductor.songPosition = 0;

		if(daStage != 'phillyBlazin')
		{
		bf = new Boyfriend(1925, 753, daBf);
		add(bf);

		bf.updateHitbox();
		}

if(daStage == 'phillyBlazin')
{
picoBlazin = new FlxAnimate(0, 0);
Paths.loadAnimateAtlas(picoBlazin, 'picoBlazin');
picoBlazin.anim.addBySymbolIndices('idle', 'Pico Fighting ALL ANIMS', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], 24, true);
picoBlazin.anim.addBySymbolIndices('block', 'Pico Fighting ALL ANIMS', [14, 15, 16, 17, 18], 24, false);
picoBlazin.anim.addBySymbolIndices('dodge', 'Pico Fighting ALL ANIMS', [19, 20, 21, 22, 23], 24, false);
picoBlazin.anim.addBySymbolIndices('fakeout', 'Pico Fighting ALL ANIMS', [57, 58, 59, 60, 61], 24, false);
picoBlazin.anim.addBySymbolIndices('taunt', 'Pico Fighting ALL ANIMS', [62, 63, 64, 65, 66, 67], 24, false);
picoBlazin.anim.addBySymbolIndices('taunt-hold', 'Pico Fighting ALL ANIMS', [64, 65, 66, 67], 24, true);
picoBlazin.anim.addBySymbolIndices('punchHigh1', 'Pico Fighting ALL ANIMS', [24, 25, 26, 27], 24, false);
picoBlazin.anim.addBySymbolIndices('punchHigh2', 'Pico Fighting ALL ANIMS', [28, 29, 30, 31], 24, false);
picoBlazin.anim.addBySymbolIndices('punchLow1', 'Pico Fighting ALL ANIMS', [32, 33, 34, 35], 24, false);
picoBlazin.anim.addBySymbolIndices('punchLow2', 'Pico Fighting ALL ANIMS', [36, 37, 38, 39], 24, false);
picoBlazin.anim.addBySymbolIndices('hitHigh', 'Pico Fighting ALL ANIMS', [44, 45, 46, 47], 24, false);
picoBlazin.anim.addBySymbolIndices('hitLow', 'Pico Fighting ALL ANIMS', [40, 41, 42, 43], 24, false);
picoBlazin.anim.addBySymbolIndices('hitSpin', 'Pico Fighting ALL ANIMS', [78, 79, 80], 24, true);
picoBlazin.anim.addBySymbolIndices('uppercutPrep', 'Pico Fighting ALL ANIMS', [68, 69, 70, 71, 72], 24, false);
picoBlazin.anim.addBySymbolIndices('uppercut', 'Pico Fighting ALL ANIMS', [73, 74, 75, 76, 77], 24, false);
picoBlazin.anim.addBySymbolIndices('uppercutHit', 'Pico Fighting ALL ANIMS', [48, 49, 50, 51, 52, 53, 54, 55, 56], 24, false);
picoBlazin.anim.addBySymbolIndices('uppercut-hold', 'Pico Fighting ALL ANIMS', [75, 76, 77], 24, true);
picoBlazin.anim.addBySymbolIndices('firstDeath', 'Pico Fighting ALL ANIMS', [85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128], 24, false);
picoBlazin.anim.addBySymbolIndices('deathLoop', 'Pico Fighting ALL ANIMS', [129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276], 24, true);
picoBlazin.anim.addBySymbolIndices('deathConfirm', 'Pico Fighting ALL ANIMS', [277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378], 24, false);
picoBlazin.anim.play('firstDeath', true);
picoBlazin.anim.curInstance.matrix.tx = 858;
picoBlazin.anim.curInstance.matrix.ty = 770;
add(picoBlazin);
picoBlazin.antialiasing = true;
picoBlazin.scale.set(1.75, 1.75);
picoBlazin.updateHitbox();
picoBlazin.x = -424.822087053792;
picoBlazin.y = -370.611902062036;
picoBlazin.offset.x = -187.822087053792;
picoBlazin.offset.y = -235.305951031018;
picoBlazin.origin.x = 0;
picoBlazin.origin.y = 0;

targetCameraZoom = FlxG.camera.zoom * 0.8;
new FlxTimer().start(1.25, function(tmr){afterPicoDeathGutPunchIntro();});
}

		var playState = cast(FlxG.state, PlayState);
		@:privateAccess
		camFollow = new FlxObject(playState.camFollow.x, playState.camFollow.y, 1, 1);
		if(picoBlazin != null)
		{
		camFollow.x = getMidPointOld(picoBlazin).x + 1700;
		camFollow.y = getMidPointOld(picoBlazin).y + 1550;
		}
		else
		{
		camFollow.x = getMidPointOld(bf).x + 10;
		camFollow.y = getMidPointOld(bf).y + -40;
		}
		add(camFollow);

		if(playState.Explode)
		doExplosionDeath();

		if(daStage == 'phillyBlazin')
		FlxG.sound.play(Paths.sound('gameplay/gameover/fnf_loss_sfx-pico-gutpunch', 'weekend1'));
		else if(playState.Explode)
		FlxG.sound.play(Paths.sound('gameplay/gameover/fnf_loss_sfx-pico-explode', 'weekend1'));
		else
		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.target = null;

		if(bf != null && picoDeathExplosion == null)
		bf.playAnim('firstDeath');

		FlxG.camera.setFilters([]);

		if(bf != null && picoDeathExplosion == null)
		{
		createDeathSprites();

		add(deathSpriteRetry);
		deathSpriteRetry.antialiasing = true;
		add(deathSpriteNene);
		deathSpriteNene.antialiasing = true;
		deathSpriteNene.animation.play("throw");
		}

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
	}

	function afterPicoDeathGutPunchIntro():Void {
		if(isEnding) return;
		FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		picoBlazin.anim.play('deathLoop', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(picoDeathExplosion != null)
		if(picoDeathExplosion.anim.finished)
		onExplosionFinishAnim(picoDeathExplosion.anim.curSymbol.name);

		if(targetCameraZoom != 1.0)
		FlxG.camera.zoom = smoothLerp(FlxG.camera.zoom, targetCameraZoom, elapsed, CAMERA_ZOOM_DURATION);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if(bf != null && picoDeathExplosion == null)
		{
		if (bf.animation.curAnim.name == "firstDeath" && bf.animation.curAnim.curFrame == 36 - 1) {
			if (deathSpriteRetry != null && deathSpriteRetry.animation != null)
			{
				deathSpriteRetry.animation.play('idle');
				deathSpriteRetry.visible = true;

				deathSpriteRetry.x = bf.x + 195;
				deathSpriteRetry.y = bf.y - 70;
			}

			var playState = cast(FlxG.state, PlayState);

			if(!isEnding)
			{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			}
			bf.playAnim('deathLoop');
		}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			if(picoBlazin != null)
			doDeathConfirm();
			if(picoDeathExplosion != null)
			doExplosionConfirm();
			isEnding = true;
			if(deathSpriteRetry != null)
			{
			deathSpriteRetry.animation.play('confirm');
			deathSpriteRetry.x -= 250;
			deathSpriteRetry.y -= 200;
			}
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}

  function getMidPointOld(spr:FlxSprite, ?point:FlxPoint):FlxPoint
  {
    if (point == null) point = FlxPoint.get();
    return point.set(spr.x + spr.frameWidth * 0.5 * spr.scale.x, spr.y + spr.frameHeight * 0.5 * spr.scale.y);
  }

	function createDeathSprites() {
		deathSpriteRetry = new FlxSprite(0, 0);
		deathSpriteRetry.frames = Paths.getSparrowAtlas("Pico_Death_Retry", 'weekend1');

		deathSpriteRetry.animation.addByPrefix('idle', "Retry Text Loop0", 24, true);
		deathSpriteRetry.animation.addByPrefix('confirm', "Retry Text Confirm0", 24, false);

		deathSpriteRetry.visible = false;

		deathSpriteNene = new FlxSprite(0, 0);
		deathSpriteNene.frames = Paths.getSparrowAtlas("NeneKnifeToss", 'weekend1');
		deathSpriteNene.x = 1342.5;
		deathSpriteNene.y = 424;
		deathSpriteNene.origin.x = 172;
		deathSpriteNene.origin.y = 205;
		deathSpriteNene.animation.addByPrefix('throw', "knife toss0", 24, false);
		deathSpriteNene.visible = true;
		deathSpriteNene.animation.finishCallback = function(name:String)
		{
			deathSpriteNene.visible = false;
		}
	}

  public static function lerp(base:Float, target:Float, progress:Float):Float
  {
    return base + progress * (target - base);
  }

  public static function smoothLerp(current:Float, target:Float, elapsed:Float, duration:Float, precision:Float = 1 / 100):Float
  {
    if (current == target) return target;

    var result:Float = lerp(current, target, 1 - Math.pow(precision, elapsed / duration));

    if (Math.abs(result - target) < (precision * target)) result = target;

    return result;
  }

	function doDeathConfirm():Void {
		var picoDeathConfirm:FlxSprite = new FlxSprite(picoBlazin.x + 1045, picoBlazin.y + 1214);
		picoDeathConfirm.frames = Paths.getSparrowAtlas('picoBlazinDeathConfirm', 'weekend1');
		picoDeathConfirm.animation.addByPrefix('confirm', "Pico Gut Punch Death0", 24, false);
		picoDeathConfirm.animation.play('confirm');
		picoDeathConfirm.scale.set(1.75, 1.75);
		add(picoDeathConfirm);
		picoDeathConfirm.antialiasing = true;
		picoBlazin.visible = false;
	}

	var picoDeathExplosion:FlxAnimate;

	function doExplosionDeath() {
		FlxG.camera.zoom = 0.77;

		var picoDeathExplosionPath = "picoExplosionDeath";
		picoDeathExplosion = new FlxAnimate(bf.x - 640, bf.y - 340);
		Paths.loadAnimateAtlas(picoDeathExplosion, picoDeathExplosionPath);
		picoDeathExplosion.anim.addBySymbolIndices('intro', 'Pico Explode Death', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91], 24, false);
		picoDeathExplosion.anim.addBySymbolIndices('Loop Start', 'Pico Explode Death', [92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119], 24, true);
		picoDeathExplosion.anim.addBySymbolIndices('Confirm', 'Pico Explode Death', [120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198], 24, false);
		add(picoDeathExplosion);
		picoDeathExplosion.visible = true;
		picoDeathExplosion.antialiasing = true;
		bf.visible = false;

		new FlxTimer().start(3.0, afterPicoDeathExplosionIntro);
		picoDeathExplosion.anim.play('intro');
		picoDeathExplosion.anim.curInstance.matrix.tx = 960.25 + 279.85;
		picoDeathExplosion.anim.curInstance.matrix.ty = 540.15 + 153.0;
	}

	function onExplosionFinishAnim(animLabel:String) {
		if (animLabel == 'intro') {
		picoDeathExplosion.anim.play('Loop Start', true);
		picoDeathExplosion.anim.curInstance.matrix.tx = 960.25 + 279.85;
		picoDeathExplosion.anim.curInstance.matrix.ty = 540.15 + 153.0;
		} else if (animLabel == 'Confirm') {
		}
		trace("Explosion animation finished: " + animLabel);
	}

	var singed:FlxSound;
	function afterPicoDeathExplosionIntro(timer:FlxTimer) {
		if (isEnding) return;
		FlxG.sound.playMusic(Paths.music('gameplay/gameover/gameOverStart-pico-explode', 'weekend1'));
		singed = new FlxSound().loadEmbedded(Paths.sound('singed_loop', 'weekend1'));
		singed.looped = true;
		FlxG.sound.list.add(singed);
	}

	function doExplosionConfirm() {
		picoDeathExplosion.anim.play('Confirm', true);
		picoDeathExplosion.anim.curInstance.matrix.tx = 960.25 + 279.85;
		picoDeathExplosion.anim.curInstance.matrix.ty = 540.15 + 153.0;
		if (singed != null) {
			singed.stop();
			singed = null;
		}
	}
}
