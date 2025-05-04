package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import openfl.Lib;
import openfl.display3D.textures.Texture;
import openfl.system.System;
import flxanimate.FlxAnimate;
#if js
import js.html.File;
import js.html.FileSystem;
#else
import sys.io.File;
import sys.FileSystem;
#end

class Paths
{
	public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static var localTrackedAssets:Array<String> = [];

	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					var isTexture:Bool = currentTrackedTextures.exists(key);
					if (isTexture)
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}
					OpenFlAssets.cache.removeBitmapData(key);
					OpenFlAssets.cache.clearBitmapData(key);
					OpenFlAssets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}

		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedSounds.get(key);
				if (obj != null)
				{
					OpenFlAssets.cache.removeSound(key);
					OpenFlAssets.cache.clearSounds(key);
					OpenFlAssets.cache.clear(key);
					currentTrackedSounds.remove(key);
				}
			}
		}
		System.gc();
		#if cpp
		cpp.NativeGc.run(true);
		#end
	}

	public static function clearStoredMemory()
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				OpenFlAssets.cache.removeBitmapData(key);
				OpenFlAssets.cache.clearBitmapData(key);
				OpenFlAssets.cache.clear(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		@:privateAccess
		for (key in OpenFlAssets.cache.getSoundKeys())
		{
			if (key != null && !currentTrackedSounds.exists(key))
			{
				var obj = OpenFlAssets.cache.getSound(key);
				if (obj != null)
				{
					OpenFlAssets.cache.removeSound(key);
					OpenFlAssets.cache.clearSounds(key);
					OpenFlAssets.cache.clear(key);
				}
			}
		}

		localTrackedAssets = [];
	}

	public static function cacheBitmap(file:String, ?bitmap:BitmapData = null):FlxGraphic
	{
		if (bitmap == null)
		{
			if (OpenFlAssets.exists(file, BINARY))
				bitmap = OpenFlAssets.getBitmapData(file);

			if (bitmap == null)
				return null;
		}

		localTrackedAssets.push(file);
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		currentTrackedAssets.set(file, newGraphic);
		return newGraphic;
	}

	public static function returnSound(path:String, key:String, ?library:String):Sound
	{
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		if (!currentTrackedSounds.exists(gottenPath))
		{
			var folder:String = '';
			if (path == 'songs')
				folder = 'songs:';

			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library == "mobile")
			return getPreloadPath('mobile/$file');

		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	public static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	public static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	static public function lua(key:String,?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.astc', BINARY, library);
	}

	static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	static public function music(key:String, ?library:String)
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	static public function voices(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
	}

	static public function inst(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
	}

	static public function image(key:String, ?library:String):FlxGraphic
	{
		var bitmap:BitmapData = null;
		var file:String = null;

		file = getPath('images/$key.astc', BINARY, library);
		if (currentTrackedAssets.exists(file))
		{
			localTrackedAssets.push(file);
			return currentTrackedAssets.get(file);
		}
		else if (OpenFlAssets.exists(file, BINARY))
			bitmap = OpenFlAssets.getBitmapData(file);

		if (bitmap != null)
		{
			var retVal = cacheBitmap(file, bitmap);
			if (retVal != null)
				return retVal;
		}

		trace('$file image is null');
		return null;
	}

	static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	static public function video(key:String)
	{
		return 'assets/videos/$key.mp4';
	}

	static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	static public function getTextureAtlas(key:String)
	{
		return 'assets/images/$key';
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		var path:String = 'assets/' + key;
		return (OpenFlAssets.exists(path, TEXT)) ? OpenFlAssets.getText(path) : null;
	}

	public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?parentFolder:String = null)
	{
		return (OpenFlAssets.exists(getPath(key, type, parentFolder)));
	}

	public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null)
	{
		var changedAnimJson = false;
		var changedAtlasJson = false;
		var changedImage = false;

			var originalPath:String = folderOrImg;
				animationJson = getTextFromFile('images/$originalPath/Animation.json');
					spriteJson = getTextFromFile('images/$originalPath/spritemap1.json');
					folderOrImg = image('$originalPath/spritemap1');

		spr.loadAtlasEx(folderOrImg, spriteJson, animationJson);
	}

	static public function formatToSongPath(path:String)
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	public static function readDirectory(directory:String):Array<String>
	{
		#if desktop
		return FileSystem.readDirectory(directory);
		#else
		var dirs:Array<String> = [];
		for (dir in OpenFlAssets.list().filter(folder -> folder.startsWith(directory)))
		{
			@:privateAccess
			for (library in lime.utils.Assets.libraries.keys())
			{
				if (library != 'default' && OpenFlAssets.exists('$library:$dir') && (!dirs.contains('$library:$dir') || !dirs.contains(dir)))
					dirs.push('$library:$dir');
				else if (OpenFlAssets.exists(dir) && !dirs.contains(dir))
					dirs.push(dir);
			}
		}
		return dirs.map(dir -> dir.substr(dir.lastIndexOf("/") + 1));
		#end
	}
}
