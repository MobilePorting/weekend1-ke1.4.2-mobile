/*
 * Copyright (C) 2025 Mobile Porting Team
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package mobile;

// I wanted to delete this but i have no idea how i coded MobileControlSelectSubState so idk how to implement IMobileControls into it... yet...
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxDestroyUtil;
import mobile.Hitbox;
import mobile.TouchPad;
import mobile.input.MobileInputManager;

/**
 * ...
 * @author: Karim Akra
 */
class MobileControls extends FlxTypedSpriteGroup<MobileInputManager>
{
	public var touchPad:TouchPad = new TouchPad('NONE', 'NONE');
	public var hitbox:Hitbox = new Hitbox();

	public function new(?forceType:Int)
	{
		super();
		MobileData.forcedMode = forceType;
		switch (MobileData.mode)
		{
			case 0: // RIGHT_FULL
				initControler(0);
			case 1: // LEFT_FULL
				initControler(1);
			case 2: // CUSTOM
				initControler(2);
			case 3: // HITBOX
				initControler(3);
		}
		alpha = #if desktop 0 #else 0.6 #end;
	}

	private function initControler(controlMode:Int = 0):Void
	{
		switch (controlMode)
		{
			case 0:
				touchPad = new TouchPad('RIGHT_FULL', 'NONE');
				add(touchPad);
			case 1:
				touchPad = new TouchPad('LEFT_FULL', 'NONE');
				add(touchPad);
			case 2:
				touchPad = MobileData.getTouchPadCustom(new TouchPad('RIGHT_FULL', 'NONE'));
				add(touchPad);
			case 3:
				hitbox = new Hitbox();
				add(hitbox);
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		if (touchPad != null)
		{
			touchPad = FlxDestroyUtil.destroy(touchPad);
			touchPad = null;
		}

		if (hitbox != null)
		{
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}
		MobileData.forcedMode = null;
	}
}
