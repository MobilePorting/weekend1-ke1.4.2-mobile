package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;

class CharacterSetting
{
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var scale(default, null):Float;
	public var flipped(default, null):Bool;

	public function new(x:Int = 0, y:Int = 0, scale:Float = 1.0, flipped:Bool = false)
	{
		this.x = x;
		this.y = y;
		this.scale = scale;
		this.flipped = flipped;
	}
}

class MenuCharacter extends FlxSprite
{
	private static var settings:Map<String, CharacterSetting> = [
		'darnell' => new CharacterSetting(0, 0, 1.0, false),
		'pico-player' => new CharacterSetting(0, 0, 1.0, false),
		'nene' => new CharacterSetting(0, 0, 1.0, false)
	];

	private var flipped:Bool = false;

	public function new(x:Int, y:Int, scale:Float, flipped:Bool, character:String)
	{
		super(x, y);
		this.flipped = flipped;

		antialiasing = true;

		if(character == 'darnell')
		{
		frames = Paths.getSparrowAtlas('darnell', 'preload');
		animation.addByPrefix('idle', "idle0", 24);
		animation.play('idle');
		this.x = x + FlxG.width * 0.25 * 0;
		}

		if(character == 'pico-player')
		{
		frames = Paths.getSparrowAtlas('pico-player');
		animation.addByPrefix('idle', "idle0", 24);
		animation.addByPrefix('confirm', 'confirm0', 24, false);
		animation.play('idle');
		this.x = x + FlxG.width * 0.25 * 1;
		}

		if(character == 'nene')
		{
		frames = Paths.getSparrowAtlas('nene');
		animation.addByPrefix('idle', "idle0", 24);
		animation.play('idle');
		this.x = x + FlxG.width * 0.25 * 2;
		}

		this.scale.set(scale, scale);
	}

	public function setCharacter(character:String):Void
	{
		if (character == '')
		{
			visible = false;
			return;
		}
		else
		{
			visible = true;
		}

		var setting:CharacterSetting = settings[character];
		offset.set(setting.x, setting.y);
		flipX = setting.flipped != flipped;
	}
}
