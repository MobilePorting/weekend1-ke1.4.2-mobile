import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flxanimate.FlxAnimate;
import flixel.FlxG;

class SpraycanAtlasSprite extends FlxAnimate
{
	public var STATE_ARCING:Int = 2; // In the air.
	public var STATE_SHOT:Int = 3; // Hit by the player.
	public var STATE_IMPACTED:Int = 4; // Impacted the player.

  public var currentState:Int = 2;

  public function new(x:Float, y:Float)
  {
    super(x, y);

    Paths.loadAnimateAtlas(this, 'spraycanAtlas');
    this.anim.addBySymbolIndices('Can Start', 'Can with Labels', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 24, false);
    this.anim.addBySymbolIndices('Hit Pico', 'Can with Labels', [19, 20, 21, 22, 23, 24, 25], false);
    this.anim.addBySymbolIndices('Can Shot', 'Can with Labels', [26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42], 24, false);
  }

  var name:String = '';

  public function finishCanAnimation() {
    switch(name) {
      case 'Can Start':
        playHitPico();
      case 'Can Shot':
        this.kill();
      case 'Hit Pico':
        playHitExplosion();
        this.kill();
    }
  }

  public function playHitExplosion():Void {
    var explodeEZ:FlxSprite = new FlxSprite(this.x + 1050, this.y + 150);
		explodeEZ.frames = Paths.getSparrowAtlas('spraypaintExplosionEZ', 'weekend1');
		explodeEZ.animation.addByPrefix("idle", "explosion round 1 short0", 24, false);
		explodeEZ.animation.play("idle");

		FlxG.state.add(explodeEZ);
		explodeEZ.antialiasing = true;
		explodeEZ.animation.finishCallback = function(name:String) {
		explodeEZ.kill();
		}
  }

  public function playCanStart():Void {
    this.anim.play('Can Start');
    name = 'Can Start';
  }

  public function playCanShot():Void {
    this.anim.play('Can Shot');
    name = 'Can Shot';
  }

  public function playHitPico():Void {
    this.anim.play('Hit Pico');
    name = 'Hit Pico';
  }

  public override function update(elapsed:Float)
  {
  super.update(elapsed);

  if(this.anim.finished)
  finishCanAnimation();

  this.anim.curInstance.matrix.tx = 960.25;
  this.anim.curInstance.matrix.ty = 540.1;
  }
}