package;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
#if linc_luajit
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
#end
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxTiledSprite;
import flxanimate.FlxAnimate;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;

#if desktop
import Discord.DiscordClient;
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;
	
	#if desktop
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxSpriteGroup;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camCutscene:FlxCamera;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	var songName:FlxText;

	var fc:Bool = true;

	var scrollingSky:FlxTiledSprite;

	var phillyCars:FlxSprite;
	var phillyCars2:FlxSprite;

	var phillyTraffic:FlxSprite;

	var lightsStop:Bool = false;
	var lastChange:Int = 0;
	var changeInterval:Int = 8;

	var carWaiting:Bool = false;
	var carInterruptable:Bool = true;
	var car2Interruptable:Bool = true;

	var abot:ABotSpeaker;
	var abotLookDir:Bool = false;

	var rainShader:RainShader;
	var rainShaderStartIntensity:Float = 0;
	var rainShaderEndIntensity:Float = 0;

	var spraycanPile:FlxSprite;

	var bgSprite:FlxSprite;

	var darnellBlazin:FlxAnimate;
	var picoBlazin:FlxAnimate;

	var skyAdditive:FlxSprite;
	var lightning:FlxSprite;
	var foregroundMultiply:FlxSprite;
	var additionalLighten:FlxSprite;

	var groupBlazin = new FlxTypedGroup<FlxAnimate>();

	var gunCocked:Bool = false;
	var spawnedCans:Array<SpraycanAtlasSprite> = [];

	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	private var triggeredAlready:Bool = false;
	
	private var allowedToHeadbang:Bool = false;
	public static var songOffset:Float = 0;

	#if linc_luajit
	private var executeModchart = false;

	public static var lua:State = null;

	function callLua(func_name : String, args : Array<Dynamic>, ?type : String) : Dynamic
	{
		var result : Any = null;

		Lua.getglobal(lua, func_name);

		for( arg in args ) {
		Convert.toLua(lua, arg);
		}

		result = Lua.pcall(lua, args.length, 1, 0);

		if (getLuaErrorMessage(lua) != null)
			trace(func_name + ' LUA CALL ERROR ' + Lua.tostring(lua,result));

		if( result == null) {
			return null;
		} else {
			return convert(result, type);
		}

	}

	function getType(l, type):Any
	{
		return switch Lua.type(l,type) {
			case t if (t == Lua.LUA_TNIL): null;
			case t if (t == Lua.LUA_TNUMBER): Lua.tonumber(l, type);
			case t if (t == Lua.LUA_TSTRING): (Lua.tostring(l, type):String);
			case t if (t == Lua.LUA_TBOOLEAN): Lua.toboolean(l, type);
			case t: throw 'you don goofed up. lua type error ($t)';
		}
	}

	function getReturnValues(l) {
		var lua_v:Int;
		var v:Any = null;
		while((lua_v = Lua.gettop(l)) != 0) {
			var type:String = getType(l,lua_v);
			v = convert(lua_v, type);
			Lua.pop(l, 1);
		}
		return v;
	}

	private function convert(v : Any, type : String) : Dynamic {
		if( Std.is(v, String) && type != null ) {
		var v : String = v;
		if( type.substr(0, 4) == 'array' ) {
			if( type.substr(4) == 'float' ) {
			var array : Array<String> = v.split(',');
			var array2 : Array<Float> = new Array();

			for( vars in array ) {
				array2.push(Std.parseFloat(vars));
			}

			return array2;
			} else if( type.substr(4) == 'int' ) {
			var array : Array<String> = v.split(',');
			var array2 : Array<Int> = new Array();

			for( vars in array ) {
				array2.push(Std.parseInt(vars));
			}

			return array2;
			} else {
			var array : Array<String> = v.split(',');
			return array;
			}
		} else if( type == 'float' ) {
			return Std.parseFloat(v);
		} else if( type == 'int' ) {
			return Std.parseInt(v);
		} else if( type == 'bool' ) {
			if( v == 'true' ) {
			return true;
			} else {
			return false;
			}
		} else {
			return v;
		}
		} else {
		return v;
		}
	}

	function getLuaErrorMessage(l) {
		var v:String = Lua.tostring(l, -1);
		Lua.pop(l, 1);
		return v;
	}

	public function setVar(var_name : String, object : Dynamic){
		Lua.pushnumber(lua,object);
		Lua.setglobal(lua, var_name);
	}

	public function getVar(var_name : String, type : String) : Dynamic {
		var result : Any = null;

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua,-1);
		Lua.pop(lua,1);

		if( result == null ) {
		return null;
		} else {
		var result = convert(result, type);
		return result;
		}
	}

	function getActorByName(id:String):Dynamic
	{
		switch(id)
		{
			case 'boyfriend':
				return boyfriend;
			case 'girlfriend':
				return gf;
			case 'dad':
				return dad;
		}
		if (luaSprites.get(id) == null)
			return strumLineNotes.members[Std.parseInt(id)];
		return luaSprites.get(id);
	}

	public static var luaSprites:Map<String,FlxSprite> = [];



	function makeLuaSprite(spritePath:String,toBeCalled:String, drawBehind:Bool)
	{
		#if sys
		var data:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/data/" + PlayState.SONG.song.toLowerCase() + '/' + spritePath + ".png");

		var sprite:FlxSprite = new FlxSprite(0,0);
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		if (scale > 1)
		{
			scale = 1;
		}

		sprite.makeGraphic(Std.int(data.width * scale),Std.int(data.width * scale),FlxColor.TRANSPARENT);

		var data2:BitmapData = sprite.pixels.clone();
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		data2.draw(data, matrix, null, null, null, true);
		sprite.pixels = data2;
		
		luaSprites.set(toBeCalled,sprite);
		if (drawBehind)
		{
			remove(gf);
			remove(boyfriend);
			remove(dad);
		}
		add(sprite);
		if (drawBehind)
		{
			add(gf);
			add(boyfriend);
			add(dad);
		}
		#end
		return toBeCalled;
	}
	#end

	override public function create()
	{
		Paths.clearStoredMemory();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		repPresses = 0;
		repReleases = 0;

		#if linc_luajit
		executeModchart = FileSystem.exists(Paths.lua(PlayState.SONG.song.toLowerCase()  + "/modchart"));
		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));
		#end

		#if desktop
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		detailsPausedText = "Paused - " + detailsText;

		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camCutscene = new FlxCamera();
		camCutscene.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camCutscene);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale);

		switch(SONG.song.toLowerCase())
		{
			case 'darnell' | 'lit-up' | '2hot':
			{
					curStage = 'phillyStreets';
					defaultCamZoom = 0.77;

		scrollingSky = new FlxTiledSprite(Paths.image('phillyStreets/phillySkybox', 'weekend1'), 2922, 718, true, false);
		scrollingSky.setPosition(-650, -375);
		scrollingSky.scrollFactor.set(0.1, 0.1);
		scrollingSky.scale.set(0.65, 0.65);

		add(scrollingSky);

		var phillySkyline = new FlxSprite(-545, -273).loadGraphic(Paths.image("phillyStreets/phillySkyline", 'weekend1'));
		phillySkyline.scrollFactor.set(0.2, 0.2);
		phillySkyline.antialiasing = true;
		add(phillySkyline);

		var phillyForegroundCity = new FlxSprite(625, 94).loadGraphic(Paths.image("phillyStreets/phillyForegroundCity", 'weekend1'));
		phillyForegroundCity.scrollFactor.set(0.3, 0.3);
		phillyForegroundCity.antialiasing = true;
		add(phillyForegroundCity);

		var phillyConstruction = new FlxSprite(1800, 364).loadGraphic(Paths.image("phillyStreets/phillyConstruction", 'weekend1'));
		phillyConstruction.scrollFactor.set(0.7, 1);
		phillyConstruction.antialiasing = true;
		add(phillyConstruction);

		var phillyHighwayLights = new FlxSprite(284, 305).loadGraphic(Paths.image("phillyStreets/phillyHighwayLights", 'weekend1'));
		phillyHighwayLights.scrollFactor.set(1, 1);
		phillyHighwayLights.antialiasing = true;
		add(phillyHighwayLights);

		var phillyHighwayLights_lightmap = new FlxSprite(284, 305).loadGraphic(Paths.image("phillyStreets/phillyHighwayLights_lightmap", 'weekend1'));
		phillyHighwayLights_lightmap.scrollFactor.set(1, 1);
		phillyHighwayLights_lightmap.antialiasing = true;
		phillyHighwayLights_lightmap.blend = ADD;
		phillyHighwayLights_lightmap.alpha = 0.6;
		add(phillyHighwayLights_lightmap);

		var phillyHighway = new FlxSprite(139, 209).loadGraphic(Paths.image("phillyStreets/phillyHighway", 'weekend1'));
		phillyHighway.scrollFactor.set(1, 1);
		phillyHighway.antialiasing = true;
		add(phillyHighway);

		var phillySmog = new FlxSprite(-6, 245).loadGraphic(Paths.image("phillyStreets/phillySmog", 'weekend1'));
		phillySmog.scrollFactor.set(0.8, 1);
		phillySmog.antialiasing = true;
		add(phillySmog);

		phillyCars = new FlxSprite(1748, 818);
		phillyCars.frames = Paths.getSparrowAtlas("phillyStreets/phillyCars", 'weekend1');
		phillyCars.scrollFactor.set(0.9, 1);
		phillyCars.antialiasing = true;
		phillyCars.animation.addByPrefix("car1", "car1", 0, false);
		phillyCars.animation.addByPrefix("car2", "car2", 0, false);
		phillyCars.animation.addByPrefix("car3", "car3", 0, false);
		phillyCars.animation.addByPrefix("car4", "car4", 0, false);
		add(phillyCars);

		phillyCars2 = new FlxSprite(1748, 818);
		phillyCars2.frames = Paths.getSparrowAtlas("phillyStreets/phillyCars", 'weekend1');
		phillyCars2.scrollFactor.set(0.9, 1);
		phillyCars2.antialiasing = true;
		phillyCars2.flipX = true;
		phillyCars2.animation.addByPrefix("car1", "car1", 0, false);
		phillyCars2.animation.addByPrefix("car2", "car2", 0, false);
		phillyCars2.animation.addByPrefix("car3", "car3", 0, false);
		phillyCars2.animation.addByPrefix("car4", "car4", 0, false);
		add(phillyCars2);

		phillyTraffic = new FlxSprite(1840, 608);
		phillyTraffic.frames = Paths.getSparrowAtlas("phillyStreets/phillyTraffic", 'weekend1');
		phillyTraffic.scrollFactor.set(0.9, 1);
		phillyTraffic.antialiasing = true;
		phillyTraffic.animation.addByPrefix("togreen", "redtogreen", 24, false);
		phillyTraffic.animation.addByPrefix("tored", "greentored", 24, false);
		add(phillyTraffic);

		var phillyHighwayLights_lightmap = new FlxSprite(1840, 608).loadGraphic(Paths.image("phillyStreets/phillyTraffic_lightmap", 'weekend1'));
		phillyHighwayLights_lightmap.scrollFactor.set(0.9, 1);
		phillyHighwayLights_lightmap.antialiasing = true;
		phillyHighwayLights_lightmap.blend = ADD;
		phillyHighwayLights_lightmap.alpha = 0.6;
		add(phillyHighwayLights_lightmap);

		var phillyForeground = new FlxSprite(88, 317).loadGraphic(Paths.image("phillyStreets/phillyForeground", 'weekend1'));
		phillyForeground.antialiasing = true;
		add(phillyForeground);

		resetCar(true, true);

			setupRainShader();
			}
			case 'blazin':
			{
					curStage = 'phillyBlazin';
					defaultCamZoom = 0.75;

		scrollingSky = new FlxTiledSprite(Paths.image('phillyBlazin/skyBlur', 'weekend1'), 2000, 359, true, false);
		scrollingSky.setPosition(-500, -120);
		scrollingSky.scrollFactor.set(0, 0);

		add(scrollingSky);

		skyAdditive = new FlxSprite(-600, -175).loadGraphic(Paths.image("phillyBlazin/skyBlur", 'weekend1'));
		skyAdditive.scrollFactor.set(0, 0);
		skyAdditive.scale.set(1.75, 1.75);
		add(skyAdditive);
		skyAdditive.blend = ADD;
		skyAdditive.visible = false;

		lightning = new FlxSprite(50, -300);
		lightning.frames = Paths.getSparrowAtlas("phillyBlazin/lightning", 'weekend1');
		lightning.animation.addByPrefix('strike', "lightning", 24, false);
		lightning.scrollFactor.set(0, 0);
		lightning.scale.set(1.75, 1.75);
		lightning.updateHitbox();
		add(lightning);
		lightning.visible = false;

		var phillyForegroundCity = new FlxSprite(-600, -175).loadGraphic(Paths.image("phillyBlazin/streetBlur", 'weekend1'));
		phillyForegroundCity.scrollFactor.set(0, 0);
		phillyForegroundCity.scale.set(1.75, 1.75);
		phillyForegroundCity.updateHitbox();
		add(phillyForegroundCity);

		foregroundMultiply = new FlxSprite(-600, -175).loadGraphic(Paths.image("phillyBlazin/streetBlur", 'weekend1'));
		foregroundMultiply.scrollFactor.set(0, 0);
		foregroundMultiply.scale.set(1.75, 1.75);
		foregroundMultiply.updateHitbox();
		add(foregroundMultiply);
		foregroundMultiply.blend = MULTIPLY;
		foregroundMultiply.visible = false;

		additionalLighten = new FlxSprite(-600, -175).makeGraphic(1, 1, 0xFFFFFFFF);
		additionalLighten.scrollFactor.set(0, 0);
		additionalLighten.scale.set(2500, 2500);
		additionalLighten.updateHitbox();
		add(additionalLighten);
		additionalLighten.blend = ADD;
		additionalLighten.visible = false;

			setupRainShader();
			}
			default:
			{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
			}
		}
		var gfVersion:String = 'nene';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(1, 1);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
		
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		boyfriend.updateHitbox();
		dad.updateHitbox();
		gf.updateHitbox();

		switch (curStage)
		{
			case 'phillyStreets':
				boyfriend.x = 2151 - boyfriend.characterOrigin.x + boyfriend.globalOffsets[0];
				boyfriend.y = 1228 - boyfriend.characterOrigin.y + boyfriend.globalOffsets[1];
				dad.x = 786 - dad.characterOrigin.x + dad.globalOffsets[0];
				dad.y = 1141 - dad.characterOrigin.y + dad.globalOffsets[1];
				gf.globalOffsets[1] = -100;
				gf.x = 1453 - gf.characterOrigin.x + gf.globalOffsets[0];
				gf.y = 1100 - gf.characterOrigin.y + gf.globalOffsets[1];
				var dadCenterX = dad.x + 135 + dad.width / 2;
				var dadCenterY = dad.y + 45 + dad.height / 2;
				camPos.set(dadCenterX + 500, dadCenterY + -100);
			case 'phillyBlazin':
				boyfriend.x = -237 - boyfriend.characterOrigin.x;
				boyfriend.y = 100 - boyfriend.characterOrigin.y;
				dad.x = -237 - dad.characterOrigin.x;
				dad.y = 150 - dad.characterOrigin.y;
				gf.globalOffsets[1] = -100;
				gf.x = 1353 - gf.characterOrigin.x + gf.globalOffsets[0];
				gf.y = 1125 - gf.characterOrigin.y + gf.globalOffsets[1];
				camPos.set(1403, 717);
		}

		switch (curStage)
		{
			case 'phillyStreets':
				abot = new ABotSpeaker(gf.x, gf.y);
				abot.lookRight();
				abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
				add(abot);
			case 'phillyBlazin':
				abot = new ABotSpeaker(gf.x, gf.y);
				abot.lookRight();
				abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
				add(abot);

			boyfriend.color = 0xFFDEDEDE;
			dad.color = 0xFFDEDEDE;
			gf.color = 0xFF888888;
			abot.speaker.color = 0xFF888888;
		}

		add(gf);

		add(dad);
		add(boyfriend);

if(curStage == 'phillyBlazin')
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
picoBlazin.anim.play('idle', true);
picoBlazin.anim.curInstance.matrix.tx = 858;
picoBlazin.anim.curInstance.matrix.ty = 770;
groupBlazin.add(picoBlazin);
picoBlazin.antialiasing = true;
picoBlazin.scale.set(1.75, 1.75);
picoBlazin.updateHitbox();
picoBlazin.x = -424.822087053792;
picoBlazin.y = -370.611902062036;
picoBlazin.offset.x = -187.822087053792;
picoBlazin.offset.y = -235.305951031018;
picoBlazin.origin.x = 0;
picoBlazin.origin.y = 0;
picoBlazin.color = 0xFFDEDEDE;

boyfriend.visible = false;

		var picoDeathConfirm:FlxSprite = new FlxSprite();
		picoDeathConfirm.frames = Paths.getSparrowAtlas('picoBlazinDeathConfirm', 'weekend1');
		picoDeathConfirm.animation.addByPrefix('confirm', "Pico Gut Punch Death0", 24, false);
		picoDeathConfirm.animation.play('confirm');
		picoDeathConfirm.scale.set(1.75, 1.75);
		picoDeathConfirm.antialiasing = true;
		picoDeathConfirm.screenCenter();
		picoDeathConfirm.scrollFactor.set(0, 0);
		add(picoDeathConfirm);
		picoDeathConfirm.alpha = 0.00000001;
}

if(curStage == 'phillyBlazin')
{
darnellBlazin = new FlxAnimate(0, 0);
Paths.loadAnimateAtlas(darnellBlazin, 'darnellBlazin');
darnellBlazin.anim.addBySymbolIndices('idle', 'Darnell Fighting ALL ANIMS', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], 24, true);
darnellBlazin.anim.addBySymbolIndices('pissed', 'Darnell Fighting ALL ANIMS', [74, 75, 76, 77, 78], 24, false);
darnellBlazin.anim.addBySymbolIndices('cringe', 'Darnell Fighting ALL ANIMS', [67, 68, 69, 70], 24, false);
darnellBlazin.anim.addBySymbolIndices('fakeout', 'Darnell Fighting ALL ANIMS', [24, 25, 26, 27, 28], 24, false);
darnellBlazin.anim.addBySymbolIndices('block', 'Darnell Fighting ALL ANIMS', [29, 30, 31, 32], 24, false);
darnellBlazin.anim.addBySymbolIndices('dodge', 'Darnell Fighting ALL ANIMS', [53, 54, 55, 56, 57], 24, false);
darnellBlazin.anim.addBySymbolIndices('uppercutPrep', 'Darnell Fighting ALL ANIMS', [14, 15, 16, 17, 18], 24, false);
darnellBlazin.anim.addBySymbolIndices('uppercut', 'Darnell Fighting ALL ANIMS', [19, 20, 21, 22, 23], 24, false);
darnellBlazin.anim.addBySymbolIndices('uppercutHit', 'Darnell Fighting ALL ANIMS', [79, 80, 81, 82, 83, 84, 85, 86, 87, 88], 24, false);
darnellBlazin.anim.addBySymbolIndices('uppercut-hold', 'Darnell Fighting ALL ANIMS', [21, 22, 23], 24, true);
darnellBlazin.anim.addBySymbolIndices('punchHigh1', 'Darnell Fighting ALL ANIMS', [33, 34, 35, 36, 37], 24, false);
darnellBlazin.anim.addBySymbolIndices('punchHigh2', 'Darnell Fighting ALL ANIMS', [38, 39, 40, 41, 42], 24, false);
darnellBlazin.anim.addBySymbolIndices('punchLow1', 'Darnell Fighting ALL ANIMS', [48, 49, 50, 51, 52], 24, false);
darnellBlazin.anim.addBySymbolIndices('punchLow2', 'Darnell Fighting ALL ANIMS', [43, 44, 45, 46, 47], 24, false);
darnellBlazin.anim.addBySymbolIndices('hitHigh', 'Darnell Fighting ALL ANIMS', [58, 59, 60, 61, 62], 24, false);
darnellBlazin.anim.addBySymbolIndices('hitLow', 'Darnell Fighting ALL ANIMS', [63, 64, 65, 66], 24, false);
darnellBlazin.anim.addBySymbolIndices('hitSpin', 'Darnell Fighting ALL ANIMS', [71, 72, 73], 24, true);
darnellBlazin.anim.play('idle', true);
darnellBlazin.anim.curInstance.matrix.tx = 907.95;
darnellBlazin.anim.curInstance.matrix.ty = 742;
groupBlazin.add(darnellBlazin);
darnellBlazin.antialiasing = true;
darnellBlazin.scale.set(1.75, 1.75);
darnellBlazin.updateHitbox();
darnellBlazin.x = -432.431985473633;
darnellBlazin.y = -337.836295987852;
darnellBlazin.offset.x = -195.431985473633;
darnellBlazin.offset.y = -243.918147993926;
darnellBlazin.origin.x = 0;
darnellBlazin.origin.y = 0;
darnellBlazin.color = 0xFFDEDEDE;

dad.visible = false;

add(groupBlazin);
}

		if (curStage == 'phillyStreets')
		{
		spraycanPile = new FlxSprite(920, 1045).loadGraphic(Paths.image("SpraycanPile", 'weekend1'));
		spraycanPile.antialiasing = true;
		add(spraycanPile);

				var newCan:SpraycanAtlasSprite = new SpraycanAtlasSprite(0, 0);

				newCan.x = spraycanPile.x - 430;
				newCan.y = spraycanPile.y - 840;

				insert(members.indexOf(spraycanPile), newCan);
				remove(spraycanPile);
				insert(members.indexOf(newCan), spraycanPile);
				newCan.alpha = 0.00000001;

		if (curSong.toLowerCase() == '2hot')
		{
		var casing:CasingSprite = new CasingSprite();
		casing.x = boyfriend.x + 250;
		casing.y = boyfriend.y + 100;
		add(casing);
		casing.alpha = 0.00000001;

		var picoDeathExplosion:FlxAnimate = new FlxAnimate();
		Paths.loadAnimateAtlas(picoDeathExplosion, "picoExplosionDeath");
		picoDeathExplosion.screenCenter();
		picoDeathExplosion.scrollFactor.set(0, 0);
		add(picoDeathExplosion);
		picoDeathExplosion.antialiasing = true;
		picoDeathExplosion.alpha = 0.00000001;
		}
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxSpriteGroup();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			if (curSong.toLowerCase() != 'blazin')
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition)
			{
				songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
				if (FlxG.save.data.downscroll)
					songPosBG.y = FlxG.height * 0.9 + 45; 
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();
				add(songPosBG);
				
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
				add(songPosBar);
	
				var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
				if (FlxG.save.data.downscroll)
					songName.y -= 3;
				songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				add(songName);
				songName.cameras = [camHUD];
			}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50,0,SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") + (Main.watermarks ? " - KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (FlxG.save.data.downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		if (offsetTesting)
			scoreTxt.x += 300;
		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
			{
				add(replayTxt);
			}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		startingSong = true;

		addMobileControls();
		mobileControls.instance.visible = true;
		
		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "darnell":
					trace('Pausing countdown to play a video cutscene (`darnell`)');
					FlxG.camera.zoom  = 1.3;
					bgSprite = new FlxSprite(0, 0).makeGraphic(2000, 2500, 0xFF000000);
					bgSprite.cameras = [camCutscene];
					add(bgSprite);

					startVideo();
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		if (!loadRep)
			rep = new Replay("na");

		#if !android
		addTouchPad("NONE", "P");
 		addTouchPadCamera();
		#end

		super.create();

		Paths.clearUnusedMemory();
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		if (curSong.toLowerCase() == 'blazin')
		camGame.fade(0xFF000000, 1.5, true, null, true);

		#if linc_luajit
		if (executeModchart)
			{
				trace('opening a lua state (because we are cool :))');
				lua = LuaL.newstate();
				LuaL.openlibs(lua);
				trace("Lua version: " + Lua.version());
				trace("LuaJIT version: " + Lua.versionJIT());
				Lua.init_callbacks(lua);
				
				var result = LuaL.dofile(lua, Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));
	
				if (result != 0)
					trace('COMPILE ERROR\n' + getLuaErrorMessage(lua));
	
				setVar("bpm", Conductor.bpm);
				setVar("fpsCap", FlxG.save.data.fpsCap);
				setVar("downscroll", FlxG.save.data.downscroll);
	
				setVar("curStep", 0);
				setVar("curBeat", 0);
	
				setVar("hudZoom", camHUD.zoom);
				setVar("cameraZoom", FlxG.camera.zoom);
	
				setVar("cameraAngle", FlxG.camera.angle);
				setVar("camHudAngle", camHUD.angle);
	
				setVar("followXOffset",0);
				setVar("followYOffset",0);
	
				setVar("showOnlyStrums", false);
				setVar("strumLine1Visible", true);
				setVar("strumLine2Visible", true);
	
				setVar("screenWidth",FlxG.width);
				setVar("screenHeight",FlxG.height);
				setVar("hudWidth", camHUD.width);
				setVar("hudHeight", camHUD.height);
	
				trace(Lua_helper.add_callback(lua,"makeSprite", makeLuaSprite));
	
				Lua_helper.add_callback(lua,"destroySprite", function(id:String) {
					var sprite = luaSprites.get(id);
					if (sprite == null)
						return false;
					remove(sprite);
					return true;
				});
	
				trace(Lua_helper.add_callback(lua,"setHudPosition", function (x:Int, y:Int) {
					camHUD.x = x;
					camHUD.y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getHudX", function () {
					return camHUD.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getHudY", function () {
					return camHUD.y;
				}));
				
				trace(Lua_helper.add_callback(lua,"setCamPosition", function (x:Int, y:Int) {
					FlxG.camera.x = x;
					FlxG.camera.y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getCameraX", function () {
					return FlxG.camera.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getCameraY", function () {
					return FlxG.camera.y;
				}));
	
				trace(Lua_helper.add_callback(lua,"setCamZoom", function(zoomAmount:Int) {
					FlxG.camera.zoom = zoomAmount;
				}));
	
				trace(Lua_helper.add_callback(lua,"setHudZoom", function(zoomAmount:Int) {
					camHUD.zoom = zoomAmount;
				}));
				
				trace(Lua_helper.add_callback(lua,"getRenderedNotes", function() {
					return notes.length;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteX", function(id:Int) {
					return notes.members[id].x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteY", function(id:Int) {
					return notes.members[id].y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteScaleX", function(id:Int) {
					return notes.members[id].scale.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteScaleY", function(id:Int) {
					return notes.members[id].scale.y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteAlpha", function(id:Int) {
					return notes.members[id].alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNotePos", function(x:Int,y:Int, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].x = x;
					notes.members[id].y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteAlpha", function(alpha:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].alpha = alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].setGraphicSize(Std.int(notes.members[id].width * scale));
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScaleX", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].scale.x = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScaleY", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].scale.y = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorX", function(x:Int,id:String) {
					getActorByName(id).x = x;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorAlpha", function(alpha:Int,id:String) {
					getActorByName(id).alpha = alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorY", function(y:Int,id:String) {
					getActorByName(id).y = y;
				}));
							
				trace(Lua_helper.add_callback(lua,"setActorAngle", function(angle:Int,id:String) {
					getActorByName(id).angle = angle;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScale", function(scale:Float,id:String) {
					getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScaleX", function(scale:Float,id:String) {
					getActorByName(id).scale.x = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScaleY", function(scale:Float,id:String) {
					getActorByName(id).scale.y = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorWidth", function (id:String) {
					return getActorByName(id).width;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorHeight", function (id:String) {
					return getActorByName(id).height;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorAlpha", function(id:String) {
					return getActorByName(id).alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorAngle", function(id:String) {
					return getActorByName(id).angle;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorX", function (id:String) {
					return getActorByName(id).x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorY", function (id:String) {
					return getActorByName(id).y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorScaleX", function (id:String) {
					return getActorByName(id).scale.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorScaleY", function (id:String) {
					return getActorByName(id).scale.y;
				}));
				
				Lua_helper.add_callback(lua,"tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenFadeIn", function(id:String, toAlpha:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenFadeOut", function(id:String, toAlpha:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				for (i in 0...strumLineNotes.length) {
					var member = strumLineNotes.members[i];
					trace(strumLineNotes.members[i].x + " " + strumLineNotes.members[i].y + " " + strumLineNotes.members[i].angle + " | strum" + i);
					setVar("defaultStrum" + i + "X", Math.floor(member.x));
					setVar("defaultStrum" + i + "Y", Math.floor(member.y));
					setVar("defaultStrum" + i + "Angle", Math.floor(member.angle));
					trace("Adding strum" + i);
				}
	
				trace('calling start function');
	
				trace('return: ' + Lua.tostring(lua,callLua('start', [PlayState.SONG.song])));
			}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			if (abot != null)
			{
			abot.speaker.anim.play('anim', true);
			abot.speaker.anim.curFrame = 1;
			}
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
		
		allowedToHeadbang = false;
		
		#if desktop
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end

		if(abot != null)
		abot.snd = FlxG.sound.music;
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		var playerCounter:Int = 0;

		#if desktop
			var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';
			for(file in Paths.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if(!sys.FileSystem.isDirectory(path))
				{
					if(path.endsWith('.offset'))
					{
						trace('Found offset file: ' + path);
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}else {
						trace('Offset file not found. Creating one @: ' + songPath);
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
					}
				}
			}
		#end
		var daBeats:Int = 0;
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				if(songNotes[3] != null)
				swagNote.noteType = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2;
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (FlxG.save.data.middleScroll)
			{
				babyArrow.x -= 275;
				if (player != 1) {
					babyArrow.visible = false;
				}
			}

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if desktop
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "Acc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			if (curStage == 'phillyStreets')
			{
			resumeCars();
			}

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if desktop
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}


	function generateRanking():String
	{
		var ranking:String = "N/A";

		if (misses == 0 && bads == 0 && shits == 0 && goods == 0)
			ranking = "(MFC)";
		else if (misses == 0 && bads == 0 && shits == 0 && goods >= 1)
			ranking = "(GFC)";
		else if (misses == 0)
			ranking = "(FC)";
		else if (misses < 10)
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935,
			accuracy >= 99.980,
			accuracy >= 99.970,
			accuracy >= 99.955,
			accuracy >= 99.90,
			accuracy >= 99.80,
			accuracy >= 99.70,
			accuracy >= 99,
			accuracy >= 96.50,
			accuracy >= 93,
			accuracy >= 90,
			accuracy >= 85,
			accuracy >= 80,
			accuracy >= 70,
			accuracy >= 60,
			accuracy < 60
		];

		for(i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch(i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";

		return ranking;
	}

	public static var songRate = 1.5;

	function shouldTransitionState():Bool {
		return boyfriend.curCharacter != "pico-blazin";
	}

	var lightningTimer:Float = 3.0;
	var lightningActive:Bool = true;

	var rainTimeScale:Float = 1.0;

  public static function coolLerp(base:Float, target:Float, ratio:Float):Float
  {
    return base + cameraLerp(ratio) * (target - base);
  }

  public static function cameraLerp(lerp:Float):Float
  {
    return lerp * (FlxG.elapsed / (1 / 60));
  }

	var isCameraOnForcedPos:Bool = false;

	var hasHidden = false;

  public var isPlayerDying:Bool = false;

	override public function update(elapsed:Float)
	{
		if(!inCutscene && !paused)
			FlxG.camera.followLerp = 0.04 * 1;
		else
			FlxG.camera.followLerp = 0;

		if(gf.curCharacter == 'nene')
		{
		if (shouldTransitionState()) {
			transitionState();
		}

		if(gf.animation.curAnim.finished)
		onAnimationFinished(gf.animation.curAnim.name);

		if(gf.animation.curAnim != null)
		onAnimationFrame(gf.animation.curAnim.name, gf.animation.curAnim.curFrame);
		}

		if(boyfriend.curCharacter == 'pico-playable')
		{
		if(boyfriend.animation.curAnim.finished)
		onAnimationFinished2(boyfriend.animation.curAnim.name);

		if(boyfriend.animation.curAnim != null)
		onAnimationFrame2(boyfriend.animation.curAnim.name, boyfriend.animation.curAnim.curFrame);
		}

		if (curSong.toLowerCase() == 'blazin')
		{
		if (!hasHidden)
		{
			hasHidden = true;
			hideOpponentStrumline();
			centerPlayerStrumline();
		}
		}

		if(picoBlazin != null)
		{
		if(picoBlazin.anim.curSymbol.name == 'uppercut' && picoBlazin.anim.finished)
		{
		picoBlazin.anim.play('uppercut-hold', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		}
		if(picoBlazin.anim.curSymbol.name == 'taunt' && picoBlazin.anim.finished)
		{
		picoBlazin.anim.play('taunt-hold', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		}
		}

		if(darnellBlazin != null)
		{
		if(darnellBlazin.anim.curSymbol.name == 'uppercut' && darnellBlazin.anim.finished)
		{
		darnellBlazin.anim.play('uppercut-hold', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		}
		}

		#if !debug
		perfectMode = false;
		#end

		#if linc_luajit
		if (executeModchart && lua != null && songStarted)
		{
			setVar('songPos',Conductor.songPosition);
			setVar('hudZoom', camHUD.zoom);
			setVar('cameraZoom',FlxG.camera.zoom);
			callLua('update', [elapsed]);

			FlxG.camera.angle = getVar('cameraAngle', 'float');
			camHUD.angle = getVar('camHudAngle','float');

			if (getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = getVar("strumLine1Visible",'bool');
			var p2 = getVar("strumLine2Visible",'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		if (currentFrames == FlxG.save.data.fpsCap)
		{
			for(i in 0...notesHitArray.length)
			{
				var cock:Date = notesHitArray[i];
				if (cock != null)
					if (cock.getTime() + 2000 < Date.now().getTime())
						notesHitArray.remove(cock);
			}
			nps = Math.floor(notesHitArray.length / 2);
			currentFrames = 0;
		}
		else
			currentFrames++;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'phillyStreets':
		if(scrollingSky != null) scrollingSky.scrollX -= FlxG.elapsed * 22;

		if(rainShader != null)
		{
var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, (FlxG.sound.music != null ? FlxG.sound.music.length : 0), rainShaderStartIntensity, rainShaderEndIntensity);
			rainShader.intensity = remappedIntensityValue;
			rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
			rainShader.update(elapsed);
		}

		if(cutsceneConductor != null && cutsceneMusic != null)
		{
			if(cutsceneMusic.playing)
			cutsceneConductor.songPosition = cutsceneMusic.time;

			if(cutsceneConductor.curStep % 4 == 0)
			onCutsceneBeatHit();
		}

			case 'phillyBlazin':
		if(scrollingSky != null) scrollingSky.scrollX -= FlxG.elapsed * 35;

		if(rainShader != null)
		{
			rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
			rainShader.update(elapsed * rainTimeScale);
			rainTimeScale = coolLerp(rainTimeScale, 0.02, 0.05);
		}

		if (lightningActive) {
			lightningTimer -= FlxG.elapsed;
		} else {
			lightningTimer = 1;
		}

		if (lightningTimer <= 0) {
			applyLightning();
			lightningTimer = FlxG.random.float(7, 15);
		}
		}

		super.update(elapsed);

		if (!offsetTesting)
		{
			if (FlxG.save.data.accuracyDisplay)
			{
				scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + (Conductor.safeFrames != 10 ? songScore + " (" + songScoreDef + ")" : "" + songScore) + " | Combo Breaks:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% | " + generateRanking();
			}
			else
			{
				scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + songScore;
			}
		}
		else
		{
			scoreTxt.text = "Suggested Offset: " + offsetTest;

		}
		if ((#if android FlxG.android.justReleased.BACK || #elseif !desktop touchPad.buttonP.justPressed || #end controls.PAUSE) && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			FlxG.camera.followLerp = 0;
			if (curStage == 'phillyStreets')
			{
			pauseCars();
			}

			if (FlxG.random.bool(0.1))
			{
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			#if linc_luajit
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
			#end
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
		}
		
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
		if (curSong.toLowerCase() == 'darnell')
		{
		switch (curStep)
		{
		case 32:
		PlayState.SONG.notes[2].mustHitSection = false;
		case 36:
		PlayState.SONG.notes[2].mustHitSection = true;
		case 256:
		PlayState.SONG.notes[16].mustHitSection = true;
		case 258:
		PlayState.SONG.notes[16].mustHitSection = false;
		case 320:
		PlayState.SONG.notes[20].mustHitSection = false;
		case 322:
		PlayState.SONG.notes[20].mustHitSection = true;
		case 384:
		PlayState.SONG.notes[24].mustHitSection = true;
		case 388:
		PlayState.SONG.notes[24].mustHitSection = false;
		case 448:
		PlayState.SONG.notes[28].mustHitSection = false;
		case 452:
		PlayState.SONG.notes[28].mustHitSection = true;
		case 768:
		PlayState.SONG.notes[48].mustHitSection = true;
		case 770:
		PlayState.SONG.notes[48].mustHitSection = false;
		case 832:
		PlayState.SONG.notes[52].mustHitSection = false;
		case 834:
		PlayState.SONG.notes[52].mustHitSection = true;
		case 896:
		PlayState.SONG.notes[56].mustHitSection = true;
		case 900:
		PlayState.SONG.notes[56].mustHitSection = false;
		case 960:
		PlayState.SONG.notes[60].mustHitSection = false;
		case 964:
		PlayState.SONG.notes[60].mustHitSection = true;
		case 1056:
		PlayState.SONG.notes[66].mustHitSection = false;
		case 1060:
		PlayState.SONG.notes[66].mustHitSection = true;
		}
		}
			
		if(!isCameraOnForcedPos)
		{
			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if(abot != null)
				abot.lookLeft();
				camFollow.setPosition(dad.getMidpoint().x + 150 #if linc_luajit + (lua != null ? getVar("followXOffset", "float") : 0) #end, dad.getMidpoint().y - 100 #if linc_luajit + (lua != null ? getVar("followYOffset", "float") : 0) #end);

				switch (curStage)
				{
					case 'phillyStreets':
						var dadCenterX = dad.x + 135 + dad.width / 2;
						var dadCenterY = dad.y + 45 + dad.height / 2;
						camFollow.setPosition(dadCenterX + 500, dadCenterY + -100);
					case 'phillyBlazin':
						camFollow.setPosition(1403, 717);
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				if(abot != null)
				abot.lookRight();
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 #if linc_luajit + (lua != null ? getVar("followXOffset", "float") : 0) #end, boyfriend.getMidpoint().y - 100 #if linc_luajit + (lua != null ? getVar("followYOffset", "float") : 0) #end);

				switch (curStage)
				{
					case 'phillyStreets':
						var boyfriendCenterX = boyfriend.x + boyfriend.width / 2;
						var boyfriendCenterY = boyfriend.y + boyfriend.height / 2;
						camFollow.setPosition(boyfriendCenterX + -350, boyfriendCenterY + -100);
					case 'phillyBlazin':
						camFollow.setPosition(1403, 717);
				}
			}
		}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick("dadX", dad.x);
		FlxG.watch.addQuick("dady", dad.y);
		if (loadRep)
			{
				FlxG.watch.addQuick('rep rpesses',repPresses);
				FlxG.watch.addQuick('rep releases',repReleases);
			}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			if(curStage == 'phillyBlazin')
			{
			if(!isPlayerDying)
			{
			isPlayerDying = true;
			new FlxTimer().start(0.125, function(tmr)
			{
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			});
			}
			}
			else
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(),"\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				var msTilStrum = dunceNote.strumTime - Conductor.songPosition;
			switch(dunceNote.noteType) {
				case "weekend-1-lightcan":
					scheduleLightCanSound(msTilStrum - 65);
				case "weekend-1-kickcan":
					scheduleKickCanSound(msTilStrum - 50);
				case "weekend-1-kneecan":
					scheduleKneeCanSound(msTilStrum - 22);
				default:
			}

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{	
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;

						if(curStage == 'phillyBlazin')
						rainTimeScale += 0.7;

						var altAnim:String = "";
	
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}
	
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}

		moveByNoteKind(daNote.noteType);

		if (dad.curCharacter == 'darnell')
		{
		if(daNote.noteType == "weekend-1-lightcan")
		playLightCanAnim();
		if(daNote.noteType == "weekend-1-kickcan")
		{
		playKickCanAnim();

				var newCan:SpraycanAtlasSprite = new SpraycanAtlasSprite(0, 0);

				newCan.x = spraycanPile.x - 430;
				newCan.y = spraycanPile.y - 840;

				newCan.playCanStart();

				insert(members.indexOf(spraycanPile), newCan);
				remove(spraycanPile);
				insert(members.indexOf(newCan), spraycanPile);
				spawnedCans.push(newCan);
		}
		if(daNote.noteType == "weekend-1-kneecan")
		playKneeCanAnim();
		}

		if (dad.curCharacter == 'darnell-blazin')
		{
		darnellBlazinNoteHit(daNote);
		}

		if (boyfriend.curCharacter == 'pico-blazin')
		{
		picoBlazinNoteHit(daNote);
		}

						dad.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
	
					if (FlxG.save.data.downscroll)
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));
					else
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));

					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
	
					if ((daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll) && daNote.mustPress)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else
						{
							health -= 0.075;
							vocals.volume = 0;
							if (theFunne)
								noteMiss(daNote.noteData, daNote);
						}
	
						daNote.active = false;
						daNote.visible = false;
	
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}


		if (!inCutscene)
			keyShit();


		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	var hasPlayedCutscene:Bool = false;

	function endSong():Void
	{
		mobileControls.instance.visible = #if !android touchPad.visible = #end lightningActive = false;

		if (SONG.song.toLowerCase() == '2hot' && !hasPlayedCutscene && isStoryMode)
		{
		FlxG.sound.music.stop();
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		startCutscene();
		return;
		}

		if (SONG.song.toLowerCase() == 'blazin' && !hasPlayedCutscene && isStoryMode)
		{
		FlxG.sound.music.stop();
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		bgSprite = new FlxSprite(0, 0).makeGraphic(2000, 2500, 0xFF000000);
		bgSprite.cameras = [camCutscene];
		add(bgSprite);
		startVideo3();
		hasPlayedCutscene = true;
		return;
		}

		if (!loadRep)
			rep.SaveReplay();

		#if linc_luajit
		if (executeModchart)
		{
			Lua.close(lua);
			lua = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			if (curSong.toLowerCase() == '2hot')
			Highscore.saveScore('TwoHOT', Math.round(songScore), storyDifficulty);
			else
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.switchState(new StoryMenuState());

					#if linc_luajit
					if (lua != null)
					{
						Lua.close(lua);
						lua = null;
					}
					#end

					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
				}
				else
				{
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				FlxG.switchState(new FreeplayState());
			}
		}
	}


	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					if (combo > 70 && gf.animOffsets.exists('drop70'))
					{
					gf.canPlayOtherAnims = true;
					gf.playAnim('drop70', true);
					gf.canPlayOtherAnims = false;
					}
					combo = 0;
					misses++;
					health -= 0.2;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}

			if (daRating != 'shit' || daRating != 'bad')
				{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
	
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			if (curSong.toLowerCase() == 'blazin')
			{
			rating.x += 380;
			rating.y += -50;
			}
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = truncateFloat(noteDiff, 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			add(rating);
	
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0);

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));

				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
	
			coolText.text = Std.string(seperatedScore);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;
			}
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

	private function keyShit():Void
	{
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		if (loadRep)
		{
			up = false;
			down = false;
			right = false;
			left = false;
			
			if (repPresses < rep.replay.keyPresses.length && repReleases < rep.replay.keyReleases.length)
			{
				upP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition  && rep.replay.keyPresses[repPresses].key == "up";
				rightP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "right";
				downP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "down";
				leftP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition  && rep.replay.keyPresses[repPresses].key == "left";	

				upR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "up";
				rightR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition  && rep.replay.keyReleases[repReleases].key == "right";
				downR = rep.replay.keyPresses[repReleases].time - 1<= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "down";
				leftR = rep.replay.keyPresses[repReleases].time - 1<= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "left";

				upHold = upP ? true : upR ? false : true;
				rightHold = rightP ? true : rightR ? false : true;
				downHold = downP ? true : downR ? false : true;
				leftHold = leftP ? true : leftR ? false : true;
			}
		}
		else if (!loadRep)
		{
			if (upP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "up"});
			if (rightP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "right"});
			if (downP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "down"});
			if (leftP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "left"});

			if (upR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "up"});
			if (rightR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "right"});
			if (downR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "down"});
			if (leftR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "left"});
		}
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
			{
				repPresses++;
				boyfriend.holdTimer = 0;
	
				var possibleNotes:Array<Note> = [];
	
				var ignoreList:Array<Int> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					{
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
						ignoreList.push(daNote.noteData);
					}
				});
	
				
				if (possibleNotes.length > 0)
				{
					var daNote = possibleNotes[0];
	
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{

								if (controlArray[coolNote.noteData])
									goodNoteHit(coolNote);
								else
								{
									var inIgnoreList:Bool = false;
									for (shit in 0...ignoreList.length)
									{
										if (controlArray[ignoreList[shit]])
											inIgnoreList = true;
									}
								}
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							if (loadRep)
							{
								var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

								daNote.rating = Ratings.CalculateRating(noteDiff);

								if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
								{
									goodNoteHit(daNote);
									trace('force note hit');
								}
								else
									noteCheck(controlArray, daNote);
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								if (loadRep)
									{
										if (NearlyEquals(coolNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
										{
											var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);

											if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
												coolNote.rating = "shit";
											else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
												coolNote.rating = "bad";
											else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
												coolNote.rating = "good";
											else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
												coolNote.rating = "sick";
											goodNoteHit(coolNote);
											trace('force note hit');
										}
										else
											noteCheck(controlArray, daNote);
									}
								else
									noteCheck(controlArray, coolNote);
							}
						}
					}
					else
					{	
						if (loadRep)
						{
							if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
							{
								var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

								daNote.rating = Ratings.CalculateRating(noteDiff);

								goodNoteHit(daNote);
								trace('force note hit');
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
							noteCheck(controlArray, daNote);
					}
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
			}
	
			if ((up || right || down || left) && generatedMusic || (upHold || downHold || leftHold || rightHold) && loadRep && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						switch (daNote.noteData)
						{
							case 2:
								if (up || upHold)
									goodNoteHit(daNote);
							case 3:
								if (right || rightHold)
									goodNoteHit(daNote);
							case 1:
								if (down || downHold)
									goodNoteHit(daNote);
							case 0:
								if (left || leftHold)
									goodNoteHit(daNote);
						}
					}
				});
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
	
				playerStrums.forEach(function(spr:FlxSprite)
				{
					switch (spr.ID)
					{
						case 2:
							if (loadRep)
							{
							}
							else
							{
								if (upP && spr.animation.curAnim.name != 'confirm' && !loadRep)
								{
									spr.animation.play('pressed');
									trace('play');
								}
								if (upR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							}
						case 3:
							if (loadRep)
								{
								}
							else
							{
								if (rightP && spr.animation.curAnim.name != 'confirm' && !loadRep)
									spr.animation.play('pressed');
								if (rightR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							}	
						case 1:
							if (loadRep)
								{
								}
							else
							{
								if (downP && spr.animation.curAnim.name != 'confirm' && !loadRep)
									spr.animation.play('pressed');
								if (downR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							}
						case 0:
							if (loadRep)
								{
								}
							else
							{
								if (leftP && spr.animation.curAnim.name != 'confirm' && !loadRep)
									spr.animation.play('pressed');
								if (leftR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							}
					}
					
					if (spr.animation.curAnim.name == 'confirm')
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			if (combo > 70 && gf.animOffsets.exists('drop70'))
			{
				gf.canPlayOtherAnims = true;
				gf.playAnim('drop70', true);
				gf.canPlayOtherAnims = false;
			}
			combo = 0;
			misses++;

			var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if(daNote.noteType == "weekend-1-cockgun")
			{
			}
			else if(daNote.noteType == "weekend-1-firegun")
			{
			}
			else
			{
			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
			}

		switch (daNote.noteType)
		{
			case "weekend-1-cockgun":
				health += 0.04;
			case "weekend-1-firegun":
				playCanExplodeAnim();
				gunCocked = false;
				health += 0.04;
				missNextCan();
				takeCanDamage();
		}

		if (dad.curCharacter == 'darnell-blazin')
		{
		darnellBlazinNoteMiss(daNote);
		}

		if (boyfriend.curCharacter == 'pico-blazin')
		{
		picoBlazinNoteMiss(daNote);
		}

			updateAccuracy();
		}
	}

	var HEALTH_LOSS = 0.25 * 2;

	public var Explode = false;

	function takeCanDamage():Void {
		trace('Taking damage from can exploding!');
		health -= HEALTH_LOSS;

		if (health <= 0) {
			trace('Died to the can! Use special death animation.');

			Explode = true;

			blackenStageProps();
		}
	}

	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
				note.rating = "shit";
			else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
				note.rating = "bad";
			else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
				note.rating = "good";
			else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
				note.rating = "sick";

			if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note);
					}
				}
			}
			else if (controlArray[note.noteData])
				{
					for (b in controlArray) {
						if (b)
							mashing++;
					}

					if (mashing <= getKeyPresses(note) && mashViolations < 2)
					{
						mashViolations++;
						
						goodNoteHit(note, (mashing <= getKeyPresses(note)));
					}
					else
					{
						playerStrums.members[0].animation.play('static');
						playerStrums.members[1].animation.play('static');
						playerStrums.members[2].animation.play('static');
						playerStrums.members[3].animation.play('static');
						health -= 0.2;
						trace('mash ' + mashing);
					}

					if (mashing != 0)
						mashing = 0;
				}
		}

		var nps:Int = 0;

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{
				if(note.noteType == "weekend-1-firegun" && !gunCocked) return trace('Cannot fire gun!');
				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				if (!note.isSustainNote)
					notesHitArray.push(Date.now());

				if (resetMashViolation)
					mashViolations--;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						if(combo == 50 && gf.animOffsets.exists('combo50'))
						{
						gf.canPlayOtherAnims = true;
						gf.playAnim('combo50', true);
						gf.canPlayOtherAnims = false;
						}
						if(combo == 200 && gf.animOffsets.exists('combo200'))
						{
						gf.canPlayOtherAnims = true;
						gf.playAnim('combo200', true);
						gf.canPlayOtherAnims = false;
						}
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;

						if(curStage == 'phillyBlazin')
						rainTimeScale += 0.7;

					switch (note.noteData)
					{
						case 2:
							boyfriend.playAnim('singUP', true);
						case 3:
							boyfriend.playAnim('singRIGHT', true);
						case 1:
							boyfriend.playAnim('singDOWN', true);
						case 0:
							boyfriend.playAnim('singLEFT', true);
					}

			moveByNoteKind(note.noteType);

			if (boyfriend.curCharacter == 'pico-playable')
			{
			switch(note.noteType) {
				case "weekend-1-cockgun":
					boyfriend.holdTimer = 0;
					playCockGunAnim();
					gunCocked = true;
					new FlxTimer().start(1.0, function(tmr)
					{
					gunCocked = false;
					});
				case "weekend-1-firegun":
					boyfriend.holdTimer = 0;
					playFireGunAnim();
					if (gunCocked)
					{
					trace('Firing gun!');
					shootNextCan();
					}
				default:
			}
			}

		if (dad.curCharacter == 'darnell-blazin')
		{
		darnellBlazinNoteHit(note);
		}

		if (boyfriend.curCharacter == 'pico-blazin')
		{
		picoBlazinNoteHit(note);
		}

					if (!loadRep)
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(note.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
						});
		
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (curSong.toLowerCase() == '2hot')
		{
		switch (curStep)
		{
		case 108:
		isCameraOnForcedPos = true;
		var charCenterX = gf.x + gf.width / 2;
		var charCenterY = gf.y + gf.height / 2;
		camFollow.setPosition(charCenterX + 100,charCenterY + 105);

		var durSeconds = Conductor.stepCrochet * 4 / 1000;
		var targetZoom = 0.65 * FlxCamera.defaultZoom;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.elasticInOut});

		case 128:
		isCameraOnForcedPos = false;

		var durSeconds = Conductor.stepCrochet * 12 / 1000;
		var targetZoom = 0.95 * 0.77;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.quadInOut});

		case 492:
		isCameraOnForcedPos = true;
		var charCenterX = gf.x + gf.width / 2;
		var charCenterY = gf.y + gf.height / 2;
		camFollow.setPosition(charCenterX + 100,charCenterY + 105);

		var durSeconds = Conductor.stepCrochet * 4 / 1000;
		var targetZoom = 0.65 * FlxCamera.defaultZoom;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.elasticInOut});

		case 512:
		isCameraOnForcedPos = false;

		var durSeconds = Conductor.stepCrochet * 12 / 1000;
		var targetZoom = 0.95 * 0.77;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.quadInOut});

		case 620:
		isCameraOnForcedPos = true;
		var charCenterX = gf.x + gf.width / 2;
		var charCenterY = gf.y + gf.height / 2;
		camFollow.setPosition(charCenterX + 100,charCenterY + 105);

		var durSeconds = Conductor.stepCrochet * 4 / 1000;
		var targetZoom = 0.65 * FlxCamera.defaultZoom;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.elasticInOut});

		case 640:
		isCameraOnForcedPos = false;

		var durSeconds = Conductor.stepCrochet * 12 / 1000;
		var targetZoom = 0.95 * 0.77;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.quadInOut});

		case 972:
		isCameraOnForcedPos = true;
		var charCenterX = gf.x + gf.width / 2;
		var charCenterY = gf.y + gf.height / 2;
		camFollow.setPosition(charCenterX + 100,charCenterY + 105);

		var durSeconds = Conductor.stepCrochet * 4 / 1000;
		var targetZoom = 0.65 * FlxCamera.defaultZoom;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.elasticInOut});

		case 992:
		isCameraOnForcedPos = false;

		var durSeconds = Conductor.stepCrochet * 12 / 1000;
		var targetZoom = 0.95 * 0.77;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.quadInOut});

		case 1036:
		isCameraOnForcedPos = true;
		var charCenterX = gf.x + gf.width / 2;
		var charCenterY = gf.y + gf.height / 2;
		camFollow.setPosition(charCenterX + 100,charCenterY + 105);

		var durSeconds = Conductor.stepCrochet * 4 / 1000;
		var targetZoom = 0.65 * FlxCamera.defaultZoom;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.elasticInOut});

		case 1056:
		isCameraOnForcedPos = false;

		var durSeconds = Conductor.stepCrochet * 12 / 1000;
		var targetZoom = 0.95 * 0.77;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.quadInOut});

		case 1420:
		isCameraOnForcedPos = true;
		var charCenterX = gf.x + gf.width / 2;
		var charCenterY = gf.y + gf.height / 2;
		camFollow.setPosition(charCenterX + 100,charCenterY + 105);

		var durSeconds = Conductor.stepCrochet * 4 / 1000;
		var targetZoom = 0.65 * FlxCamera.defaultZoom;
		FlxTween.tween(this, {defaultCamZoom: targetZoom}, durSeconds, {ease: FlxEase.elasticInOut});

		case 1440:
		FlxG.camera.zoom = 0.77;
		defaultCamZoom = 0.77;
		}
		}

		#if linc_luajit
		if (executeModchart && lua != null)
		{
			setVar('curStep',curStep);
			callLua('stepHit',[curStep]);
		}
		#end

		#if desktop
		songLength = FlxG.sound.music.length;

		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "Acc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC,true,  songLength - Conductor.songPosition);
		#end

	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		#if linc_luajit
		if (executeModchart && lua != null)
		{
			setVar('curBeat',curBeat);
			callLua('beatHit',[curBeat]);
		}
		#end

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}

			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
			if (abot != null)
			{
			abot.speaker.anim.play('anim', true);
			abot.speaker.anim.curFrame = 1;
			}
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		switch (curStage)
		{
			case "phillyStreets":
		if (FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && carInterruptable == true){
			if(lightsStop == false){
				driveCar(phillyCars);
			}
			else{
				driveCarLights(phillyCars);
			}
		}
	
		if(FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && car2Interruptable == true && lightsStop == false) driveCarBack(phillyCars2);
	
		if (curBeat == (lastChange + changeInterval)) changeLights(curBeat);
		}
	}

	var curLight:Int = 0;

  	function changeLights(beat:Int):Void{

		lastChange = beat;
		lightsStop = !lightsStop;

		if(lightsStop){
			phillyTraffic.animation.play('tored');
			changeInterval = 20;
		} else {
			phillyTraffic.animation.play('togreen');
			changeInterval = 30;

			if(carWaiting == true) finishCarLights(phillyCars);
		}
	}

	function resetCar(left:Bool, right:Bool){
		if(left){
			carWaiting = false;
			carInterruptable = true;
			if (phillyCars != null) {
				FlxTween.cancelTweensOf(phillyCars);
				phillyCars.x = 1200;
				phillyCars.y = 818;
				phillyCars.angle = 0;
			}
		}

		if(right){
			car2Interruptable = true;
			if (phillyCars2 != null) {
				FlxTween.cancelTweensOf(phillyCars2);
				phillyCars2.x = 1200;
				phillyCars2.y = 818;
				phillyCars2.angle = 0;
			}
		}
	}

	function finishCarLights(sprite:FlxSprite):Void{
		carWaiting = false;
		var duration:Float = FlxG.random.float(1.8, 3);
		var rotations:Array<Int> = [-5, 18];
		var offset:Array<Float> = [306.6, 168.3];
		var startdelay:Float = FlxG.random.float(0.2, 1.2);

		var path:Array<FlxPoint> = [
			FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15),
			FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
			FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.sineIn, startDelay: startdelay} );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.sineIn,
			startDelay: startdelay,
			onComplete: function(_) {
				carInterruptable = true;
			}
		});
	}

	function driveCarLights(sprite:FlxSprite):Void{
		carInterruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		var extraOffset = [0, 0];
		var duration:Float = 2;

		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.9, 1.5);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		
		var rotations:Array<Int> = [-7, -5];
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);

		var path:Array<FlxPoint> = [
			FlxPoint.get(1500 - offset[0] - 20, 1049 - offset[1] - 20),
			FlxPoint.get(1770 - offset[0] - 80, 994 - offset[1] + 10),
			FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15)
		];
		FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.cubeOut} );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.cubeOut,
			onComplete: function(_) {
				carWaiting = true;
				if(lightsStop == false) finishCarLights(phillyCars);
			}
		});
	}

	function driveCar(sprite:FlxSprite):Void{
		carInterruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		var extraOffset = [0, 0];
		var duration:Float = 2;
		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.6, 1.2);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);
		var rotations:Array<Int> = [-8, 18];
		var path:Array<FlxPoint> = [
			FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 30),
			FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
			FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, null );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: null,
			onComplete: function(_) {
				carInterruptable = true;
			}
		});
	}

	function driveCarBack(sprite:FlxSprite):Void{
		car2Interruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		var extraOffset = [0, 0];
		var duration:Float = 2;
		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.6, 1.2);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);
		var rotations:Array<Int> = [18, -8];
		var path:Array<FlxPoint> = [
				FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 60),
				FlxPoint.get(2400 - offset[0], 980 - offset[1] - 30),
				FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 10)

		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, null );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: null,
			onComplete: function(_) {
				car2Interruptable = true;
			}
		});
	}

	function setupRainShader()
	{
		rainShader = new RainShader();
		rainShader.scale = FlxG.height / 200;
		switch (SONG.song.toLowerCase())
		{
			case 'darnell':
				rainShaderStartIntensity = 0;
				rainShaderEndIntensity = 0.1;
			case 'lit-up':
				rainShaderStartIntensity = 0.1;
				rainShaderEndIntensity = 0.2;
			case '2hot':
				rainShaderStartIntensity = 0.2;
				rainShaderEndIntensity = 0.4;
		}
		rainShader.intensity = rainShaderStartIntensity;
		if(curStage == 'phillyBlazin')
		rainShader.intensity = 0.5;
		FlxG.camera.setFilters([new ShaderFilter(rainShader)]);
	}

  var cutsceneMusic:FlxSound;

  var cutsceneConductor:CutsceneConductor;

  function introCutscene(){
						var boyfriendCenterX = boyfriend.x + boyfriend.width / 2;
						var boyfriendCenterY = boyfriend.y + boyfriend.height / 2;
						var gfCenterX = gf.x + gf.width / 2;
						var gfCenterY = gf.y + gf.height / 2;
						var dadCenterX = dad.x + 135 + dad.width / 2;
						var dadCenterY = dad.y + 45 + dad.height / 2;
		var picoPos:Array<Float> = [boyfriendCenterX + -350, boyfriendCenterY + -100];
		var nenePos:Array<Float> = [gfCenterX, gfCenterY];
		var darnellPos:Array<Float> = [dadCenterX + 500, dadCenterY - 100];

		var cutsceneDelay:Float = 2;

		cutsceneMusic = new FlxSound().loadEmbedded(Paths.music("darnellCanCutscene/darnellCanCutscene", "weekend1"));
		cutsceneMusic.looped = true;
		FlxG.sound.list.add(cutsceneMusic);

		cutsceneConductor = new CutsceneConductor();

		cutsceneConductor.changeBPM(168);

		var cutsceneCan:FlxSprite = new FlxSprite(darnellPos[0], darnellPos[1]);
		cutsceneCan.frames = Paths.getSparrowAtlas('wked1_cutscene_1_can', 'weekend1');
		cutsceneCan.animation.addByPrefix('forward', "can kick quick0", 24, false);
		cutsceneCan.animation.addByPrefix('up', "can kicked up0", 24, false);
		add(cutsceneCan);
		cutsceneCan.antialiasing = true;
		cutsceneCan.visible = false;

		cutsceneCan.x = spraycanPile.x + 30;
		cutsceneCan.y = spraycanPile.y - 320;

		var newCan:SpraycanAtlasSprite = new SpraycanAtlasSprite(0, 0);
		newCan.x = spraycanPile.x - 430;
		newCan.y = spraycanPile.y - 840;
		add(newCan);
		newCan.antialiasing = true;
		newCan.visible = false;

		boyfriend.playAnim('intro1', true);

		new FlxTimer().start(0.1, function(tmr)
		{
			camFollow.setPosition(picoPos[0] + 250, picoPos[1]);
			FlxG.camera.focusOn(camFollow.getPosition());

			FlxG.camera.zoom  = 1.3;
		});

		new FlxTimer().start(0.7, function(tmr){
			cutsceneMusic.play(false);
			FlxTween.tween(bgSprite, {alpha: 0}, 2, {startDelay: 0.3, onComplete: function(twn:FlxTween) {bgSprite.visible = false;}});
		});

		new FlxTimer().start(cutsceneDelay, function(tmr){
			FlxTween.tween(camFollow, {x: darnellPos[0]+100, y: darnellPos[1]}, 2.5, {ease: FlxEase.quadInOut});
			FlxTween.tween(FlxG.camera, {zoom: 0.66}, 2.5, {ease: FlxEase.quadInOut});
		});

		new FlxTimer().start(cutsceneDelay + 3, function(tmr)
		{
			dad.playAnim('lightCan', true);
			FlxG.sound.play(Paths.sound('Darnell_Lighter', 'weekend1'), 1.0);
		});

		new FlxTimer().start(cutsceneDelay + 4, function(tmr)
		{
			boyfriend.playAnim('cock', true);
			FlxTween.tween(camFollow, {x: darnellPos[0]+180, y: darnellPos[1]}, 0.4, {ease: FlxEase.backOut});
			FlxG.sound.play(Paths.sound('Gun_Prep', 'weekend1'), 1.0);
		});

		new FlxTimer().start(cutsceneDelay + 4.4, function(tmr)
		{
			dad.playAnim('kickCan', true);
			FlxG.sound.play(Paths.sound('Kick_Can_UP', 'weekend1'), 1.0);
			cutsceneCan.animation.play('up');
			cutsceneCan.visible = true;
		});

		new FlxTimer().start(cutsceneDelay + 4.9, function(tmr)
		{
			dad.playAnim('kneeCan', true);
			FlxG.sound.play(Paths.sound('Kick_Can_FORWARD', 'weekend1'), 1.0);
			cutsceneCan.animation.play('forward');
		});

		new FlxTimer().start(cutsceneDelay + 5.1, function(tmr)
		{
			boyfriend.playAnim('intro2', true);
			boyfriend.canPlayOtherAnims = false;

			FlxG.sound.play(Paths.soundRandom('shot', 1, 4, 'weekend1'));

			FlxTween.tween(camFollow, {x: darnellPos[0]+100, y: darnellPos[1]}, 1, {ease: FlxEase.quadInOut});

			newCan.playCanShot();
			newCan.visible = true;
			cutsceneCan.visible = false;
			new FlxTimer().start(1/24, function(tmr)
			{
				darkenStageProps();
			});
		});

		new FlxTimer().start(cutsceneDelay + 5.9, function(tmr)
		{
			dad.playAnim('laughCutscene', true);
			FlxG.sound.play(Paths.sound('cutscene/darnell_laugh', 'weekend1'), 0.6);
		});

		new FlxTimer().start(cutsceneDelay + 6.2, function(tmr)
		{
			gf.playAnim('laughCutscene', true);
			FlxG.sound.play(Paths.sound('cutscene/nene_laugh', 'weekend1'), 0.6);
		});

		new FlxTimer().start(cutsceneDelay + 8, function(tmr)
		{
			FlxTween.tween(FlxG.camera, {zoom: 0.77}, 2, {ease: FlxEase.sineInOut});
			FlxTween.tween(camFollow, {x: darnellPos[0]+180, y: darnellPos[1]}, 2, {ease: FlxEase.sineInOut});
			startCountdown();
			camHUD.visible = true;
			cutsceneMusic.stop();
			cutsceneMusic = null;
			cutsceneConductor.songPosition = 0;
			cutsceneConductor = null;
		});
	}

	function onCutsceneBeatHit() {
		if (dad.animation.curAnim.finished && dad.animation.curAnim.name != 'lightCan') {
			dad.dance();
		}

		if (gf.animation.curAnim.finished) {
			gf.dance();
			if (abot != null)
			{
			abot.speaker.anim.play('anim', true);
			abot.speaker.anim.curFrame = 1;
			}
		}
	}

	function pauseCars():Void {
		if (phillyCars != null) {
			FlxTweenUtil.pauseTweensOf(phillyCars);
		}

		if (phillyCars2 != null) {
			FlxTweenUtil.pauseTweensOf(phillyCars2);
		}
	}

	function resumeCars():Void {
		if (phillyCars != null) {
			FlxTweenUtil.resumeTweensOf(phillyCars);
		}

		if (phillyCars2 != null) {
			FlxTweenUtil.resumeTweensOf(phillyCars2);
		}
	}

	function darkenStageProps()
	{
			var blackScreen:FlxSprite = new FlxSprite(-500, -400).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
			insert(members.indexOf(gf), blackScreen);
			blackScreen.scrollFactor.set();
			blackScreen.blend = MULTIPLY;
			var stageProp = blackScreen;
			stageProp.color = 0xFF111111;
			spraycanPile.color = 0xFF111111;
			if(casingGroup != null)
			casingGroup.color = 0xFF111111;
			new FlxTimer().start(1/24, (tmr) ->
			{
				stageProp.color = 0xFF222222;
				spraycanPile.color = 0xFF222222;
				if(casingGroup != null)
				casingGroup.color = 0xFF222222;
				FlxTween.tween(stageProp, {alpha: 0}, 1.3);
				FlxTween.color(spraycanPile, 1.4, 0xFF222222, 0xFFFFFFFF);
				if(casingGroup != null)
				FlxTween.color(casingGroup, 1.4, 0xFF222222, 0xFFFFFFFF);
			});
	}

	function blackenStageProps()
	{
			var blackScreen:FlxSprite = new FlxSprite(-500, -400).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			insert(members.indexOf(boyfriend), blackScreen);
			blackScreen.scrollFactor.set();

			spraycanPile.color = 0xFF000000;
			if(casingGroup != null)
			casingGroup.color = 0xFF000000;
	}

	var video:VideoHandler;

	function startVideo() {
        video = new VideoHandler();
	video.scrollFactor.set();
	video.antialiasing = true;
        video.cameras = [camCutscene];

		video.playMP4(Paths.video("darnellCutscene"), function(){
		camHUD.visible = false;
		introCutscene();
		}, false);
		add(video);
	}

	function startVideo2() {
        video = new VideoHandler();
	video.scrollFactor.set();
	video.antialiasing = true;
        video.cameras = [camCutscene];

		video.playMP4(Paths.video("2hotCutscene"), function(){
		endSong();
		}, false);
		@:privateAccess
		video.bitmap.onPlaying.add(endCutscene);
		add(video);
		video.alpha = 0.00000001;
	}

	function startVideo3() {
        video = new VideoHandler();
	video.scrollFactor.set();
	video.antialiasing = true;
        video.cameras = [camCutscene];

		video.playMP4(Paths.video("blazinCutscene"), function(){
		endSong();
		}, false);
		add(video);
	}

	function playLightCanAnim() {
		dad.canPlayOtherAnims = true;
		dad.playAnim('lightCan', true);
		dad.canPlayOtherAnims = false;
	}

	var lightCanSound:FlxSound;
	var loadedLightCanSound:Bool = false;

	function scheduleLightCanSound(timeToPlay:Float) {
	FlxG.sound.play(Paths.sound('Darnell_Lighter', 'weekend1'), -timeToPlay);
	}

	function playKickCanAnim() {
		dad.canPlayOtherAnims = true;
		dad.playAnim('kickCan', true);
		dad.canPlayOtherAnims = false;
	}

	var kickCanSound:FlxSound;
	var loadedKickCanSound:Bool = false;

	function scheduleKickCanSound(timeToPlay:Float) {
	FlxG.sound.play(Paths.sound('Kick_Can_UP', 'weekend1'), -timeToPlay);
	}

	function playKneeCanAnim() {
		dad.canPlayOtherAnims = true;
		dad.playAnim('kneeCan', true);
		dad.canPlayOtherAnims = false;
	}

	var kneeCanSound:FlxSound;
	var loadedKneeCanSound:Bool = false;

	function scheduleKneeCanSound(timeToPlay:Float) {
	FlxG.sound.play(Paths.sound('Kick_Can_FORWARD', 'weekend1'), -timeToPlay);
	}

	function moveByNoteKind(kind:String) {
		if(abot == null) return;
		switch(kind) {
			case "weekend-1-lightcan":
				abot.lookLeft();
			case "weekend-1-cockgun":
				abot.lookRight();
			default:
		}
	}

	function transitionState() {
		switch (gf.currentState) {
			case 0:
				if (health <= gf.VULTURE_THRESHOLD) {
					gf.currentState = 1;
				} else {
					gf.currentState = 0;
				}
			case 1:
				if (health > gf.VULTURE_THRESHOLD) {
					gf.currentState = 0;
				} else if (gf.animationFinished) {
					gf.currentState = 2;
					gf.playAnim('raiseKnife');
					gf.animationFinished = false;
				}
			case 2:
				if (gf.animationFinished) {
					gf.currentState = 3;
					gf.animationFinished = false;
				}
			case 3:
				if (health > gf.VULTURE_THRESHOLD) {
					gf.currentState = 4;
				}
			case 4:
				if (gf.animationFinished) {
					gf.currentState = 0;
					gf.animationFinished = false;
				}
			default:
				gf.currentState = 0;
		}
	}

	function onAnimationFinished(name:String) {
		switch(gf.currentState) {
			case 2:
				if (name == "raiseKnife") {
					gf.animationFinished = true;
					transitionState();
				}
			case 4:
				if (name == "lowerKnife") {
					gf.animationFinished = true;
					transitionState();
				}
			default:
		}
	}

	var picoFlicker:FlxFlicker = null;

	function onAnimationFinished2(name:String) {
		if (name == 'shootMISS' && health > 0.0) {
      picoFlicker = FlxFlicker.flicker(boyfriend, 1, 1 / 30, true, true, function(_) {
		new FlxTimer().start(0.000001, function(tmr:FlxTimer)
		{
        picoFlicker = FlxFlicker.flicker(boyfriend, 0.5, 1 / 60, true, true, function(_) {
					picoFlicker = null;
				});
		});
      });
		}
	}

	function onAnimationFrame(name:String, frameNumber:Int) {
		switch(gf.currentState) {
			case 1:
				if (name == "danceLeft" && frameNumber == 13) {
					gf.animationFinished = true;
					transitionState();
				}
			default:
		}
	}

	var frameNumber2 = 0;

	function onAnimationFrame2(name:String, frameNumber:Int) {
		if (name == "cock" && frameNumber == 3 && frameNumber2 != 3) {
			createCasing();
		}
		if (name == "cock") {
			frameNumber2 = frameNumber;
		}
	}

	var alternate:Bool = false;

	function doAlternate():String {
		alternate = !alternate;
		return alternate ? '1' : '2';
	}

	function playBlockAnim()
	{
		darnellBlazin.anim.play('block', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		camGame.shake(0.002, 0.1);
		moveToBack();
	}

	function playCringeAnim()
	{
		darnellBlazin.anim.play('cringe', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToBack();
	}

	function playDodgeAnim()
	{
		darnellBlazin.anim.play('dodge', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToBack();
	}

	function playIdleAnim()
	{
		darnellBlazin.anim.play('idle', false);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToBack();
	}

	function playFakeoutAnim()
	{
		darnellBlazin.anim.play('fakeout', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToBack();
	}

	function playPissedConditionalAnim()
	{
		if (darnellBlazin.anim.curSymbol.name == "cringe") {
			playPissedAnim();
		} else {
			playIdleAnim();
		}
	}

	function playPissedAnim()
	{
		darnellBlazin.anim.play('pissed', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToBack();
	}

	function playUppercutPrepAnim()
	{
		darnellBlazin.anim.play('uppercutPrep', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToFront();
	}

	function playUppercutAnim()
	{
		darnellBlazin.anim.play('uppercut', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToFront();
	}

	function playUppercutHitAnim()
	{
		darnellBlazin.anim.play('uppercutHit', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToBack();
	}

	function playHitHighAnim()
	{
		darnellBlazin.anim.play('hitHigh', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		camGame.shake(0.0025, 0.15);
		moveToBack();
	}

	function playHitLowAnim()
	{
		darnellBlazin.anim.play('hitLow', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		camGame.shake(0.0025, 0.15);
		moveToBack();
	}

	function playPunchHighAnim()
	{
		darnellBlazin.anim.play('punchHigh' + doAlternate(), true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToFront();
	}

	function playPunchLowAnim()
	{
		darnellBlazin.anim.play('punchLow' + doAlternate(), true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		moveToFront();
	}

	function playSpinAnim()
	{
		darnellBlazin.anim.play('hitSpin', true);
		darnellBlazin.anim.curInstance.matrix.tx = 907.95;
		darnellBlazin.anim.curInstance.matrix.ty = 742;
		camGame.shake(0.0025, 0.15);
		moveToBack();
	}

	var casingGroup:FlxTypedSpriteGroup<CasingSprite>;

	function createCasing() {
		if (casingGroup == null) {
			casingGroup = new FlxTypedSpriteGroup<CasingSprite>();
			casingGroup.x = boyfriend.x + 250;
			casingGroup.y = boyfriend.y + 100;
			add(casingGroup);
		}

		var casing:CasingSprite = new CasingSprite();
		if (casing != null)
			casingGroup.add(casing);
	}

	var picoFade:FlxSprite;

	function playCockGunAnim() {
		boyfriend.canPlayOtherAnims = true;
		boyfriend.playAnim('cock', true);
		boyfriend.canPlayOtherAnims = false;

		picoFade = new FlxSprite(0, 0);
		picoFade.frames = boyfriend.frames;
		picoFade.frame = boyfriend.frame;
		picoFade.updateHitbox();
		picoFade.x = boyfriend.x;
		picoFade.y = boyfriend.y;
		picoFade.alpha = 0.3;
		insert(members.indexOf(boyfriend), picoFade);
		remove(boyfriend);
		insert(members.indexOf(picoFade), boyfriend);
		FlxTween.tween(picoFade.scale, {x: 1.3, y: 1.3}, 0.4);
		FlxTween.tween(picoFade, {alpha: 0}, 0.4);

		FlxG.sound.play(Paths.sound('Gun_Prep', 'weekend1'));
	}

	function playFireGunAnim() {
		boyfriend.canPlayOtherAnims = true;
		boyfriend.playAnim('shoot', true);
		boyfriend.canPlayOtherAnims = false;
		FlxG.sound.play(Paths.soundRandom('shot', 1, 4, 'weekend1'));
	}

	function playCanExplodeAnim() {
		boyfriend.canPlayOtherAnims = true;
		boyfriend.playAnim('shootMISS', true);
		boyfriend.canPlayOtherAnims = false;
		FlxG.sound.play(Paths.sound('Pico_Bonk', 'weekend1'));
	}

	var alternate2:Bool = false;

	function doAlternate2():String {
		alternate2 = !alternate2;
		return alternate2 ? '1' : '2';
	}

	function playBlockAnim2()
	{
		picoBlazin.anim.play('block', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		camGame.shake(0.002, 0.1);
		moveToBack2();
	}

	function playCringeAnim2()
	{
		picoBlazin.anim.play('cringe', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		moveToBack2();
	}

	function playDodgeAnim2()
	{
		picoBlazin.anim.play('dodge', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		moveToBack2();
	}

	function playIdleAnim2()
	{
		picoBlazin.anim.play('idle', false);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		moveToBack2();
	}

	function playFakeoutAnim2()
	{
		picoBlazin.anim.play('fakeout', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		moveToBack2();
	}

	function playUppercutPrepAnim2()
	{
		picoBlazin.anim.play('uppercutPrep', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		moveToFront2();
	}

	function playUppercutAnim2(hit:Bool)
	{
		picoBlazin.anim.play('uppercut', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		if (hit) {
			camGame.shake(0.005, 0.25);
		}
		moveToFront2();
	}

	function playUppercutHitAnim2()
	{
		picoBlazin.anim.play('uppercutHit', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		camGame.shake(0.005, 0.25);
		moveToBack2();
	}

	function playHitHighAnim2()
	{
		picoBlazin.anim.play('hitHigh', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		camGame.shake(0.0025, 0.15);
		moveToBack2();
	}

	function playHitLowAnim2()
	{
		picoBlazin.anim.play('hitLow', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		camGame.shake(0.0025, 0.15);
		moveToBack2();
	}

	function playHitSpinAnim2()
	{
		picoBlazin.anim.play('hitSpin', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		camGame.shake(0.0025, 0.15);
		moveToBack2();
	}

	function playPunchHighAnim2()
	{
		picoBlazin.anim.play('punchHigh' + doAlternate2(), true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		moveToFront2();
	}

	function playPunchLowAnim2()
	{
		picoBlazin.anim.play('punchLow' + doAlternate2(), true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		moveToFront2();
	}

	function playTauntConditionalAnim2()
	{
		if (picoBlazin.anim.curSymbol.name == "fakeout") {
			playTauntAnim2();
		} else {
			playIdleAnim2();
		}
	}

	function playTauntAnim2()
	{
		picoBlazin.anim.play('taunt', true);
		picoBlazin.anim.curInstance.matrix.tx = 858;
		picoBlazin.anim.curInstance.matrix.ty = 770;
		moveToBack2();
	}

	function moveToBack()
	{
		darnellBlazin.zIndex = 2000;

		groupBlazin.sort(byZIndex, FlxSort.ASCENDING);
	}

	function moveToFront()
	{
		darnellBlazin.zIndex = 3000;

		groupBlazin.sort(byZIndex, FlxSort.ASCENDING);
	}

	function moveToBack2()
	{
		picoBlazin.zIndex = 2000;

		groupBlazin.sort(byZIndex, FlxSort.ASCENDING);
	}

	function moveToFront2()
	{
		picoBlazin.zIndex = 3000;

		groupBlazin.sort(byZIndex, FlxSort.ASCENDING);
	}

	function applyLightning():Void {
		var LIGHTNING_FULL_DURATION = 1.5;
		var LIGHTNING_FADE_DURATION = 0.3;

		skyAdditive.visible = true;
		skyAdditive.alpha = 0.7;
		FlxTween.tween(skyAdditive, {alpha: 0.0}, LIGHTNING_FULL_DURATION, {
			onComplete: cleanupLightning,
		});

		foregroundMultiply.visible = true;
		foregroundMultiply.alpha = 0.64;
		FlxTween.tween(foregroundMultiply, {alpha: 0.0}, LIGHTNING_FULL_DURATION);

		additionalLighten.visible = true;
		additionalLighten.alpha = 0.3;
		FlxTween.tween(additionalLighten, {alpha: 0.0}, LIGHTNING_FADE_DURATION);

		lightning.visible = true;
		lightning.animation.play('strike');

		if(FlxG.random.bool(65)){
			lightning.x = FlxG.random.int(-250, 280);
		}else{
			lightning.x = FlxG.random.int(780, 900);
		}

		if(picoBlazin != null)
		FlxTween.color(picoBlazin, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
		if(picoBlazin != null)
		FlxTween.color(darnellBlazin, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
		FlxTween.color(gf, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFF888888);

		FlxG.sound.play(Paths.soundRandom('Lightning', 1, 3, 'weekend1'));
	}

	function cleanupLightning(tween:FlxTween):Void {
		skyAdditive.visible = false;
		foregroundMultiply.visible = false;
		additionalLighten.visible = false;
		lightning.visible = false;
	}

	public var STATE_ARCING:Int = 2;
	public var STATE_SHOT:Int = 3;
	public var STATE_IMPACTED:Int = 4;

	function getNextCanWithState(desiredState:Int)
	{
		for (index in 0...spawnedCans.length)
		{
			var can = spawnedCans[index];
			var canState = can.currentState;

			if (canState == desiredState)
			{
				return can;
			}
		}
		return null;
	}

	function shootNextCan()
	{
		var can = getNextCanWithState(STATE_ARCING);

		if (can != null)
		{
			can.currentState = STATE_SHOT;
			can.playCanShot();

			new FlxTimer().start(1/24, function(tmr)
			{
				darkenStageProps();
			});

		}
	}

	function missNextCan()
	{
		var can = getNextCanWithState(STATE_ARCING);

		if (can != null)
		{
			can.currentState = STATE_IMPACTED;
		}
	}

	var cantUppercut = false;

function darnellBlazinNoteHit(note:Note)
{
		if (!StringTools.startsWith(note.noteType, 'weekend-1-')) return;

		var shouldDoUppercutPrep = wasNoteHitPoorly(note) && isPlayerLowHealth() && FlxG.random.bool(30);

		if (shouldDoUppercutPrep) {
			playUppercutPrepAnim();
			return;
		}

		if (cantUppercut) {
			playPunchHighAnim();
			return;
		}

		switch (note.noteType)
		{
			case "weekend-1-punchlow":
				playHitLowAnim();
			case "weekend-1-punchlowblocked":
				playBlockAnim();
			case "weekend-1-punchlowdodged":
				playDodgeAnim();
			case "weekend-1-punchlowspin":
				playSpinAnim();
			case "weekend-1-punchhigh":
				playHitHighAnim();
			case "weekend-1-punchhighblocked":
				playBlockAnim();
			case "weekend-1-punchhighdodged":
				playDodgeAnim();
			case "weekend-1-punchhighspin":
				playSpinAnim();
			case "weekend-1-blockhigh":
				playPunchHighAnim();
			case "weekend-1-blocklow":
				playPunchLowAnim();
			case "weekend-1-blockspin":
				playPunchHighAnim();
			case "weekend-1-dodgehigh":
				playPunchHighAnim();
			case "weekend-1-dodgelow":
				playPunchLowAnim();
			case "weekend-1-dodgespin":
				playPunchHighAnim();
			case "weekend-1-hithigh":
				playPunchHighAnim();
			case "weekend-1-hitlow":
				playPunchLowAnim();
			case "weekend-1-hitspin":
				playPunchHighAnim();
			case "weekend-1-picouppercutprep":
			case "weekend-1-picouppercut":
				playUppercutHitAnim();
			case "weekend-1-darnelluppercutprep":
				playUppercutPrepAnim();
			case "weekend-1-darnelluppercut":
				playUppercutAnim();
			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playCringeAnim();
			case "weekend-1-taunt":
				playPissedConditionalAnim();
			case "weekend-1-tauntforce":
				playPissedAnim();
			case "weekend-1-reversefakeout":
				playFakeoutAnim();
			default:
		}

		cantUppercut = false;
}

function darnellBlazinNoteMiss(note:Note)
{
		if (!StringTools.startsWith(note.noteType, 'weekend-1-')) {
			return;
		}

		if (darnellBlazin.anim.curSymbol.name == 'uppercutPrep') {
			playUppercutAnim();
			return;
		}

		if (willMissBeLethal()) {
			playPunchLowAnim();
			return;
		}

		if (cantUppercut) {
			playPunchHighAnim();
			return;
		}

		switch (note.noteType)
		{
			case "weekend-1-punchlow":
				playPunchLowAnim();
			case "weekend-1-punchlowblocked":
				playPunchLowAnim();
			case "weekend-1-punchlowdodged":
				playPunchLowAnim();
			case "weekend-1-punchlowspin":
				playPunchLowAnim();
			case "weekend-1-punchhigh":
				playPunchHighAnim();
			case "weekend-1-punchhighblocked":
				playPunchHighAnim();
			case "weekend-1-punchhighdodged":
				playPunchHighAnim();
			case "weekend-1-punchhighspin":
				playPunchHighAnim();
			case "weekend-1-blockhigh":
				playPunchHighAnim();
			case "weekend-1-blocklow":
				playPunchLowAnim();
			case "weekend-1-blockspin":
				playPunchHighAnim();
			case "weekend-1-dodgehigh":
				playPunchHighAnim();
			case "weekend-1-dodgelow":
				playPunchLowAnim();
			case "weekend-1-dodgespin":
				playPunchHighAnim();
			case "weekend-1-hithigh":
				playPunchHighAnim();
			case "weekend-1-hitlow":
				playPunchLowAnim();
			case "weekend-1-hitspin":
				playPunchHighAnim();
			case "weekend-1-picouppercutprep":
				playHitHighAnim();
				cantUppercut = true;
			case "weekend-1-picouppercut":
				playDodgeAnim();
			case "weekend-1-darnelluppercutprep":
				playUppercutPrepAnim();
			case "weekend-1-darnelluppercut":
				playUppercutAnim();
			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playCringeAnim();
			case "weekend-1-taunt":
				playPissedConditionalAnim();
			case "weekend-1-tauntforce":
			case "weekend-1-reversefakeout":
				playFakeoutAnim();
			default:
		}

		cantUppercut = false;
}

	var cantUppercut2 = false;

function picoBlazinNoteHit(note:Note)
{
		if (!StringTools.startsWith(note.noteType, 'weekend-1-')) return;

		var shouldDoUppercutPrep = wasNoteHitPoorly(note) && isPlayerLowHealth() && isDarnellPreppingUppercut();

		if (shouldDoUppercutPrep) {
			playPunchHighAnim2();
			return;
		}

		if (cantUppercut2) {
			playBlockAnim2();
			cantUppercut2 = false;
			return;
		}

		switch (note.noteType)
		{
			case "weekend-1-punchlow":
				playPunchLowAnim2();
			case "weekend-1-punchlowblocked":
				playPunchLowAnim2();
			case "weekend-1-punchlowdodged":
				playPunchLowAnim2();
			case "weekend-1-punchlowspin":
				playPunchLowAnim2();
			case "weekend-1-punchhigh":
				playPunchHighAnim2();
			case "weekend-1-punchhighblocked":
				playPunchHighAnim2();
			case "weekend-1-punchhighdodged":
				playPunchHighAnim2();
			case "weekend-1-punchhighspin":
				playPunchHighAnim2();
			case "weekend-1-blockhigh":
				playBlockAnim2();
			case "weekend-1-blocklow":
				playBlockAnim2();
			case "weekend-1-blockspin":
				playBlockAnim2();
			case "weekend-1-dodgehigh":
				playDodgeAnim2();
			case "weekend-1-dodgelow":
				playDodgeAnim2();
			case "weekend-1-dodgespin":
				playDodgeAnim2();
			case "weekend-1-hithigh":
				playHitHighAnim2();
			case "weekend-1-hitlow":
				playHitLowAnim2();
			case "weekend-1-hitspin":
				playHitSpinAnim2();
			case "weekend-1-picouppercutprep":
				playUppercutPrepAnim2();
			case "weekend-1-picouppercut":
				playUppercutAnim2(true);
			case "weekend-1-darnelluppercutprep":
				playIdleAnim2();
			case "weekend-1-darnelluppercut":
				playUppercutHitAnim2();
			case "weekend-1-idle":
				playIdleAnim2();
			case "weekend-1-fakeout":
				playFakeoutAnim2();
			case "weekend-1-taunt":
				playTauntConditionalAnim2();
			case "weekend-1-tauntforce":
				playTauntAnim2();
			case "weekend-1-reversefakeout":
				playIdleAnim2();
			default:
		}
}

function picoBlazinNoteMiss(note:Note)
{
		if (isDarnellInUppercut()) {
			playUppercutHitAnim2();
			return;
		}

		if (willMissBeLethal()) {
			playHitLowAnim2();
			return;
		}

		if (cantUppercut2) {
			playHitHighAnim2();
			return;
		}

		switch (note.noteType)
		{
			case "weekend-1-punchlow":
				playHitLowAnim2();
			case "weekend-1-punchlowblocked":
				playHitLowAnim2();
			case "weekend-1-punchlowdodged":
				playHitLowAnim2();
			case "weekend-1-punchlowspin":
				playHitSpinAnim2();
			case "weekend-1-punchhigh":
				playHitHighAnim2();
			case "weekend-1-punchhighblocked":
				playHitHighAnim2();
			case "weekend-1-punchhighdodged":
				playHitHighAnim2();
			case "weekend-1-punchhighspin":
				playHitSpinAnim2();
			case "weekend-1-blockhigh":
				playHitHighAnim2();
			case "weekend-1-blocklow":
				playHitLowAnim2();
			case "weekend-1-blockspin":
				playHitSpinAnim2();
			case "weekend-1-dodgehigh":
				playHitHighAnim2();
			case "weekend-1-dodgelow":
				playHitLowAnim2();
			case "weekend-1-dodgespin":
				playHitSpinAnim2();
			case "weekend-1-hithigh":
				playHitHighAnim2();
			case "weekend-1-hitlow":
				playHitLowAnim2();
			case "weekend-1-hitspin":
				playHitSpinAnim2();
			case "weekend-1-picouppercutprep":
				playPunchHighAnim2();
				cantUppercut2 = true;
			case "weekend-1-picouppercut":
				playUppercutAnim2(false);
			case "weekend-1-darnelluppercutprep":
				playIdleAnim2();
			case "weekend-1-darnelluppercut":
				playUppercutHitAnim2();
			case "weekend-1-idle":
				playIdleAnim2();
			case "weekend-1-fakeout":
				playHitHighAnim2();
			case "weekend-1-taunt":
				playTauntConditionalAnim2();
			case "weekend-1-tauntforce":
				playTauntAnim2();
			case "weekend-1-reversefakeout":
				playIdleAnim2();
 			default:
		}
}

	function isDarnellInUppercut():Bool {
		return darnellBlazin.anim.curSymbol.name == 'uppercut' || darnellBlazin.anim.curSymbol.name == 'uppercut-hold';
	}

	function isDarnellPreppingUppercut():Bool {
		return darnellBlazin.anim.curSymbol.name == 'uppercutPrep';
	}

	function wasNoteHitPoorly(note):Bool {
		return (note.rating == "shit");
	}

	function isPlayerLowHealth():Bool {
		return health <= 0.30 * 2.0;
	}

	function willMissBeLethal(healthChange:Float = 0.04):Bool {
		return (health + healthChange) <= 0.0;
	}

	function hideOpponentStrumline()
	{
		var opponentStrumline = strumLineNotes;
		if (opponentStrumline != null)
		{
			strumLineNotes.members[0].visible = false;
			strumLineNotes.members[1].visible = false;
			strumLineNotes.members[2].visible = false;
			strumLineNotes.members[3].visible = false;
		}
	}

	function centerPlayerStrumline()
	{
		var playerStrumline = playerStrums;
		if (playerStrumline != null)
		{
			playerStrumline.members[0].x = Note.swagWidth * 0;
			playerStrumline.members[1].x = Note.swagWidth * 1;
			playerStrumline.members[2].x = Note.swagWidth * 2;
			playerStrumline.members[3].x = Note.swagWidth * 3;
			playerStrums.x = 416;
		}
	}

	function startCutscene(){
		camHUD.visible = false;

		hasPlayedCutscene = true;

		boyfriend.debugMode = true;
		dad.debugMode = true;

		bgSprite = new FlxSprite(0, 0).makeGraphic(2000, 2500, 0xFF000000);
		bgSprite.cameras = [camCutscene];
		add(bgSprite);
		bgSprite.alpha = 0.00000001;

		startVideo2();
	}

	function endCutscene(){
		isCameraOnForcedPos = true;
		camZooming = false;
		new FlxTimer().start(1, function(tmr)
		{
			FlxTween.tween(camFollow, {x: 1539, y: 833.5}, 2, {ease: FlxEase.quadInOut});
			var targetZoom = 0.69 * FlxCamera.defaultZoom;
			FlxTween.tween(FlxG.camera, {zoom: targetZoom}, 2, {ease: FlxEase.quadInOut});
		});

		new FlxTimer().start(2, function(tmr)
		{
			boyfriend.canPlayOtherAnims = true;
			boyfriend.playAnim('intro1', true);
			boyfriend.canPlayOtherAnims = false;
		});
		new FlxTimer().start(2.5, function(tmr)
		{
			dad.canPlayOtherAnims = true;
			dad.playAnim('pissed', true);
			dad.canPlayOtherAnims = false;
		});

		new FlxTimer().start(6, function(tmr)
		{
			trace('Pausing ending to play a video cutscene (`2hot`)');

			bgSprite.alpha = 1;
			video.alpha = 1;
		});
	}

  public static inline function byZIndex(order:Int, a:FlxAnimate, b:FlxAnimate):Int
  {
    if (a == null || b == null) return 0;
    return FlxSort.byValues(order, a.zIndex, b.zIndex);
  }
}
