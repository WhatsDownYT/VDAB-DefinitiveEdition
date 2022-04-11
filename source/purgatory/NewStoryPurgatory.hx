package purgatory;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import flixel.group.FlxSpriteGroup;
import openfl.Lib;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import purgatory.PurMainMenuState;
import purgatory.PurWeekData;

class NewStoryPurgatory extends MusicBeatState
{
	var bg:FlxSprite;
	var week1:FlxSprite;
	var o:FlxSprite;
	var lol:Bool = false;
	var sex:FlxSprite;
	var canExit:Bool = true;
	var week1text:FlxText;
	var week2text:FlxText;
	var week2:FlxSprite;
	var week3:FlxSprite;
	var week3text:FlxText;
	var arrowshit:FlxSprite;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var text:FlxText;

	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Purgatory Menu", null);
		#end

		#if android
		addVirtualPad(FULL, A_B_X_Y);
		addPadCamera();
		#end
		
		super.create();

		FlxG.mouse.visible = true;
		
		bg = new FlxSprite(-80).loadGraphic(Paths.image('backgrounds/purgatory/osp'));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFF738BFF;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		week1 = new FlxSprite(100, 70).loadGraphic(Paths.image('purgatoryweeks/story'));
		week1.scale.set(0.8, 0.8);
		week1.updateHitbox();
		week1.antialiasing = ClientPrefs.globalAntialiasing;
		menuItems.add(week1);
		
		week1text = new FlxText(80, 480, 320, "Rage\n" + "Week\n");
		week1text.setFormat(Paths.font("comic-sans.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		week1text.scrollFactor.set();
		week1text.borderSize = 3.25;
		week1text.visible = true;
		menuItems.add(week1text);
		
		week2 = new FlxSprite(500, 70).loadGraphic(Paths.image('purgatoryweeks/story2'));
		week2.scale.set(0.8, 0.8);
		week2.updateHitbox();
		week2.antialiasing = ClientPrefs.globalAntialiasing;
		menuItems.add(week2);
		
		week2text = new FlxText(480, 480, 320, "Hell\n" + "Week\n");
		week2text.setFormat(Paths.font("comic-sans.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		week2text.scrollFactor.set();
		week2text.borderSize = 3.25;
		week2text.visible = true;
		menuItems.add(week2text);
		
		week3 = new FlxSprite(900, 70).loadGraphic(Paths.image('purgatoryweeks/story2'));
		week3.scale.set(0.8, 0.8);
		week3.updateHitbox();
		week3.antialiasing = ClientPrefs.globalAntialiasing;
		menuItems.add(week3);
		
		week3text = new FlxText(880, 480, 320, "Dave's\n" + "Rematch\n");
		week3text.setFormat(Paths.font("comic-sans.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		week3text.scrollFactor.set();
		week3text.borderSize = 3.25;
		week3text.visible = true;
		menuItems.add(week3text);
		
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 46).makeGraphic(FlxG.width, 56, 0xFF000000);
		textBG.alpha = 0.6;
		menuItems.add(textBG);
		#if PRELOAD_ALL
		var leText:String = "Use your mouse to select a week.";
		#end
		text = new FlxText(textBG.x + -10, textBG.y + 3, FlxG.width, leText, 21);
		text.setFormat(Paths.font("comic-sans.ttf"), 18, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		menuItems.add(text);
		
		arrowshit = new FlxSprite(-80).loadGraphic(Paths.image('stupidarrows'));
		arrowshit.setGraphicSize(Std.int(arrowshit.width * 1));
		arrowshit.updateHitbox();
		arrowshit.screenCenter();
		arrowshit.antialiasing = ClientPrefs.globalAntialiasing;
		menuItems.add(arrowshit);
		
	}
	  override public function update(elapsed:Float)
	  {
		  
		var clicked = FlxG.mouse.overlaps(week1) && FlxG.mouse.justPressed && !lol;
		
		if (clicked)
		{
			lol = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			startSong('shattered/shattered-hard', 'supplanted', 'reality breaking');	
		}
		  
		if(controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new PurMainMenuState());
				
		}
		
		if (controls.UI_RIGHT_P)
		{
			openSubState(new Section2Substate());
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		super.update(elapsed);
	  }
	  
    function startSong(songName1:String, songName2:String, songName3:String)
    {
	   FlxFlicker.flicker(week1, 1, 0.06, false, false, function(flick:FlxFlicker)
	   {
	    PlayState.storyPlaylist = [songName1, songName2, songName3];
		PlayState.isStoryMode = false;
		PlayState.isFreeplay = false;
		PlayState.isFreeplayPur = false;
		PlayState.isPurStoryMode = true;
	    PlayState.storyWeek = 2;
	    PlayState.storyDifficulty = 2;
	    PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], '');
	    PlayState.campaignScore = 0;
	    PlayState.campaignMisses = 0;
	    FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
	    FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
	    FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
	    menuItems.forEach(function(spr:FlxSprite) {
	    FlxTween.tween(spr, {alpha: 0}, 0.4, {
	  	    ease: FlxEase.quadOut,
		    onComplete: function(twn:FlxTween)
		    {
		  	    spr.kill();
		    }
	      });
       });
	    new FlxTimer().start(1, function(tmr:FlxTimer)
	    {
		    LoadingState.loadAndSwitchState(new PlayState());
	    });
	   });
	}

	function weekIsLocked(weekNum:Int) {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
}


class Section2Substate extends MusicBeatSubstate
{
	
	var arrowshitSub:FlxSprite;
	var menuItemsSub:FlxTypedGroup<FlxSprite>;
	var bgSub:FlxSprite;
	var textSub:FlxText;
	var week4:FlxSprite;
	var week5:FlxSprite;
	var week4text:FlxText;
	var week5text:FlxText;
	var week6:FlxSprite;
	var week6text:FlxText;

	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	
	public function new() {
		super();
		
		bgSub = new FlxSprite(-80).loadGraphic(Paths.image('backgrounds/purgatory/osp'));
		bgSub.scrollFactor.set();
		bgSub.updateHitbox();
		bgSub.screenCenter();
		bgSub.color = 0xFF738BFF;
		bgSub.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgSub);
		
		menuItemsSub = new FlxTypedGroup<FlxSprite>();
		add(menuItemsSub);
		
		week4 = new FlxSprite(100, 70).loadGraphic(Paths.image('purgatoryweeks/story2'));
		week4.scale.set(0.8, 0.8);
		week4.updateHitbox();
		week4.antialiasing = ClientPrefs.globalAntialiasing;
		menuItemsSub.add(week4);
		
		week4text = new FlxText(80, 480, 320, "Coming\n" + "Soon\n");
		week4text.setFormat(Paths.font("comic-sans.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		week4text.scrollFactor.set();
		week4text.borderSize = 3.25;
		week4text.visible = true;
		menuItemsSub.add(week4text);
		
		week5 = new FlxSprite(500, 70).loadGraphic(Paths.image('purgatoryweeks/story2'));
		week5.scale.set(0.8, 0.8);
		week5.updateHitbox();
		week5.antialiasing = ClientPrefs.globalAntialiasing;
		menuItemsSub.add(week5);
		
		week5text = new FlxText(480, 480, 320, "Coming\n" + "Soon\n");
		week5text.setFormat(Paths.font("comic-sans.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		week5text.scrollFactor.set();
		week5text.borderSize = 3.25;
		week5text.visible = true;
		menuItemsSub.add(week5text);
		
		week6 = new FlxSprite(900, 70).loadGraphic(Paths.image('purgatoryweeks/story2'));
		week6.scale.set(0.8, 0.8);
		week6.updateHitbox();
		week6.antialiasing = ClientPrefs.globalAntialiasing;
		menuItemsSub.add(week6);
		
		week6text = new FlxText(880, 480, 320, "Coming\n" + "Soon\n");
		week6text.setFormat(Paths.font("comic-sans.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		week6text.scrollFactor.set();
		week6text.borderSize = 3.25;
		week6text.visible = true;
		menuItemsSub.add(week6text);
		
		var textBGSub:FlxSprite = new FlxSprite(0, FlxG.height - 46).makeGraphic(FlxG.width, 56, 0xFF000000);
		textBGSub.alpha = 0.6;
		menuItemsSub.add(textBGSub);
		
		arrowshitSub = new FlxSprite(-80).loadGraphic(Paths.image('stupidarrows'));
		arrowshitSub.setGraphicSize(Std.int(arrowshitSub.width * 1));
		arrowshitSub.updateHitbox();
		arrowshitSub.screenCenter();
		arrowshitSub.antialiasing = ClientPrefs.globalAntialiasing;
		menuItemsSub.add(arrowshitSub);
	}
	
	override function update(elapsed:Float)
	{
		if (controls.UI_LEFT_P)
		{
			close();
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		if(controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new PurMainMenuState());
				
		}
		
		super.update(elapsed);
	}

	function weekIsLocked(weekNum:Int) {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
}
