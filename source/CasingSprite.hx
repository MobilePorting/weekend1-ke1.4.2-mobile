import flixel.FlxG;
import flixel.FlxSprite;

class CasingSprite extends FlxSprite
{
	public function new()
	{
		super(0, 0);

		frames = Paths.getSparrowAtlas('PicoBullet', 'weekend1');

		active = true;

		animation.addByPrefix('pop', "Pop0", 24, false);
		animation.addByPrefix('idle', "Bullet0", 24, true);
		animation.play('pop');
	}

	function onFrame(name:String, frameNumber:Int) {
		if (name == 'pop' && frameNumber == 40) {
			startRoll();
		}
	}

	function startRoll() {
		this.animation.callback = null;

		this.x = this.x + this.frame.offset.x - 1;
		this.y = this.y + this.frame.offset.y + 1;

		this.angle = 125.1; // Copied from FLA

		var randomFactorA = FlxG.random.float(3, 10);
		var randomFactorB = FlxG.random.float(1.0, 2.0);
		this.velocity.x = 20 * randomFactorB;
		this.drag.x = randomFactorA * randomFactorB;

		this.angularVelocity = 100;
		this.angularDrag = (this.drag.x / this.velocity.x) * 100;

		animation.play('idle');
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(this.animation.curAnim != null)
		onFrame(this.animation.curAnim.name, this.animation.curAnim.curFrame);
	}
}

