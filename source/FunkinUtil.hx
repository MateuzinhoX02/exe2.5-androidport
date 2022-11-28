package;

import flixel.FlxG;
import lime.system.System;
import lime.utils.Assets;
import PlayState;
import flash.system.System;
import flixel.input.touch.FlxTouch;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.CallStack;
import flixel.FlxG;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;
import extension.webview.WebView;

using StringTools;

class FunkinUtil
{
   public static var path:String = System.applicationStorageDirectory; 
   // credits: fnf loading state
   public static var target:FlxState;

   public static function playVideo(videoName:String, videoPath:String, target:FlxState) 
   {
   videopath = "assets/videos/" + videoName;
   FlxG.switchState(new DaVideoHandler(videoPath), target);  
   }

   public static function cutsceneStart()
   {
   FlxG.switchState(new DaVideoHandler(videopath));
   DaVideoHandler.finishCallback = function() {
   FlxG.switchState(target);
   }
   }

   public static function spriteCache(sprite:FlxSprite, spriteName:String)
   {
   sprite = new FlxSprite(-1800, -4097).loadGraphic(SpriteName); // I dont know, i just write some random coordenates in that code.
   add(sprite);
   remove(sprite);
   }

   public static function traceLog(msg:String) 
   {
   Application.current.window.alert(msg);
   }

   public static function doSongPrecache()
   {
   FlxG.sound.cache(Paths.inst(PlayState.SONG.song));
   FlxG.sound.cache(Paths.voices(PlayState.SONG.song));
   }

   public static function dumpCache() // Stoled from kade engine :)
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null)
			{
			    Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}
		Paths.localTrackedAssets = [];
		Paths.currentTrackedAssets = [];
		Assets.cache.clear("songs");
		Assets.cache.clear("shared");
		Assets.cache.clear("preload");
	}

    public static function absolutePath(create:String, folderpath:String)
    {
    create = path + folderpath;
    return Assets.getPath(create); 
    }

    // Stoled of Musk-h (in Github), sorry, i dont have a brain.
    public static function justTouched():Bool
	{
		var justTouched:Bool = false;

		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				justTouched = true;
		}

		#if mobile
 		return justTouched;
		#else
 		return false;
		#end
	}

    public static function androidBack():Bool
	{
		#if mobile
 		return FlxG.android.justReleased.BACK;
		#else
 		return false;
		#end
	}

    public static function crashHandler()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent)
		{
			var errMsg:String = "";
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var dateNow:String = Date.now().toString();

			dateNow = StringTools.replace(dateNow, " ", "_");
			dateNow = StringTools.replace(dateNow, ":", "'");

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += file + " (line " + line + ")\n";
					default:
						errMsg += stackItem;
				}
			}

			errMsg += '\nUncaught Error: ' + e.error;

			Lib.application.window.alert(errMsg, 'Crash!');
			System.exit(1);
		});
	}

     public static function readDirectory(path:String):Array<String>
	{
        var baseDirectory:Array<String> = [];
        var finalDirectory:Array<String> = [];

        for (trim in Assets.list())
        {
            if (trim.contains(path))
            {
                var cut:String = '';
                if (!path.endsWith('/'))
                    cut = '/';
                var folder:String = trim.replace(path + cut, '');
                baseDirectory.push(folder);
            }
        }

        for (file in baseDirectory)
        {
            var okay:Array<String> = file.split('/');
            if (okay[0].endsWith('assets') && okay.length > 1)
                okay[0] = null;
            if (!finalDirectory.contains(okay[0]))
                finalDirectory.push(okay[0]);
        }

        finalDirectory.sort(function(a:String, b:String):Int 
        {
            a = a.toUpperCase();
            b = b.toUpperCase();

            if (a < b)
                return -1;
            else if (a > b)
                return 1;
            else
                return 0;
        });

        return finalDirectory;
    }

    public static function exists(path:String):Bool
	{
		return Assets.exists(path);
	}

    public static function getContent(path:String):String
    {
        return Assets.getText(path);
    }

    class DaVideoHandler
    {
	public static var androidPath:String = 'file:///android_asset/';

	public function new(source:String, toTrans:FlxState)
	{
		super();

		//FlxG.autoPause = false;

		WebView.onClose=onClose;
		WebView.onURLChanging=onURLChanging;

		WebView.open(androidPath + videoPath + '.html', false, null, ['http://exitme(.*)']);
	}

	public override function update(dt:Float) {
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				onClose();

		super.update(dt);	
	}

	function onClose(){// not working
		text.alpha = 0;
		//FlxG.autoPause = true;
		trace('close!');
		trace(target);
		FlxG.switchState(target);
	}

	function onURLChanging(url:String) {
		text.alpha = 1;
		if (url == 'http://exitme/') onClose(); // drity hack lol
	}
}
}