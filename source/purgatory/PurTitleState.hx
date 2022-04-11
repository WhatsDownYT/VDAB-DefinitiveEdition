package purgatory;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import lime.app.Application;
import openfl.Assets;
import trolling.SusState;
import trolling.CheaterState;
import trolling.YouCheatedSomeoneIsComing;
import trolling.CrasherState;
import TitleState;

using StringTools;

class PurTitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var logoSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var Timer:Float = 0;

	var fun:Int;

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = true; //Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.B, FlxKey.B]; //bb stands for bbpanzu cuz he wanted this lmao
	var lastKeysPressed:Array<FlxKey> = [];

	private var doTheFunny:Bool = false;

	override public function create():Void
	{
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}

		fun = FlxG.random.int(0, 999);
		if(fun == 1)
		{
			LoadingState.loadAndSwitchState(new SusState());
		}

		//Gonna finish this later, probably
		#end
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				purgatoryIntro();
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var slidething:FlxBackdrop;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var arrowshit:FlxSprite;
	var swagShader:ColorSwap = null;

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		Timer += 1;

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		var pressLeftNright:Bool = FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT #if android || _virtualpad.buttonC.justPressed #end;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.Y)
				pressLeftNright = true;

			#if switch
			if (gamepad.justPressed.Y)
				pressLeftNright = true;
			#end
		}

		if (!transitioning && skippedIntro)
		{
			if (pressLeftNright)
				{
					if(ClientPrefs.flashing) { FlxG.camera.flash(FlxColor.WHITE, 1, null, true); }
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
	
					FlxTween.tween(FlxG.camera, {y: -900}, 1.2, {ease: FlxEase.expoIn, startDelay: 0.4});
	
					transitioning = true;
					// FlxG.sound.music.stop();
	
					MainMenuState.firstStart = true;
					MainMenuState.finishedFunnyMove = false;
		
					MainMenuState.firstStart = true;
	
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						MusicBeatState.switchState(new TitleState());
						closedState = true;
						PurMainMenuState.sexo4 = false;
					});
				}

			if(pressedEnter)
			{
				if(titleText != null) titleText.animation.play('press');

				if(ClientPrefs.flashing) { FlxG.camera.flash(FlxColor.WHITE, 1, null, true); }
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				MainMenuState.firstStart = true;
				MainMenuState.finishedFunnyMove = false;
	
				MainMenuState.firstStart = true;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new PurWarningState());
					closedState = true;
					PurMainMenuState.sexo4 = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (pressedEnter && !skippedIntro)
		{
			purgatoryIntro();
		}

		if (doTheFunny) {
	    	FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		super.update(elapsed);
	}

	private static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(doTheFunny) { 
	    	FlxG.camera.zoom += 0.03;
		}

		if(logoBl != null) 
			logoBl.animation.play('bump');

		if(!closedState) 
		{
            purgatoryIntro();
		}
	}

	var skippedIntro:Bool = false;

	function purgatoryIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.sound.playMusic(Paths.music('purFreakyMenu'), 0.7, true);

			Conductor.changeBPM(90);
			persistentUpdate = true;

			doTheFunny = true;

			var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('purgatorytitle'));
			bg.setGraphicSize(Std.int(bg.width * 1.175));
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
	
			slidething = new FlxBackdrop(Paths.image('hahaslider'),1,0,true,false);
			slidething.velocity.set(-14,0);
			slidething.x = -20;
			slidething.y = 209;
			slidething.setGraphicSize(Std.int(slidething.width * 0.65));
			add(slidething); // i borrowed this from tricky hhehehehehe

			logoBl = new FlxSprite(245, -25);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBl.antialiasing = ClientPrefs.globalAntialiasing;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
			logoBl.updateHitbox();
			add(logoBl);
	
			arrowshit = new FlxSprite(-80).loadGraphic(Paths.image('stupidarrows'));
			arrowshit.setGraphicSize(Std.int(arrowshit.width * 1));
			arrowshit.updateHitbox();
			arrowshit.screenCenter();
			arrowshit.antialiasing = ClientPrefs.globalAntialiasing;

			var gr:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('purgatorygrad'));
			gr.setGraphicSize(Std.int(gr.width * 1.175));
			gr.updateHitbox();
			gr.screenCenter();
			gr.antialiasing = ClientPrefs.globalAntialiasing;
			add(gr);

			add(arrowshit);

			titleText = new FlxSprite(100, FlxG.height * 0.8);
			titleText.frames = Paths.getSparrowAtlas('titleEnter');
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			if(ClientPrefs.flashing) { titleText.animation.addByPrefix('press', "ENTER PRESSED", 24); }
			titleText.antialiasing = ClientPrefs.globalAntialiasing;
			titleText.animation.play('idle');
			titleText.updateHitbox();
		    // titleText.screenCenter(X);
			add(titleText);

			if(ClientPrefs.flashing) {FlxG.camera.flash(FlxColor.WHITE, 4); }
			skippedIntro = true;

		}
	}
}
