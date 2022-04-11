package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
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
import purgatory.PurTitleState;
import trolling.SusState;
import trolling.CheaterState;
import trolling.YouCheatedSomeoneIsComing;
import trolling.CrasherState;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var randomNumber:Int;
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFF0F5FFF);
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var Timer:Float = 0;

	var fun:Int;

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = false; //Disable this to hide the easter egg
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

		curWacky = FlxG.random.getObject(getIntroTextShit());

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

		trace(FlxG.save.data.unlockedCharacters);
		if(FlxG.save.data.unlockedCharacters == null)
            {
				FlxG.save.data.unlockedCharacters = ["Boyfriend"];//does something idk lol
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
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var arrowshit:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			FlxG.camera.zoom = 1.5;
			FlxG.camera.angle = 30;

			FlxTween.tween(FlxG.camera, {zoom:1}, 0.95, {ease: FlxEase.quadOut});
			FlxTween.tween(FlxG.camera, {angle:0}, 0.95, {ease: FlxEase.quadOut});
			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			// this thing is for the vertical transition but idk how to implement it into the customfadetransition file
			/*	var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;
			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(-1, 0), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.42, FlxG.height * 4.2));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(1, 0),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.42, FlxG.height * 4.2));
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/ // vertical transition needs fix lol

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			randomNumber = FlxG.random.int(0, 100);
			if(randomNumber == 100)
			{
				FlxG.sound.playMusic(Paths.music('unFreakyMenu'), 0, true);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			}
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(275);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		swagShader = new ColorSwap();
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

		logoBl = new FlxSprite(-1100, -25);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);
		//logoBl.shader = swagShader.shader;

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		arrowshit = new FlxSprite(-80).loadGraphic(Paths.image('stupidarrows'));
		arrowshit.setGraphicSize(Std.int(arrowshit.width * 1));
		arrowshit.updateHitbox();
		arrowshit.screenCenter();
		arrowshit.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		Timer += 1;
		gradientBar.scale.y += Math.sin(Timer / 10) * 0.001;
		gradientBar.updateHitbox();
		gradientBar.y = FlxG.height - gradientBar.height;
		// gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), Math.round(gradientBar.height), [0x00ff0000, 0xaaAE59E4, 0xff19ECFF], 1, 90, true);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

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
					MusicBeatState.switchState(new WarningState());
					closedState = true;
					MainMenuState.sexo3 = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			if(pressLeftNright)
				{
					if(ClientPrefs.flashing) { FlxG.camera.flash(FlxColor.WHITE, 1, null, true); }
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
	
					FlxTween.tween(FlxG.camera, {y: FlxG.height}, 1.2, {ease: FlxEase.expoIn, startDelay: 0.4});
	
					transitioning = true;
					// FlxG.sound.music.stop();
	
					MainMenuState.firstStart = true;
					MainMenuState.finishedFunnyMove = false;
		
					MainMenuState.firstStart = true;
	
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						MusicBeatState.switchState(new PurTitleState());
						closedState = true;
						MainMenuState.sexo3 = false;
					});
					FlxG.sound.music.stop();
				}
		}

		if (pressedEnter || pressLeftNright && !skippedIntro)
		{
			skipIntro();
		}

		if (doTheFunny) {
	    	FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
		{
			for (i in 0...textArray.length)
			{
				var money:FlxText = new FlxText(0, 0, FlxG.width, textArray[i], 48);
				money.setFormat("Comic Sans MS Bold", 48, FlxColor.WHITE, CENTER);
				money.screenCenter(X);
				money.y += (i * 60) + 200 + offset;
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	
		function addMoreText(text:String, ?offset:Float = 0)
		{
			var coolText:FlxText = new FlxText(0, 0, FlxG.width, text, 48);
			coolText.setFormat("Comic Sans MS Bold", 48, FlxColor.WHITE, CENTER);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(doTheFunny) { 
	    	FlxG.camera.zoom += 0.03;
		}

		if(logoBl != null) 
			logoBl.animation.play('bump');

		if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			switch (curBeat)
			{
				case 1:
					createCoolText([' ']);
						//createCoolText(['Psych Engine by']);
					// credTextShit.visible = true;
				case 2:
					createCoolText([' '], 45);
				// credTextShit.visible = true;
				case 3:
					addMoreText('Psych Engine by\nShadow Mario\nRiverOaken\nbb-panzu', 45);
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['A fan tweak and mod of\nThis mod down below'], -60);
					logoSpr.visible = true;
				case 7:
					deleteCoolText();
					logoSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				//createCoolText(['MoldyGH', 'Rapparep', 'Krisspo', 'TheBuilderXD']);
			// credTextShit.visible = true;
			case 8:
				createCoolText(['VS Dave & Bambi by'], -60);
			case 9:
				addMoreText('MoldyGH, MissingTextureMan101', -60);
			case 10:
				addMoreText('rapparep lol, TheBuilderXD', -60);
			case 11:
				addMoreText('T5mpler, Erizur, Billy Bobbo', -60);
			case 12:
				addMoreText('Cuszie, Marcello_TIMEnice30', -60);
			case 13:
				deleteCoolText();
			case 14:
				createCoolText(['VS D&B Definitive Edition', "And Bambi's Purgatory", 'by']);
			case 15:
				addMoreText('WhatsDown, ztgds, MijaeLio, Voidsslime\nEpicRandomness11, Pyramix, Aadsta,\nReginald Reborn, BombasticHype, BezieAnims');
			case 16:
				deleteCoolText();
			case 17:
				createCoolText(['And Special thanks to our contributors']);
			case 18:
				addMoreText('NewReal, Cynda, Grantare, Lancey, rapparep lol\nBilly Bobbo, TheBuilder, and More!');
			case 19:
				deleteCoolText();
			case 20:
				addMoreText('Supernovae by ArchWk');
			case 21:
				addMoreText('Glitch by DeadShadow PixelGH');
			case 22:
				deleteCoolText();
			case 23:
				createCoolText([curWacky[0]]);
			case 24:
				addMoreText(curWacky[1]);
			case 25:
				deleteCoolText();
			case 26:
				addMoreText('VS Dave');
			case 27:
				addMoreText('& Bambi');
			case 28:
				addMoreText('Definitive Edition\n+ Bambis Purgatory'); 
			case 29:
				skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			Conductor.changeBPM(150);

			remove(logoSpr);

			doTheFunny = true;

			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00, 0x553D0468, 0xAA0F5FFF], 1, 90, true);
	    	gradientBar.y = FlxG.height - gradientBar.height;
	     	gradientBar.scale.y = 0;
	    	gradientBar.updateHitbox();
	    	add(gradientBar);
	     	FlxTween.tween(gradientBar, {'scale.y': 1.3}, 4, {ease: FlxEase.quadInOut});

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

			FlxTween.tween(logoBl,{x: 15}, 1.4, {ease: FlxEase.expoInOut});

			logoBl.angle = -7;
			if(logoBl.angle == -7) 
			FlxTween.angle(logoBl, logoBl.angle, 7, 7, {ease: FlxEase.quartInOut});
			if (logoBl.angle == 7) 
			FlxTween.angle(logoBl, logoBl.angle, -7, 7, {ease: FlxEase.quartInOut});

			if(ClientPrefs.flashing) {FlxG.camera.flash(FlxColor.WHITE, 4); }
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
