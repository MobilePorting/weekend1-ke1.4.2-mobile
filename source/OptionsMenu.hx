package;

import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;
	var selector:FlxText;
	var curSelected:Int = 0;
	static var buttonShift:String = #if desktop "SHIFT" #else "C" #end;

	var options:Array<OptionCatagory> = [
		new OptionCatagory("Gameplay", [
			new DFJKOption(controls),
			new MobileControlsOption("Change Mobile Controls"),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			#if !web
			new FPSCapOption("Cap your FPS (Left for -10, Right for +10." + buttonShift + "to go faster)"),
			#end
			new ScrollSpeedOption("Change your scroll speed (Left for -0.1, right for +0.1. If its at 1, it will be chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			#if PRELOAD_ALL
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new CustomizeGameplay("Drag'n'Drop Gameplay Modules around to your preference")
			#end
		]),
		new OptionCatagory("Appearence", [
			new SongPositionOption("Show the songs current position (as a bar)"),
			new DownscrollOption("Change the layout of the strumline."),
			new MiddleScroll("Toggle the middlescroll"),
			new RainbowFPSOption("Make the FPS Counter Rainbow (Only works with the FPS Counter toggeled on)"),
			new AccuracyOption("Display accuracy information."),
			new NPSDisplayOption("Shows your current Notes Per Second.")
		]),
		
		new OptionCatagory("Misc", [
			new FPSOption("Toggle the FPS Counter"),
			#if sys
			new ReplayOption("View replays"),
			#end
			new WatermarkOption("Turn off all watermarks from the engine."),
			new DisableRainShader("Disables Rain Shader in Weekend1"),
			new DisableFFT("Disables FFT in Nene's Speaker"),
		])
		
	];

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCatagory;

	override function create()
	{
		instance = this;

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height - 18, 0, "Offset (Left, Right): " + FlxG.save.data.offset + " - Description - " + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		addTouchPad("LEFT_FULL", "A_B_C");

		super.create();
	}

	var isCat:Bool = false;
	
	public static function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

			if (controls.BACK && !isCat)
				FlxG.switchState(new MainMenuState());
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
					{
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
				curSelected = 0;
			}
			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (touchPad.buttonC.pressed || FlxG.keys.pressed.SHIFT)
						{
							if (touchPad.buttonRight.pressed || FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (touchPad.buttonLeft.pressed || FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
						if (touchPad.buttonRight.justPressed || FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (touchPad.buttonLeft.justPressed || FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{

					if (touchPad.buttonC.pressed || FlxG.keys.pressed.SHIFT)
					{
						if (touchPad.buttonRight.justPressed || FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (touchPad.buttonLeft.justPressed || FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (touchPad.buttonRight.pressed || FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (touchPad.buttonLeft.pressed || FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;
					
					versionShit.text = "Offset (Left, Right, " + buttonShift + " for slow): " + truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
				}
			}
			else
			{
				if (touchPad.buttonC.pressed || FlxG.keys.pressed.SHIFT)
					{
						if (touchPad.buttonRight.justPressed || FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (touchPad.buttonLeft.justPressed || FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (touchPad.buttonRight.pressed || FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (touchPad.buttonLeft.pressed || FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				
				versionShit.text = "Offset (Left, Right, " + buttonShift + " for slow): " + truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
		

			if (controls.RESET)
					FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						grpControls.remove(grpControls.members[curSelected]);
						var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
						ctrl.isMenuItem = true;
						grpControls.add(ctrl);
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
			}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a catagory";
		versionShit.text = "Offset (Left, Right, " + buttonShift + " for slow): " + truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
