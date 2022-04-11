package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import purgatory.PurMainMenuState;

using StringTools;

class ExtrasMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1 Dave'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if desktop 'discord' #end
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	public static var firstStart:Bool = true;

	public static var finishedFunnyMove:Bool = false;

	public static var bgPaths:Array<String> = 
	[
		'backgrounds/SUSSUS AMOGUS',
		'backgrounds/SwagnotrllyTheMod',
		'backgrounds/Olyantwo',
		'backgrounds/morie',
		'backgrounds/mantis',
		'backgrounds/mamakotomi',
		'backgrounds/T5mpler'
	];

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.1 - (0.03 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(randomizeBG());
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.color = 0xFFfd719b;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(bg.graphic);
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFFDE871;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...optionShit.length)
			{
				var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
				menuItem.scale.x = scale;
				menuItem.scale.y = scale;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.x = -200;
				menuItems.add(menuItem);
				menuItem.scrollFactor.set();
				menuItem.antialiasing = ClientPrefs.globalAntialiasing;
				if (firstStart)
					FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
						{ 
							finishedFunnyMove = true; 
							changeItem();
						}});
				else
					menuItem.y = 60 + (i * 160);
			}

		firstStart = false;

		FlxG.camera.follow(camFollowPos, null, 1);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK && MainMenuState.sexo3)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			else if (controls.BACK && PurMainMenuState.sexo4)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new PurMainMenuState());
			}

			if (controls.ACCEPT)
				{
					if (optionShit[curSelected] == 'discord')
					{
						if (MainMenuState.sexo3) {
				    		CoolUtil.browserLoad('https://discord.gg/vsdave'); //vs dave discord
						} 
						else if (PurMainMenuState.sexo4) { // ELSE IF MY NUT MY NUTS MY N
							CoolUtil.browserLoad('https://discord.gg/tGvCrQPpsR'); //bp discord
						}
					} 
					else
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						
						if(ClientPrefs.flashing)
							FlxFlicker.flicker(magenta, 1.1, 0.15, false);
	
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 1.3, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
							else
							{
								if(ClientPrefs.flashing)
								{
									FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
									{
										goToState();
									});
								}
								else
								{
									new FlxTimer().start(1, function(tmr:FlxTimer)
									{
										goToState();
									});
								}
							}
						});
					}
				}
			}
			#if desktop
			if (FlxG.keys.justPressed.SEVEN)
			{
			  selectedSomethin = true;
			  MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
	
			super.update(elapsed);
	
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.screenCenter(X);
			});
		}
	function goToState()
		{
			var daChoice:String = optionShit[curSelected];
	
			switch (daChoice)
			{
				case 'credits':
					MusicBeatState.switchState(new CreditsState());
				case 'awards':
					MusicBeatState.switchState(new AchievementsMenuState());
				#if MODS_ALLOWED
				case 'mods':
					MusicBeatState.switchState(new ModsMenuState());
				#end
			}
		}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
	public static function randomizeBG():flixel.system.FlxAssets.FlxGraphicAsset
	{
		var chance:Int = FlxG.random.int(0, bgPaths.length - 1);
		return Paths.image(bgPaths[chance]);
	}
}
