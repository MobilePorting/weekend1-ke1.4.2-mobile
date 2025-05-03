package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.FlxCamera;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var canPlayOtherAnims:Bool = true;

	public var VULTURE_THRESHOLD = 0.25 * 2;

	public var currentState:Int = 0;

	public var MIN_BLINK_DELAY:Int = 3;
	public var MAX_BLINK_DELAY:Int = 7;
	public var blinkCountdown:Int = 3;

	public var animationFinished:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('DADDY_DEAREST','shared');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');

			case 'bf':
				var tex = Paths.getSparrowAtlas('BOYFRIEND','shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

			case 'darnell' | 'darnell-blazin':
				frames = Paths.getSparrowAtlas('darnell','weekend1');
				animation.addByPrefix('idle', 'Idle0', 24, false);
				animation.addByPrefix('singLEFT', 'Pose Left0', 24, false);
				animation.addByPrefix('singDOWN', 'Pose Down0', 24, false);
				animation.addByPrefix('singUP', 'Pose Up0', 24, false);
				animation.addByPrefix('singRIGHT', 'Pose Right0', 24, false);
				animation.addByPrefix('laugh', 'Laugh0', 24, false);
			animation.addByIndices('laughCutscene', 'Laugh0', [0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5], "", 24, false);
				animation.addByPrefix('lightCan', 'Light Can0', 24, false);
				animation.addByPrefix('kickCan', 'Kick Up0', 24, false);
				animation.addByPrefix('kneeCan', 'Knee Forward0', 24, false);
				animation.addByPrefix('pissed', 'Gets Pissed0', 24, false);

				addOffset('idle');
				addOffset("singLEFT", 1, 0);
				addOffset("singDOWN", 0, -3);
				addOffset("singUP", 8, 5);
				addOffset("singRIGHT", 4, 3);
				addOffset("laugh", 0, 0);
				addOffset("laughCutscene", 0, 0);
				addOffset("lightCan", 8, 1);
				addOffset("kickCan", 15, 9);
				addOffset("kneeCan", 7, -1);
				addOffset("pissed", 0, 0);

				playAnim('idle');

			case 'pico-playable' | 'pico-blazin':
				var assetList = ['Pico_Playable', 'Pico_Shooting', 'Pico_Death', 'Pico_Intro'];

				var texture:FlxAtlasFrames = Paths.getSparrowAtlas('Pico_Basic', 'weekend1');

				if (texture == null)
				{
				trace('Multi-Sparrow atlas could not load PRIMARY texture: Pico_Basic');
				}
				else
				{
				trace('Creating multi-sparrow atlas: Pico_Basic');
				texture.parent.destroyOnNoUse = false;
				}

				for (asset in assetList)
				{
				var subTexture:FlxAtlasFrames = Paths.getSparrowAtlas(asset, 'weekend1');
				// If we don't do this, the unused textures will be removed as soon as they're loaded.

				if (subTexture == null)
				{
				trace('Multi-Sparrow atlas could not load subtexture: ${asset}');
				}
				else
				{
				trace('Concatenating multi-sparrow atlas: ${asset}');
				subTexture.parent.destroyOnNoUse = false;
				}

				texture.addAtlas(subTexture);
				}

				frames = texture;

				animation.addByPrefix('idle', 'Pico Idle Dance', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico Left Note MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24, false);
				animation.addByPrefix('singUPmiss', 'Pico Up Note MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Pico Right Note MISS', 24, false);
				animation.addByPrefix('shootMISS', 'Pico Hit Can0', 24, false);
animation.addByIndices('firstDeath', 'Pico Death Stab', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47], "", 24, false);
				animation.addByPrefix('firstDeathExplosion', 'Pico Idle Dance', 24, false);
				animation.addByIndices('deathLoop', 'Pico Death Stab', [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63], "", 24, true);
				animation.addByPrefix('cock', 'Pico Reload0', 24, false);
				animation.addByPrefix('shoot', 'Pico Shoot Hip Full0', 24, false);
				animation.addByPrefix('intro1', 'Pico Gets Pissed0', 24, false);
				animation.addByPrefix('cockCutscene', 'cutscene cock0', 24, false);
				animation.addByPrefix('intro2', 'shoot and return0', 24, false);

				addOffset('idle');
				addOffset("singRIGHT", -50, 1);
				addOffset("singDOWN", 84, -77);
				addOffset("singUP", 21, 28);
				addOffset("singLEFT", 84, -11);
				addOffset("singLEFTmiss", 68, 20);
				addOffset("singDOWNmiss", 80, -40);
				addOffset("singUPmiss", 29, 70);
				addOffset("singRIGHTmiss", -55, 45);
				addOffset("shootMISS", 0, 0);
				addOffset("firstDeath", 225, 125);
				addOffset("firstDeathExplosion", 225, 125);
				addOffset("deathLoop", 225, 125);
				addOffset("cock", 0, 0);
				addOffset("shoot", 300, 250);
				addOffset("intro1", 60, 0);
				addOffset("cockCutscene", 0, 0);
				addOffset("intro2", 260, 230);

				playAnim('idle');

				flipX = true;

			case 'nene':
				frames = Paths.getSparrowAtlas('Nene','weekend1');
				animation.addByPrefix('idle', 'Idle0', 24, false);
				animation.addByIndices('danceLeft', 'Idle0', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'Idle0', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByPrefix('combo50', 'ComboCheer0', 24, false);
animation.addByIndices('drop70', 'Laugh0', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11], "", 24, false);
animation.addByIndices('laughCutscene', 'Laugh0', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByIndices('combo200', 'ComboFawn0', [0, 1, 2, 3, 4, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6], "", 24, false);
				animation.addByPrefix('raiseKnife', 'KnifeRaise0', 24, false);
				animation.addByPrefix('idleKnife', 'KnifeIdle0', 24, false);
				animation.addByPrefix('lowerKnife', 'KnifeLower0', 24, false);

				addOffset('danceLeft');
				addOffset('danceRight');
				addOffset('combo50', -120, 50);
				addOffset('drop70');
				addOffset('laughCutscene');
				addOffset('combo200', -50, -25);
				addOffset('raiseKnife', 0, 52);
				addOffset('idleKnife', -99, 52);
				addOffset('lowerKnife', 135, 52);

				playAnim('danceRight');
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf') && curCharacter != 'pico-playable' && curCharacter != 'pico-blazin')
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		if (animation.curAnim.finished)
		{
		if (!canPlayOtherAnims && !debugMode)
		{
		canPlayOtherAnims = true;
		}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'nene':
					// Then, perform the appropriate animation for the current state.
					switch(currentState) {
					case 0:
						if (danced) {
						playAnim('danceRight');
						} else {
						playAnim('danceLeft');
						}
						danced = !danced;
					case 1:
						playAnim('danceLeft', false);
						danced = false;
					case 3:
						if (blinkCountdown == 0) {
						playAnim('idleKnife', false);
						blinkCountdown = FlxG.random.int(MIN_BLINK_DELAY, MAX_BLINK_DELAY);
						} else {
						blinkCountdown--;
						}
					case 4:
						if(animation.curAnim.name != 'lowerKnife'){
						playAnim('lowerKnife');
						}
					default:
						// In other states, don't interrupt the existing animation.
					}
				default:
					playAnim('idle');
			}
		}
	}

  var animOffsets2(default, set):Array<Float> = [0, 0];

  function set_animOffsets2(value:Array<Float>):Array<Float>
  {
    if (animOffsets2 == null) animOffsets2 = [0, 0];
    if ((animOffsets2[0] == value[0]) && (animOffsets2[1] == value[1])) return value;

    return animOffsets2 = value;
  }

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (!canPlayOtherAnims) return;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			animOffsets2 = [daOffset[0],daOffset[1]];
		}
		else
			animOffsets2 = [0,0];
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

  public var characterOrigin(get, never):FlxPoint;

  function get_characterOrigin():FlxPoint
  {
    var xPos = (width / 2); // Horizontal center
    var yPos = (height); // Vertical bottom
    return new FlxPoint(xPos, yPos);
  }

  public var globalOffsets(default, set):Array<Float> = [0, 0];

  function set_globalOffsets(value:Array<Float>):Array<Float>
  {
    if (globalOffsets == null) globalOffsets = [0, 0];
    if (globalOffsets == value) return value;

    return globalOffsets = value;
  }

  // override getScreenPosition (used by FlxSprite's draw method) to account for animation offsets.
  override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
  {
    var output:FlxPoint = super.getScreenPosition(result, camera);
    output.x -= (animOffsets2[0] - globalOffsets[0]) * this.scale.x;
    output.y -= (animOffsets2[1] - globalOffsets[1]) * this.scale.y;
    return output;
  }
}
