package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);


		animation.add('bf', [6, 7], 0, false, isPlayer);
		animation.add('dad', [8, 9], 0, false, isPlayer);
		animation.add('bf-old', [4, 5], 0, false, isPlayer);
		animation.add('darnell', [0, 1], 0, false, isPlayer);
		animation.add('pico-playable', [2, 3], 0, false, isPlayer);
		animation.add('darnell-blazin', [0, 1], 0, false, isPlayer);
		animation.add('pico-blazin', [2, 3], 0, false, isPlayer);
		animation.play(char);
		switch(char){
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				{

				}
			default:
				{
					antialiasing = true;
				}
		}
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
