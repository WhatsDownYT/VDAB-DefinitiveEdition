package;

import CharacterSelectionState.CharacterUnlockObject;
#if desktop
import Discord.DiscordClient;
#end
import flixel.graphics.FlxGraphic;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import Shaders.PulseEffect;
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
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxRandom;
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
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.Shader;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
#if windows
import openfl.filters.ShaderFilter;
#end
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import openfl.events.KeyboardEvent;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import purgatory.PurFreeplayState;
import purgatory.PurWeekData;
import purgatory.NewStoryPurgatory;
import trolling.SusState;
import trolling.CheaterState;
import trolling.YouCheatedSomeoneIsComing;
import trolling.CrasherState;
import Shaders;
import Note.EventNote;

#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;

	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var characteroverride:String = "none";

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1" // your m
	];
	
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	
	public var shader_chromatic_abberation:ChromaticAberrationEffect;
	public var scanline_shader:ScanlineEffect;
	public var grain_shader:GrainEffect;
	public var vcr_shader:VCRDistortionEffect;
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	
	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;
	
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var shaderUpdates:Array<Float->Void> = [];
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var is3DStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var isPurStoryMode:Bool = false;
	public static var isFreeplayPur:Bool = false;
	public static var isFreeplay:Bool = false;
	public static var isModded:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var curbg:FlxSprite;
	public var screenshader:Shaders.PulseEffect = new PulseEffect();
	//public var screenshader:ShadersHandler.ChromaticAberration = new ChromaticAberration();
	public var UsingNewCam:Bool = false;

	//public var sex:Bool = true; //no more sex

	//reality breaking stuff for shaders lol
	var doneloll:Bool = false;
	var doneloll2:Bool = false;
	var stupidInt:Int = 0;
	var stupidBool:Bool = false;
	//ends here

	public var elapsedtime:Float = 0;

	private var swagSpeed:Float;

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	private var badai:Character;
	private var swaggy:Character;
	private var swagBombu:Character;
	public var boyfriend:Boyfriend;
	private var littleIdiot:Character;
	public var stupidThing:Boyfriend;

	private var altSong:SwagSong;

	public var stupidx:Float = 0;
	public var stupidy:Float = 0; // stupid velocities for cutscene
	public var updatevels:Bool = false;

	var isDadGlobal:Bool = true;

	var funnyFloatyBoys:Array<String> = ['dave-3d', 'but-awesome', 'bambi-3d', 'bambi-unfair', 'expunged', 'bambi-piss-3d', 'bambi-scaryooo', 'bambi-god', 'bambi-god2d', 'bambi-hell', 'bombu', 'bombu-expunged', 'badai', 'gary', 'bamburg', 'bamburg-player'];
	var funnyBanduFloaty:Array<String> = ['bandu'];
	var funnySideFloatyBoys:Array<String> = ['bombu', 'bombu-expunged'];
	var canSlide:Bool = true;
	
	var dontDarkenChar:Array<String> = ['bambi-god', 'bambi-god2d'];

	var isNewCam:Array<String> = ['corn-theft', 'maze', 'polygonized', 'splitathon', 'mealie', 'furiosity', 'cheating', 'unfairness', 'pp1', 'pp2', 'pp3', 'pp4', 'pp5', 'pp6', 'pp7', 'pp8', 'old-house', 'old-insanity', 'old-furiosity', 'old-blocked', 'old-corn-theft', 'old-maze', 'beta-maze', 'old-splitathon'];
	// this is for the modded songs to not move the cameras by default if the guy who added it didnt want to do that when using the default vs dave stages 

	var dontMiddle:Array<String> = ['cheating', 'disposition']; // dont middlescroll (this makes the arrows not go offscreen with middlescroll unless u manage to force the game to 999 fps LOL)

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var altNotes:FlxTypedGroup<Note>; 
	private var altUnspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var altStrumLine:FlxSprite;
	private var curSection:Int = 0;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	private var STUPDVARIABLETHATSHOULDNTBENEEDED:FlxSprite;

	public static var eyesoreson = true;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	private var poopStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var charactersSpeed:Int = 2;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var danceBeatSnap:Int = 2;
	public var dadDanceSnap:Int = 2;

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	public var hasBfDarkLevels:Array<String> = ['farmNight', 'houseNight', '3dScary', '3dRed', '3dScary', '3dFucked', 'houseroof'];
	public var hasBfSunsetLevels:Array<String> = ['farmSunset', 'houseSunset'];
	public var hasBfDarkerLevels:Array<String> = ['spooky'];

	private var shakeCam:Bool = false;
	private var shakeCamALT:Bool = false;

	private var fartt:Bool = false;
	private var fartt2:Bool = false;
	private var bALLS:Bool = false;

	private var daspinlmao:Bool = false;
	private var daleftspinlmao:Bool = false;

	private var oppositionMoment:Bool = false;

	private var bfSingYeah:Bool = false;
	private var dadSingYeah:Bool = false;

	private var camZoomSnap:Bool = false;
	private var autoCamZoom:Bool = true;

	public var isNormalStart:Bool = true;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public var badaiTime:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;
	var shartingTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var BAMBICUTSCENEICONHURHURHUR:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var notesHitArray:Array<Date> = [];

	var swagCounter:Int = 0;

	var score:Int = 350;
	var freeplayScore:Int = 350;

	var scoreMultipliersThing:Array<Float> = [1, 1, 1, 1];

	var redSky:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/redsky'));
	var insanityRed:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/redsky_insanity'));
	//var redPlatform:FlxSprite = new FlxSprite(-275, 750).loadGraphic(Paths.image('dave/redPlatform')); // that never happened oops
	var backyardnight:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/backyardnight'));
	var backyard:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/backyard'));
	var poop:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/blank'));
	var soscaryishitmypants:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/ok'));
	var poopBG:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/3dFucked'));
	var blackBG:FlxSprite = new FlxSprite(-120, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
	//var computer:FlxSprite;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	//languages \/
	var esDialogueJson:DialogueFile = null;
	var prDialogueJson:DialogueFile = null;
    //languages End dialog \/
	var esEteSechDialogueJson:DialogueFile = null;
	var prEteSechDialogueJson:DialogueFile = null;

	var eteSechDialogueJson:DialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var evilTrail:FlxTrail; // why the fuck doesnt fnf have this var by default is stupidd dofiodofoidsfo safduikghiuysdarfhiuyfghsdriyughdiuhgulifdshgluifdfhliuylhuiyjgrfd

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite; 
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var whiteflash:FlxSprite;
	var blackScreen:FlxSprite;
	var blackScreendeez:FlxSprite;
	var redGlow:FlxSprite;
	var blammedFunny:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var arrowJunks:Array<Array<Float>> = [];

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var judgementCounter:FlxText;
	var scoreTxtTween:FlxTween;

	var creditsWatermark:FlxText;
	var songWatermark:FlxText;

	var ballsText:FlxText;
	var composersText:FlxText;

	public var redTunnel:FlxSprite;
	public var redBG:FlxSprite;

	public var thing:FlxSprite = new FlxSprite(0, 250);
	public var splitathonExpressionAdded:Bool = false;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var daveExpressionSplitathon:Character;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
    
	public static var theFunne:Bool = true;

	#if windows
	public var crazyBatch:String = "shutdown /r /t 0"; // this isnt actually getting used cuz i dont think gb allows it lmao
    #end

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var camFollowX:Int = 0;
    var camFollowY:Int = 0;
    var dadCamFollowX:Int = 0;
	var dadCamFollowY:Int = 0;

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	var canFloat:Bool = true;

	var swagBG:FlxSprite;

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	override public function create()
	{
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop(); // whats this for idk but it was on psych so yeah

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		if(isFreeplay || isFreeplayPur)
			{
				if(CharacterSelectionState.notBF)
					{
						SONG.player1 = CharacterSelectionState.characterFile;
						scoreMultipliersThing = CharacterSelectionState.scoreMultipliers;
					}
			}
		
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);
		#if windows
		shader_chromatic_abberation = new ChromaticAberrationEffect(0.0075); // i think this one was from psych itself?
		grain_shader = new GrainEffect(0.01, 0.05, true);
		vcr_shader = new VCRDistortionEffect(0.2, true, false, false);
		scanline_shader = new ScanlineEffect(false);
		#end

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		whiteflash = new FlxSprite(-100, -100).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 100), FlxColor.WHITE);
		whiteflash.scrollFactor.set();

		blackScreen = new FlxSprite(-120, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
		blackScreen.scrollFactor.set();

		blackScreendeez = new FlxSprite(-120, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
		blackScreendeez.scrollFactor.set();
		blackScreendeez.alpha = 0;
		add(blackScreendeez);

		redGlow = new FlxSprite(-120, -120).loadGraphic(Paths.image('dave/redGlow'));
		redGlow.scrollFactor.set();
		redGlow.antialiasing = true;
		redGlow.active = true;
		redGlow.screenCenter();
		add(redGlow);
		redGlow.visible = false;

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else if (isStoryMode)
		{
			detailsText = "Purgatory Story Mode: " + PurWeekData.getCurrentWeek().weekName;
		}

		if (isFreeplayPur || isFreeplay)
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;
		trace('hey ur stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				case 'house' | 'insanity' | 'supernovae':
					curStage = 'houseDay';
				case 'old-house' | 'old-insanity':
					curStage = 'houseOlderDay';
				case 'bonus-song' | 'glitch':
					curStage = 'houseNight';
				case 'vs-dave-christmas':
					curStage = 'houseChristmas';
				case 'blocked' | 'corn-theft' | 'old-blocked' | 'old-corn-theft' | 'secret' | 'old-maze':
					curStage = 'farmDay';
				case 'maze' | 'old-maze' | 'beta-maze':
					curStage = 'farmSunset';
				case 'splitathon' | 'old-splitathon' | 'mealie' | 'supplanted' | 'screwed':
					curStage = 'farmNight';
				case 'furiosity' | 'polygonized':
					curStage = '3dRed';
				case 'disposition' | 'disposition_but_awesome':
					curStage = 'bambersHell';
				case 'old-furiosity':
					curStage = 'oldRed';
				case 'cheating' | 'disruption':
					curStage = '3dGreen';
				case 'technology':
					curStage = '3dBombuboi';
				case 'unfairness':
					curStage = '3dScary';
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
				is3DStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,
			
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		is3DStage = stageData.is3DStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];
		
		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);


		switch (curStage)
		{
			case 'houseDay': //Dave Week
			var bg:BGSprite = new BGSprite('dave/sky', -600, -200, 0.2, 0.2);
			add(bg);

			var hills:BGSprite = new BGSprite('dave/hills', -225, -125, 0.5, 0.5);
			hills.setGraphicSize(Std.int(hills.width * 1.25));
			hills.updateHitbox();
			add(hills);

			var gate:BGSprite = new BGSprite('dave/gate', -226, -125, 0.9, 0.9);
			gate.setGraphicSize(Std.int(gate.width * 1.2));
			gate.updateHitbox();
			add(gate);

			var grass:BGSprite = new BGSprite('dave/grass', -225, -125, 0.9, 0.9);
			grass.setGraphicSize(Std.int(grass.width * 1.2));
			grass.updateHitbox();
			add(grass);

			insanityRed.loadGraphic(Paths.image('dave/redsky_insanity'));
			insanityRed.antialiasing = true;
			insanityRed.scrollFactor.set(0.6, 0.6);
			insanityRed.active = true;
			insanityRed.visible = false;
			add(insanityRed);

			if(ClientPrefs.waving)
			{
			var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
			testshader.waveAmplitude = 0.1;
			testshader.waveFrequency = 5;
			testshader.waveSpeed = 2;
			insanityRed.shader = testshader.shader;
			curbg = insanityRed;
			}

			if (isNewCam.contains(SONG.song.toLowerCase())) {
				UsingNewCam = true;
			}

		case 'houseSunset': //Dave Week
			var bg:BGSprite = new BGSprite('dave/sky_sunset', -600, -200, 0.2, 0.2);
			add(bg);

			var hills:BGSprite = new BGSprite('dave/hills', -225, -125, 0.5, 0.5);
			hills.setGraphicSize(Std.int(hills.width * 1.25));
			hills.updateHitbox();
			add(hills);

			var gate:BGSprite = new BGSprite('dave/gate', -226, -125, 0.9, 0.9);
			gate.setGraphicSize(Std.int(gate.width * 1.2));
			gate.updateHitbox();
			add(gate);

			var grass:BGSprite = new BGSprite('dave/grass', -225, -125, 0.9, 0.9);
			grass.setGraphicSize(Std.int(grass.width * 1.2));
			grass.updateHitbox();
			add(grass);

			hills.color = 0xFFFF8FB2;
			gate.color = 0xFFFF8FB2;
			grass.color = 0xFFFF8FB2;

			if (isNewCam.contains(SONG.song.toLowerCase())) {
				UsingNewCam = true;
			}

		case 'houseNight': //Dave Week
			var bg:BGSprite = new BGSprite('dave/sky_night', -600, -200, 0.2, 0.2);
			add(bg);

			var hills:BGSprite = new BGSprite('dave/hills', -225, -125, 0.5, 0.5);
			hills.setGraphicSize(Std.int(hills.width * 1.25));
			hills.updateHitbox();
			add(hills);

			var gate:BGSprite = new BGSprite('dave/gate', -226, -125, 0.9, 0.9);
			gate.setGraphicSize(Std.int(gate.width * 1.2));
			gate.updateHitbox();
			add(gate);

			var grass:BGSprite = new BGSprite('dave/grass', -225, -125, 0.9, 0.9);
			grass.setGraphicSize(Std.int(grass.width * 1.2));
			grass.updateHitbox();
			add(grass);

			hills.color = 0xFF878787;
			gate.color = 0xFF878787;
			grass.color = 0xFF878787;

			if (isNewCam.contains(SONG.song.toLowerCase())) {
				UsingNewCam = true;
			}

		case 'houseroof': //SKIPPER WTF
	    	defaultCamZoom = 0.8;

			var bg:BGSprite = new BGSprite('dave/sky_night', -600, -200, 0.2, 0.2);
			add(bg);

			soscaryishitmypants.loadGraphic(Paths.image('dave/ok'));
		    soscaryishitmypants.antialiasing = true;
			soscaryishitmypants.scrollFactor.set(0.6, 0.6);
			soscaryishitmypants.active = true;
			soscaryishitmypants.visible = false;
			add(soscaryishitmypants);

			var grass:BGSprite = new BGSprite('dave/roof', -195, -105, 0.9, 0.9);
			grass.setGraphicSize(Std.int(grass.width * 1.5));
			grass.updateHitbox();
			add(grass);

			grass.color = 0xFF878787;

		case 'houseChristmas': //bab
	    	var bg:BGSprite = new BGSprite('dave/sky_night', -600, -200, 0.2, 0.2);
	     	add(bg);
	
        	var hills:BGSprite = new BGSprite('dave/Christmas/hills', -225, -125, 0.5, 0.5);
			hills.setGraphicSize(Std.int(hills.width * 1.25));
			hills.updateHitbox();
			add(hills);
	
			var gate:BGSprite = new BGSprite('dave/Christmas/gate', -226, -125, 0.9, 0.9);
			gate.setGraphicSize(Std.int(gate.width * 1.2));
			gate.updateHitbox();
			add(gate);
	
			var grass:BGSprite = new BGSprite('dave/Christmas/grass', -225, -125, 0.9, 0.9);
			grass.setGraphicSize(Std.int(grass.width * 1.2));
			grass.updateHitbox();
	    	add(grass);

		case 'houseOlderDay': //Older Dave Week
			var bg:BGSprite = new BGSprite('dave/davehouseback', -600, -200, 0.2, 0.2);
			add(bg);

			var davehouseceiling:BGSprite = new BGSprite('dave/davehouseceiling', -825, -125, 0.85, 0.85);
			davehouseceiling.setGraphicSize(Std.int(davehouseceiling.width * 1.25));
			davehouseceiling.updateHitbox();
			add(davehouseceiling);

			var davehousefloor:BGSprite = new BGSprite('dave/davehousefloor', -425, 625, 1.0, 1.0);
			davehousefloor.setGraphicSize(Std.int(davehousefloor.width * 1.3));
			davehousefloor.updateHitbox();
			add(davehousefloor);

			if (isNewCam.contains(SONG.song.toLowerCase())) {
	    		UsingNewCam = true;
			}

		case 'oldRed': 
			var bg:BGSprite = new BGSprite('dave/oldred', -600, -200, 0.9, 0.9);
			add(bg);

			UsingNewCam = true;

		case '3dRed':
			{
				defaultCamZoom = 0.85;
				curStage = '3dRed';

				redSky.loadGraphic(Paths.image('dave/redsky'));
				redSky.antialiasing = true;
				redSky.scrollFactor.set(0.6, 0.6);
				redSky.active = true;

				add(redSky);

				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				redSky.shader = testshader.shader;
				curbg = redSky;
				}

				//redPlatform.loadGraphic(Paths.image('dave/redPlatform'));
				//redPlatform.setGraphicSize(Std.int(redPlatform.width * 0.85));
				//redPlatform.updateHitbox();
				//redPlatform.antialiasing = true;
				//redPlatform.scrollFactor.set(1.0, 1.0);
				//redPlatform.active = true;
				//add(redPlatform);

				blackBG = new FlxSprite(-120, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
				blackBG.scrollFactor.set();
                blackBG.alpha = 0;
				add(blackBG);

				backyardnight.loadGraphic(Paths.image('dave/backyardnight'));
				backyardnight.antialiasing = true;
				backyardnight.scrollFactor.set(0.6, 0.6);
				backyardnight.active = true;
				backyardnight.visible = false;
				add(backyardnight);

				if (isNewCam.contains(SONG.song.toLowerCase())) {
			    	UsingNewCam = true;
				}
			}

		case '3dPissed':
			{
				defaultCamZoom = 0.85;
				curStage = '3dPissed';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/disrupted'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}
			}

		case '3dGreen':
			{
				defaultCamZoom = 0.85;
				curStage = '3dGreen';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/cheater'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}

				if (isNewCam.contains(SONG.song.toLowerCase())) {
		    		UsingNewCam = true;
				}
			}

		case 'bambersHell':
			{
				defaultCamZoom = 0.7;
				curStage = 'bambersHell';
				var bg:BGSprite = new BGSprite('bambi/purgatory/graysky', -600, -200, 0.2, 0.2);
				bg.antialiasing = false;
				bg.scrollFactor.set(0, 0);
				bg.active = true;
				add(bg);
	
				var bgshit:BGSprite = new BGSprite('bambi/purgatory/3d_Objects', -600, -200, 0.7, 0.7);
				bgshit.setGraphicSize(Std.int(bgshit.width * 1.25));
				bgshit.updateHitbox();
				add(bgshit);
	
				var bgshit2:BGSprite = new BGSprite('bambi/purgatory/3dBG_Objects', -600, -200, 0.5, 0.5);
				bgshit2.setGraphicSize(Std.int(bgshit2.width * 1.2));
				bgshit2.updateHitbox();
				add(bgshit2);
			}

		case '3dComputer':
			{
				defaultCamZoom = 0.75;
				curStage = '3dComputer';
				if(SONG.song.toLowerCase() == "technology") swagSpeed = 3.2; // https://cdn.discordapp.com/attachments/923248425145868329/936403638794993714/video0_1.mp4
				// wtf is this for
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/purgatory/billgates/computer'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}
			}

		case '3dBurger':
			{
				defaultCamZoom = 0.75;
				curStage = '3dBurger';

				if(SONG.song.toLowerCase() == "devastation") {
			    	swaggy = new Character(-1350, 100, 'bandu'); // needs to go to -300, 100 lol
			    	swagBombu = new Character(-400, 1350, 'bombu');

			        altSong = Song.loadFromJson('alt-notes', 'devastation');
				}

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/purgatory/hamburger'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.5, 0.5);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 2;
				testshader.waveSpeed = 0.95;
				bg.shader = testshader.shader;
				curbg = bg;
				}

				
				if(SONG.song.toLowerCase() == "devastation") {
			    	littleIdiot = new Character(200, -175, 'expunged');
			    	add(littleIdiot);
			    	littleIdiot.visible = false;
			    	poipInMahPahntsIsGud = false;

					swaggy = new Character(-1350, 100, 'bandu'); // needs to go to -300, 100 lol
					swagBombu = new Character(-400, 1350, 'bombu');
	
					altSong = Song.loadFromJson('alt-notes', 'devastation');

			      	what = new FlxTypedGroup<FlxSprite>();
			    	add(what);
			    }
			}

		case '3dScary':
			{
				defaultCamZoom = 0.85;
				curStage = '3dScary';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/scarybg'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}

				if (isNewCam.contains(SONG.song.toLowerCase())) {
			    	UsingNewCam = true;
				}
			}

		case '3dPhone':
			{
			    defaultCamZoom = 0.5;
			    curStage = '3dPhone';

				swagBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/3dPhone'));
				//swagBG.scrollFactor.set(0, 0);
				swagBG.scale.set(1.75, 1.75);
				//swagBG.updateHitbox();
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 1;
				testshader.waveSpeed = 2;
				swagBG.shader = testshader.shader;
				curbg = swagBG;
				}
				add(swagBG);

				littleIdiot = new Character(200, -175, 'expunged');
				add(littleIdiot);
				littleIdiot.visible = false;
				poipInMahPahntsIsGud = false;

				what = new FlxTypedGroup<FlxSprite>();
				add(what);

				/*computer = new FlxSprite(750, -150);
				computer.frames = Paths.getSparrowAtlas('bambi/pizza');
				computer.animation.addByPrefix('idle', 'p', 12, true);
				computer.animation.play('idle');
				computer.visible = true;
				computer.antialiasing = false;
				add(computer);*/

				for (i in 0...2) {
					var pizza = new FlxSprite(FlxG.random.int(100, 1000), FlxG.random.int(100, 500));
					pizza.frames = Paths.getSparrowAtlas('bambi/pizza');
					pizza.animation.addByPrefix('idle', 'p', 12, true); // https://m.gjcdn.net/game-thumbnail/500/652229-crop175_110_1130_647-stnkjdtv-v4.jpg
					pizza.animation.play('idle');
					pizza.ID = i;
					pizza.visible = false;
					pizza.antialiasing = false;
					wow2.push([pizza.x, pizza.y, FlxG.random.int(400, 1200), FlxG.random.int(500, 700), i]);
					gasw2.push(FlxG.random.int(800, 1200));
					what.add(pizza);
				}
			}

		case '3dFucked':
			{
				defaultCamZoom = 0.6;
				curStage = '3dFucked';
				poopBG.loadGraphic(Paths.image('dave/3dFucked'));
				poopBG.antialiasing = true;
				poopBG.setGraphicSize(Std.int(poopBG.width * 1.8));
				poopBG.antialiasing = true;
				poopBG.scrollFactor.set(0.4, 0.4);
				poopBG.active = true;
				add(poopBG);

				redBG = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnelBG'));
				redBG.setGraphicSize(Std.int(redBG.width * 1.15));
				redBG.updateHitbox();
				redBG.active = false;
				redBG.visible = false;
				add(redBG);

				redTunnel = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnel'));
				redTunnel.setGraphicSize(Std.int(redTunnel.width * 1.15));
				redTunnel.updateHitbox();
				redTunnel.active = false;
				redTunnel.visible = false;
				add(redTunnel);

				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				poopBG.shader = testshader.shader;
				curbg = poopBG;
				}
			}

		case 'farmDay':
			{
				defaultCamZoom = 0.85;
				curStage = 'farmDay';

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/sky'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = true;	

				var hills:FlxSprite = new FlxSprite(-300, 110).loadGraphic(Paths.image('bambi/orangey hills'));
				hills.antialiasing = true;
				hills.scrollFactor.set(0.5, 0.5);
				hills.active = true;

				var farm:FlxSprite = new FlxSprite(150, 200).loadGraphic(Paths.image('bambi/funfarmhouse'));
				farm.antialiasing = true;
				farm.scrollFactor.set(0.65, 0.65);
				farm.active = true;

				var foreground:FlxSprite = new FlxSprite(-400, 600).loadGraphic(Paths.image('bambi/grass lands'));
				foreground.antialiasing = true;
				foreground.scrollFactor.set(1, 1);
				foreground.active = true;

				var cornSet:FlxSprite = new FlxSprite(-350, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet.antialiasing = true;
				cornSet.scrollFactor.set(1, 1);
				cornSet.active = true;

				var cornSet2:FlxSprite = new FlxSprite(1050, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet2.antialiasing = true;
				cornSet2.scrollFactor.set(1, 1);
				cornSet2.active = true;

				var fence:FlxSprite = new FlxSprite(-350, 450).loadGraphic(Paths.image('bambi/crazy fences'));
				fence.antialiasing = true;
				fence.scrollFactor.set(0.98, 0.98);
				fence.active = true;

				var sign:FlxSprite = new FlxSprite(0, 500).loadGraphic(Paths.image('bambi/sign'));
				sign.antialiasing = true;
				sign.scrollFactor.set(1, 1);
				sign.active = true;

				add(bg);
				add(hills);
				add(farm);
				add(foreground);
				add(cornSet);
				add(cornSet2);
				add(fence);
				add(sign);

				if (isNewCam.contains(SONG.song.toLowerCase())) {
			    	UsingNewCam = true;
				}
			}

		case 'farmSunset':
			{
				defaultCamZoom = 0.85;
				curStage = 'farmSunset';

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/sky_sunset'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = true;

				var hills:FlxSprite = new FlxSprite(-300, 110).loadGraphic(Paths.image('bambi/orangey hills'));
				hills.antialiasing = true;
				hills.scrollFactor.set(0.5, 0.5);
				hills.active = true;

				var farm:FlxSprite = new FlxSprite(150, 200).loadGraphic(Paths.image('bambi/funfarmhouse'));
				farm.antialiasing = true;
				farm.scrollFactor.set(0.65, 0.65);
				farm.active = true;

				var foreground:FlxSprite = new FlxSprite(-400, 600).loadGraphic(Paths.image('bambi/grass lands'));
				foreground.antialiasing = true;
				foreground.scrollFactor.set(1, 1);
				foreground.active = true;

				var cornSet:FlxSprite = new FlxSprite(-350, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet.antialiasing = true;
				cornSet.scrollFactor.set(1, 1);
				cornSet.active = true;

				var cornSet2:FlxSprite = new FlxSprite(1050, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet2.antialiasing = true;
				cornSet2.scrollFactor.set(1, 1);
				cornSet2.active = true;

				var fence:FlxSprite = new FlxSprite(-350, 450).loadGraphic(Paths.image('bambi/crazy fences'));
				fence.antialiasing = true;
				fence.scrollFactor.set(0.98, 0.98);
				fence.active = true;

				var sign:FlxSprite = new FlxSprite(0, 500).loadGraphic(Paths.image('bambi/sign'));
				sign.antialiasing = true;
				sign.scrollFactor.set(1, 1);
				sign.active = true;

				hills.color = 0xFFF9974C;
				farm.color = 0xFFF9974C;
				foreground.color = 0xFFF9974C;
				cornSet.color = 0xFFF9974C;
				cornSet2.color = 0xFFF9974C;
				fence.color = 0xFFF9974C;
				sign.color = 0xFFF9974C;

				add(bg);
				add(hills);
				add(farm);
				add(foreground);
				add(cornSet);
				add(cornSet2);
				add(fence);
				add(sign);

				if (isNewCam.contains(SONG.song.toLowerCase())) {
		    		UsingNewCam = true;
				}
			}

		case 'farmNight':
			{
				defaultCamZoom = 0.85;
				curStage = 'farmNight';
				
				/*if(ClientPrefs.chromaticAberration)
				  camGame.setFilters([ShadersHandler.ChromaticAberration]);
				  ShadersHandler.setChrome(1000);
				*/

				var bg:FlxSprite = new FlxSprite(-600, -400).loadGraphic(Paths.image('dave/sky_night'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = true;

				var hills:FlxSprite = new FlxSprite(-300, 110).loadGraphic(Paths.image('bambi/orangey hills'));
				hills.antialiasing = true;
				hills.scrollFactor.set(0.5, 0.5);
				hills.active = true;

				var farm:FlxSprite = new FlxSprite(150, 200).loadGraphic(Paths.image('bambi/funfarmhouse'));
				farm.antialiasing = true;
				farm.scrollFactor.set(0.65, 0.65);
				farm.active = true;

				var foreground:FlxSprite = new FlxSprite(-400, 600).loadGraphic(Paths.image('bambi/grass lands'));
				foreground.antialiasing = true;
				foreground.scrollFactor.set(1, 1);
				foreground.active = true;

				var cornSet:FlxSprite = new FlxSprite(-350, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet.antialiasing = true;
				cornSet.scrollFactor.set(1, 1);
				cornSet.active = true;

				var cornSet2:FlxSprite = new FlxSprite(1050, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet2.antialiasing = true;
				cornSet2.scrollFactor.set(1, 1);
				cornSet2.active = true;

				var fence:FlxSprite = new FlxSprite(-350, 450).loadGraphic(Paths.image('bambi/crazy fences'));
				fence.antialiasing = true;
				fence.scrollFactor.set(0.98, 0.98);
				fence.active = true;

				var sign:FlxSprite = new FlxSprite(0, 500).loadGraphic(Paths.image('bambi/sign'));
				sign.antialiasing = true;
				sign.scrollFactor.set(1, 1);
				sign.active = true;

				hills.color = 0xFF878787;
				farm.color = 0xFF878787;
				foreground.color = 0xFF878787;
				cornSet.color = 0xFF878787;
				cornSet2.color = 0xFF878787;
				fence.color = 0xFF878787;
				sign.color = 0xFF878787;

				add(bg);
				add(hills);
				add(farm);
				add(foreground);
				add(cornSet);
				add(cornSet2);
				add(fence);
				add(sign);

				if (isNewCam.contains(SONG.song.toLowerCase())) {
					UsingNewCam = true;
				}
	        }
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				CoolUtil.precacheSound('thunder_1');
				CoolUtil.precacheSound('thunder_2');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<BGSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:BGSprite = new BGSprite('philly/win' + i, city.x, city.y, 0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				CoolUtil.precacheSound('train_passes');
				FlxG.sound.list.add(trainSound);

				var street:BGSprite = new BGSprite('philly/street', -40, 50);
				add(street);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					CoolUtil.precacheSound('dancerdeath');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				CoolUtil.precacheSound('Lights_Shut_off');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/

				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);
		
		if(curStage == 'spooky') {
			add(halloweenWhite);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if(SONG.song.toLowerCase() == "unfairness" || SONG.song.toLowerCase() == "upheaval")
		{
			health = 2;
		}

		if(curStage == 'philly') {
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}


		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = SUtil.getPath() + Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(curStage == 'philly') {
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}
		
		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));

		if(!modchartSprites.exists('blammedLightsBlack')) { //Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if(members.indexOf(boyfriendGroup) < position) {
				position = members.indexOf(boyfriendGroup);
			} else if(members.indexOf(dadGroup) < position) {
				position = members.indexOf(dadGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		if(curStage == 'philly') insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;
		#end

		screenshader.waveAmplitude = 1;
        screenshader.waveFrequency = 2;
        screenshader.waveSpeed = 1;
        screenshader.shader.uTime.value[0] = new flixel.math.FlxRandom().float(-100000, 100000);

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}
		if(isFreeplay || isFreeplayPur)
			{
				if(CharacterSelectionState.notBF)
					gf.visible = false;
			}
		
		if(SONG.song.toLowerCase() == 'antagonism')
			{
				badai = new Character(-300, 100, 'badai');
				gf.visible = false;
			}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);
		
		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		if(badai != null) add(badai);
		if (swaggy != null) add(swaggy);
		if (swagBombu != null) add(swagBombu);
		
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];


		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);	
			case 'schoolEvil' | 'spooky':
				evilTrail = new FlxTrail(dad, null, 4, 12, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
			case 'houseroof':
				evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
				evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(boyfriendGroup) - 1, evilTrail);
		}
		switch(dad.curCharacter)
		{
			case 'bambi-scaryooo' | 'bambi-god' | 'bambi-god2d' | 'bambi-hell' | 'expunged' | 'bombu-expunged':
				evilTrail = new FlxTrail(dad, null, 4, 12, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
				switch (curStage)
		    	{
		     		case 'spooky':
			    	evilTrail.color = 0xFF383838;
				}
		}

		// welcome to dialogue bullshit zone act 2
		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(SUtil.getPath() + file);
		}

		var file:String = Paths.json(songName + '/dialogueES');
		if (OpenFlAssets.exists(file)) {
			esDialogueJson = DialogueBoxPsych.parseDialogue(SUtil.getPath() + file);
		}

		var file:String = Paths.json(songName + '/dialoguePR');
		if (OpenFlAssets.exists(file)) {
			prDialogueJson = DialogueBoxPsych.parseDialogue(SUtil.getPath() + file);
		}

		// now end dialogue bullshit yeahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh

		var file:String = Paths.json(songName + '/dialogue-end'); //Checks for ending json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			eteSechDialogueJson = DialogueBoxPsych.parseDialogue(SUtil.getPath() + file);
		}

		var file:String = Paths.json(songName + '/dialogue-endES');
		if (OpenFlAssets.exists(file)) {
			esEteSechDialogueJson = DialogueBoxPsych.parseDialogue(SUtil.getPath() + file);
		}

		var file:String = Paths.json(songName + '/dialogue-endPR');
		if (OpenFlAssets.exists(file)) {
			prEteSechDialogueJson = DialogueBoxPsych.parseDialogue(SUtil.getPath() + file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai/3d/vs dave dialogue 
		// this one is only used for barcode so i dont think it will be necessary to add dialogs

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai/3d/vs dave dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(SUtil.getPath() + file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		switch (curSong.toLowerCase())
		{
			case 'roundabout' | 'upheaval':
				doof.finishThing = startSongNoCountDown;
			default:
				doof.finishThing = startCountdown;
		}
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(!dontMiddle.contains(SONG.song.toLowerCase()) && ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll || SONG.song.toLowerCase() == 'unfairness') strumLine.y = FlxG.height - 165;
		strumLine.scrollFactor.set();

		if (SONG.song.toLowerCase() == 'devastation') {
			altStrumLine = new FlxSprite(0, -100);
		}

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = ClientPrefs.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = ClientPrefs.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (ClientPrefs.laneunderlay)
		{
			add(laneunderlay);
			add(laneunderlayOpponent);
			if(ClientPrefs.middleScroll)
			{
				remove(laneunderlayOpponent);
				laneunderlayOpponent.visible = false;
			}
		}

		var showTime:Bool =  (!ClientPrefs.hideTime);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
	    	timeTxt.setFormat(Paths.font("comic-sans.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		} else {
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
			timeTxt.setFormat(Paths.font("comic-sans.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		timeTxt.scrollFactor.set();
		timeTxt.screenCenter(X);
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 55;
		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('healthBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		timeBarBG.screenCenter(X);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		reloadTimeBarColors();
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		add(timeBarBG);
		add(timeBar);
		add(timeTxt);

		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();
		poopStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = SUtil.getPath() + Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = SUtil.getPath() + Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		if(!ClientPrefs.longAssBar) {
     		healthBarBG = new AttachedSprite('healthBar');
			 
		    healthBarBG.y = FlxG.height * 0.89;
	     	healthBarBG.xAdd = -4;
	     	healthBarBG.yAdd = -4;
		}
	    else if(ClientPrefs.longAssBar) {
			healthBarBG = new AttachedSprite('healthBarWIDE');
			healthBarBG.y = FlxG.height * 0.88;
			healthBarBG.xAdd = -4;
			healthBarBG.yAdd = -4;
		}

		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 50;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;
		add(iconP2);
		reloadHealthBarColors();

		if(!ClientPrefs.classicScore) {
	    	scoreTxt = new FlxText(0, healthBarBG.y + 30, FlxG.width, "", 20);
		    scoreTxt.setFormat(Paths.font("comic-sans.ttf"), 17, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	    	scoreTxt.borderSize = 1.25;
		} else if(ClientPrefs.classicScore) {
			scoreTxt = new FlxText(0, healthBarBG.y + 40, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.borderSize = 1.5;
		}
		scoreTxt.scrollFactor.set();
		scoreTxt.screenCenter(X);
		add(scoreTxt);

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${songMisses}';
		if (ClientPrefs.judgementCounter) {
			add(judgementCounter);
		}

		var credits:String;
		switch (SONG.song.toLowerCase())
		{
			case 'supernovae' | 'supernovae-uber':
				credits = 'Original Song made by ArchWk!';
			case 'fast-food':
				credits = 'Song Made by randy the slope!';
			case 'glitch':
				credits = 'Original Song made by DeadShadow and PixelGH!';
			case 'mealie':
				credits = 'Song made by Alexander Cooper 19!';
			case '8-28-63':
				credits = 'Original Song made by Tsuraran! | VS SKIPPA';
			case 'unfairness':
				credits = "Ghost tapping is forced off! Screw you!";
			case 'disruption':
				credits = "Screw You! | Original song made by Grantare for Golden Apple!";
			case 'sucked':
				credits = 'Original Song made by ZackGM/SomeThing111 for Vs Umball!';
			case 'cheating':
				credits = 'Screw you!';
			case 'vs-dave-thanksgiving' | 'vs-dave-christmas':
				credits = 'this song is a joke lol, What the fuck.';
			case 'secret':
				credits = 'ATTENTION: WE HAVE DISCOVERED YOU HAVE MORE THAN ONE CHILD! THE BALDI BASICS VIRUS HAS INFECTED YOUR GOVERNMENT ISSUED COMPUTER! SEND US FIVE BILLION ¥ OR WE WILL ASSASSINATE YOUR FAMILY!';
			case 'secret-2':
				credits = 'https://www.youtube.com/watch?v=8hicUF3oxoU&t=111s';
			case 'secret-3':
				credits = 'rip bozo - Freedom Dive by XI';
			case 'bombu x bamburg shipping cute':
				credits = 'they kissign love of true | Original Song by Grantare for Golden Apple! (Cover by randy the slope!)';
			case 'harvested':
				credits = 'Original Song made by BezieAnims!';
			case 'DATA_EXPUNGED_(HAXELIB_ERROR)':
				credits = "????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????";
			default:
				credits = '';
		}
		var randomThingy:Int = FlxG.random.int(0, 7);
		var engineName:String = 'stupid';
		switch(randomThingy)
	    {
			case 0:
				engineName = 'Dave ';
			case 1:
				engineName = 'Bambi ';
			case 2:
				engineName = 'Tristan ';
			case 3:
				engineName = 'David '; // hey this DOESNT mean david is coming to bp, its cuz is like some alternative version of dave lol
			case 4:
				engineName = 'Bombu ';
			case 5:
				engineName = 'Bamburg ';
			case 6:
				engineName = 'Crusti ';
			case 7:
				engineName = 'Banbodi '; 
			case 8:
				engineName = 'Gary '; 
			case 9:
				engineName = 'Jeff '; 
		/*	case 10:
				engineName = 'Ringi ';*/
		/*	case 11:
				engineName = 'Candu ';*/ //  not adding these guys till the next update lololo
		}
		var creditsText:Bool = credits != '';
		var textYPos:Float = healthBarBG.y + 52;
		if (creditsText)
		{
			textYPos = healthBarBG.y + 32;
		}

		creditsWatermark = new FlxText(4, healthBarBG.y + 50, 0, credits, 16);
		creditsWatermark.setFormat(Paths.font("comic-sans.ttf"), 14, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		creditsWatermark.scrollFactor.set();
		creditsWatermark.borderSize = 1.25;
		add(creditsWatermark);
		creditsWatermark.cameras = [camHUD];

		// credits to kade dev for the song watermark lol
		if(ClientPrefs.lang == 'English') {
			songWatermark = new FlxText(4, textYPos, 0,
			SONG.song
			+ " - "
			+ (curSong.toLowerCase() != 'splitathon' ? (storyDifficulty == 3 ? "FINALE" : storyDifficulty == 2 ? "HARD" : storyDifficulty == 1 ? "NORMAL" : "EASY") : "FINALE")
			+ " | " + engineName + 'Engine ' + MainMenuState.curModVer + ' (PE ' + MainMenuState.psychEngineVersion + ')', 14);
			//+ " ", 16);
		}
		else if(ClientPrefs.lang == 'Spanish--Espanol' || ClientPrefs.lang == 'Portuguese--Português') {
			songWatermark = new FlxText(4, textYPos, 0,
			SONG.song
			+ " - "
			+ (curSong.toLowerCase() != 'splitathon' ? (storyDifficulty == 3 ? "FINAL" : storyDifficulty == 2 ? "DIFICIL" : storyDifficulty == 1 ? "NORMAL" : "FACIL") : "FINAL")
			+ " | " + engineName + 'Engine ' + MainMenuState.curModVer + ' (PE ' + MainMenuState.psychEngineVersion + ')', 14);
			//+ " ", 16);
		}
		songWatermark.setFormat(Paths.font("comic-sans.ttf"), 14, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songWatermark.scrollFactor.set();
		songWatermark.borderSize = 1.25;
		songWatermark.visible = !ClientPrefs.hideHud;
		add(songWatermark);

		shartingTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (ClientPrefs.downScroll ? 100 : -100), 0, "CHARTING MODE", 20);
		shartingTxt.setFormat(Paths.font("comic-sans.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		shartingTxt.scrollFactor.set();
		shartingTxt.screenCenter(X);
		shartingTxt.borderSize = 4;
		shartingTxt.borderQuality = 2;
		if(chartingMode) insert(members.indexOf(strumLineNotes), shartingTxt);

		var composersWatermark:String;
		switch (SONG.song.toLowerCase())
		{
			// add moldy's songs here
			case 'house' | 'insanity' | 'furiosity' | 'bonus-song' | 'polygonized' | 'blocked' | 'corn-theft' | 'maze' | 'splitathon' | 'cheating' | 'unfairness' | 'old-house' | 'old-insanity' | 'old-furiosity' | 'old-blocked' | 'old-corn-theft' | 'old-maze' | 'old-splitathon', 'beta-maze':
		    	composersWatermark = 'MoldyGH';
			// add pyramix's songs here
            case 'reality-breaking' | 'technology' | 'body-destroyer' | 'face-destroyer':
				composersWatermark = 'Pyramix';
			// add randomness songs here 
		    case 'shattered' | 'Tyranny':
				composersWatermark = 'EpicRandomness11';
			// add villezen's songs here
			case 'rascal' | 'callback':
				composersWatermark = 'Villezen';
			// add aadsta's songs here
			case 'acquaintance':
				composersWatermark = 'AadstaPinwheel';
			//randy the slope
		    case 'fast-food':
				composersWatermark = 'randy the slope';
			// razordballsc
			case 'velocity':
		        composersWatermark = 'RazorDC';
			// NULL_Y34R
			case 'lacuna':
		        composersWatermark = 'NULL_Y34R';
			// welcome to collab or v2s zone
			case 'supplanted':
                composersWatermark = 'EpicRandomness (V2), Cynda (V1)';
			case 'antagonism':
				composersWatermark = 'BezieAnims, AadstaPinwheel,\nBezieAnims, RazorDC';
		    case 'upheaval':
				composersWatermark = 'EpicRandomness11, BezieAnims';
			case 'triple-threat':
				composersWatermark = 'EpicRandomness11, add the composer here lololo';
			case 'devastation':
				composersWatermark = 'Hortas, Pyramix';

			case 'bombu x bamburg shipping cute':
				composersWatermark = 'Original song by Grantare\nCover by randy the slope';

			case 'Malware':
		        composersWatermark = 'sola, RazorDC';
			case 'disruption':
				composersWatermark = 'Grantare';


			case "beefin'":
		    	composersWatermark = 'Cynda'; // who will make v2
			// fdsgujhosfdjohfsdjgn
			default:
				composersWatermark = ' ';
		}

		ballsText = new FlxText(20, 0, 0, "", 20);
		ballsText.setFormat(Paths.font("comic-sans.ttf"), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ballsText.borderSize = 4;
		ballsText.borderQuality = 2;
		ballsText.scrollFactor.set();
		ballsText.cameras = [camHUD];
        ballsText.text = SONG.song;
		add(ballsText);

		composersText = new FlxText(20, 40/*hi remember that this is the y pos*/, 0, "", 20);
		composersText.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		composersText.borderSize = 4;
		composersText.borderQuality = 2;
		composersText.scrollFactor.set();
		composersText.cameras = [camHUD];
		if(ClientPrefs.lang == 'English') {
            composersText.text = 'Composer(s): ' + composersWatermark;
		}
		if(ClientPrefs.lang == 'Spanish--Espanol' || ClientPrefs.lang == 'Portuguese--Portugues') {
			composersText.text = 'Compositor(es): ' + composersWatermark;
		}
		add(composersText);

		add(scoreTxt); // so the score is on top of everything

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("comic-sans.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		blackScreendeez.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		shartingTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		redGlow.cameras = [camHUD];
		songWatermark.cameras = [camHUD];
		doof.cameras = [camHUD];

		#if android
		addAndroidControls();
		#end

		healthBar.alpha = 0;
		healthBarBG.alpha = 0;
		iconP1.alpha = 0;
		iconP2.alpha = 0;
		scoreTxt.alpha = 0;
		judgementCounter.alpha = 0;
		songWatermark.alpha = 0;
		creditsWatermark.alpha = 0;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;


		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode || isPurStoryMode || ClientPrefs.freeplayCuts && !seenCutscene)
		{
			switch (daSong)
			{
				case 'senpai' | 'roses' | 'thorns' | 'polygonized' | 'furiosity' | 'cheating' | 'unfairness':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

					    case 'tutorial':
							startDialogue(dialogueJson);

						case 'house':
							startVideoDIALOGUE('daveCutscene');
		 
						case 'insanity' | 'blocked' | 'corn-theft' | 'splitathon':
							dialogBullshitStart();
		 
						case 'maze':
							startVideoDIALOGUE('bambiCutscene'); 

						case 'roundabout' | 'upheaval':
							startSongNoCountDown(); // replace this l8 when there's dialogue

					default:
			    		startCountdown();
			}
			seenCutscene = true;
		} else {
			switch (curSong.toLowerCase())
			{
				case 'roundabout' | 'upheaval':
					startSongNoCountDown();
				default:
		         	startCountdown();
			}
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');
		if (PauseSubState.songName != null) {
			CoolUtil.precacheMusic(PauseSubState.songName);
		} else if(ClientPrefs.pauseMusic != 'None') {
			CoolUtil.precacheMusic(Paths.formatToSongPath(ClientPrefs.pauseMusic));
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
		
		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);

		
		super.create();

		Paths.clearUnusedMemory();
		CustomFadeTransition.nextCamera = camOther;
	}

	static public function quickSpin(sprite)
		{
			FlxTween.angle(sprite, 0, 360, 0.5, {
				type: FlxTween.ONESHOT,
				ease: FlxEase.quadInOut,
				startDelay: 0,
				loopDelay: 0
			});
		}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
				for (note in notes)
				{
					if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
					{
						note.scale.y *= ratio;
						note.updateHitbox();
					}
				}
				for (note in unspawnNotes)
				{
					if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		return value;
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		if(ClientPrefs.colorBars) {
     		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
		    	FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		} else {
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}
			
		healthBar.updateBar();
	}

	public function reloadTimeBarColors() {
		if(ClientPrefs.colorBars) {
		    timeBar.createFilledBar(FlxColor.BLACK, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
		} else {
			timeBar.createFilledBar(0xFF000000, 0xFF66FF33);
		}

		timeBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = SUtil.getPath() + Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}
	#if windows
	  public function addShaderToCamera(cam:String,effect:ShaderEffect){//STOLE FROM ANDROMEDA
	  
	  
	  
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
					camHUDShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camHUDShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
					camOtherShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camOtherShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camOther.setFilters(newCamEffects);
			case 'camgame' | 'game':
					camGameShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camGameShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camGame.setFilters(newCamEffects);
			default:
				if(modchartSprites.exists(cam)) {
					Reflect.setProperty(modchartSprites.get(cam),"shader",effect.shader);
				} else if(modchartTexts.exists(cam)) {
					Reflect.setProperty(modchartTexts.get(cam),"shader",effect.shader);
				} else {
					var OBJ = Reflect.getProperty(PlayState.instance,cam);
					Reflect.setProperty(OBJ,"shader", effect.shader);
				}
			
			
				
				
		}
	  
	  
	  
	  
  }

  public function removeShaderFromCamera(cam:String,effect:ShaderEffect){
	  
	  
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
    camHUDShaders.remove(effect);
    var newCamEffects:Array<BitmapFilter>=[];
    for(i in camHUDShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    camHUD.setFilters(newCamEffects);
			case 'camother' | 'other': 
					camOtherShaders.remove(effect);
					var newCamEffects:Array<BitmapFilter>=[];
					for(i in camOtherShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camOther.setFilters(newCamEffects);
			default: 
				camGameShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camGameShaders){
				  newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
		}
		
	  
  }
  #end
	
	
	
  public function clearShaderFromCamera(cam:String){
	  
	  
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other': 
				camOtherShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camOther.setFilters(newCamEffects);
			default: 
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camGame.setFilters(newCamEffects);
		}
		
	  
  }

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				if(endingSong) {
					endSong();
				} else {
					switch (curSong.toLowerCase()) {
					case 'roundabout' | 'upheaval':
						startSongNoCountDown();
					default:
			    		startCountdown();
					}
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
		if(endingSong) {
			endSong();
		} else {
			switch (curSong.toLowerCase()) {
				case 'roundabout' | 'upheaval':
					startSongNoCountDown();
				default:
					startCountdown();
			}
		}
	}

	public function startVideoDIALOGUE(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				if(endingSong) {
					endSong();
				} else {
					dialogBullshitStart();
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
		if(endingSong) {
			endSong();
		} else {
			dialogBullshitStart();
		}
	}

	var dialogueCount:Int = 0;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song);
			doof.scrollFactor.set();
			if(endingSong) {
				doof.finishThing = endSong;
			} else {
				switch (curSong.toLowerCase())
				{
					case 'roundabout' | 'upheaval':
						doof.finishThing = startSongNoCountDown;
					default:
						doof.finishThing = startCountdown;
				}
			}
			doof.nextDialogueThing = startNextDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				switch (curSong.toLowerCase()) {
					case 'roundabout' | 'upheaval':
						startSongNoCountDown();
					default:
			    		startCountdown();
				}
			}
		}
	}
	
	public function eteSechStartDialogue(dialogueFile:DialogueFile, ?song:String = null):Void // ENDING DIALOGUE FUNCTION NON LUA
		{
			var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

			// TO DO: Make this more flexible, maybe?
			if(dialogueFile.dialogue.length > 0) {
				inCutscene = true;
				CoolUtil.precacheSound('dialogue');
				CoolUtil.precacheSound('dialogueClose');
				var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song);
				doof.scrollFactor.set();
				if(endingSong) {
					doof.finishThing = endSong;
				} else {
					doof.finishThing = endSong;
				}
				doof.nextDialogueThing = startNextDialogue;
				doof.skipDialogueThing = skipDialogue;
				doof.cameras = [camHUD];
				add(doof);
			} else {
				FlxG.log.warn('Your dialogue file is badly formatted!');
				if(endingSong) {
					endSong();
					if(ClientPrefs.noteOffset <= 0) {
						finishCallback();
					} else {
						finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
						   finishCallback();
					   });
					}
				} else {
					endSong();
					if(ClientPrefs.noteOffset <= 0) {
						finishCallback();
					} else {
						finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
						   finishCallback();
					   });
					}
				}
			}
		}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					switch (curSong.toLowerCase()) {
					case 'roundabout' | 'upheaval':
						startSongNoCountDown();
					default:
			    		startCountdown();
					}

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var midTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		if (SONG.song.toLowerCase() == 'unfairness' || SONG.song.toLowerCase() == 'cheating' || SONG.song.toLowerCase() == 'lacuna')
		{
			if(cpuControlled || practiceMode)
			{
				FlxG.switchState(new SusState());
			}
		}
		if (SONG.song.toLowerCase() == 'lacuna') {
	    	fartt = true;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			#if android
			androidc.visible = true;
			#end

		    	generateStaticArrows(0);
		    	generateStaticArrows(1);
		    	for (i in 0...playerStrums.length) {
			     	setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
			    	setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			    }
		    	for (i in 0...opponentStrums.length) {
			    	setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			    	setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			    	if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
		    	}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (skipCountdown || startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return;
			}

			laneunderlay.x = playerStrums.members[0].x - 25;
			laneunderlayOpponent.x = opponentStrums.members[0].x - 25;
			
			laneunderlay.screenCenter(Y);
			laneunderlayOpponent.screenCenter(Y);

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}
				
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				switch (SONG.song.toLowerCase())
				{
		    	case 'polygonized':
					introAssets.set('default', ['dave/blank', 'dave/blank', 'dave/blank']);
				}

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						if(ClientPrefs.followarrow) isDadGlobal = false;
						if(ClientPrefs.followarrow) moveCamera(false);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						countdownReady.cameras = [camHUD];
						add(countdownReady);
						countDownSprites.push(countdownReady);
						FlxTween.tween(countdownReady, {y: countdownReady.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(countdownReady);
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					    if(ClientPrefs.followarrow)	isDadGlobal = true;
						if(ClientPrefs.followarrow) moveCamera(true);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						countdownSet.cameras = [camHUD];
						add(countdownSet);
						countDownSprites.push(countdownSet);
						FlxTween.tween(countdownSet, {y: countdownSet.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(countdownSet);
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						if(ClientPrefs.followarrow) isDadGlobal = false;
						if(ClientPrefs.followarrow) moveCamera(false);
					case 3:
						var countdownGo:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						countdownGo.cameras = [camHUD];
						add(countdownGo);
						countDownSprites.push(countdownGo);
						FlxTween.tween(countdownGo, {y:400}, 0.5, {ease: FlxEase.cubeOut});

						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						if(ClientPrefs.followarrow) isDadGlobal = true;
						if(ClientPrefs.followarrow) moveCamera(true);
						strumLineNotes.forEach(function(note)
							{
								quickSpin(note);
							});
							if(isNormalStart) {
						    	FlxTween.tween(healthBar, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
						    	FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
						    	FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
						    	FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 0.35);

						    	FlxTween.tween(scoreTxt, {alpha:1}, 0.35);
						    	FlxTween.tween(judgementCounter, {alpha:1}, 0.35);
					    		FlxTween.tween(songWatermark, {alpha:1}, 0.35);
						    	FlxTween.tween(creditsWatermark, {alpha:1}, 0.35);
							}
							FlxTween.tween(ballsText, {alpha:0}, 2);
							FlxTween.tween(composersText, {alpha:0}, 2);

							FlxTween.tween(ballsText, {y:-100}, 2, {
								onComplete: function(tween:FlxTween)
								{
									remove(ballsText);
								},
								ease: FlxEase.circOut
							});

							FlxTween.tween(composersText, {y:-100}, 2, {
								onComplete: function(tween:FlxTween)
								{
									remove(composersText);
								},
								ease: FlxEase.circOut
							});

					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = 1 * note.multAlpha;
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function startSongNoCountDown():Void
	{
		inCutscene = false;

		if (SONG.song.toLowerCase() == 'upheaval') {
            isNormalStart = false;
		}

		#if android
		androidc.visible = true;
		#end


		    generateStaticArrows(0);
		    generateStaticArrows(1);
		    for (i in 0...playerStrums.length) {
			   	setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
		    }
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			  	setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
		 	}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;

			laneunderlay.x = playerStrums.members[0].x - 25;
			laneunderlayOpponent.x = opponentStrums.members[0].x - 25;
			
			laneunderlay.screenCenter(Y);
			laneunderlayOpponent.screenCenter(Y);

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				if(isNormalStart) {
					FlxTween.tween(healthBar, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 0.35);

				/*	FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					 */ // i need to finish this uhhh uhhh

					FlxTween.tween(scoreTxt, {alpha:1}, 0.35);
					FlxTween.tween(judgementCounter, {alpha:1}, 0.35);
					FlxTween.tween(songWatermark, {alpha:1}, 0.35);
					FlxTween.tween(creditsWatermark, {alpha:1}, 0.35);
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = 1 * note.multAlpha;
				});

				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
	     	}, 5);

			strumLineNotes.forEach(function(note)
			{
				quickSpin(note);
			});
	}

	function daCountDownMidSong():Void
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'pixelUI/ready-pixel',
				'pixelUI/set-pixel',
				'pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'pixelUI/ready-pixel',
				'pixelUI/set-pixel',
				'pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}
			
			midTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				switch (swagCounter)

				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (curStage.startsWith('school') || isPixelStage)
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

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

						if (curStage.startsWith('school') || isPixelStage)
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

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

						if (curStage.startsWith('school') || isPixelStage)
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

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
				// generateSong('fresh');
			}, 5);
	}

		public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		if(isNormalStart) {
	    	FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
	    	FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	var isFunnySong = false;

	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		if(ClientPrefs.scroll) {
			songSpeed = ClientPrefs.speed;
		}

		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped


		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(SUtil.getPath() + file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
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

				var swagNote:Note;
				if(PlayState.SONG.isSkinSep) {
					if (gottaHitNote){
						swagNote = new Note(daStrumTime, daNoteData, oldNote, false, false, true);
					} else {
						 swagNote = new Note(daStrumTime, daNoteData, oldNote);
					}
				} else {
					swagNote = new Note(daStrumTime, daNoteData, oldNote);
				}

				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
				
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note;
						if(PlayState.SONG.isSkinSep) {
							 //checks if its a player note, if it is, then it turns it into a note that DOESNT use the custom style
							if (gottaHitNote){
								sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true, false, true);
							} else {
								sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
							}
						} else { 
							sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						}

						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
	
		if (altSong != null) {
			altNotes = new FlxTypedGroup<Note>();
			isFunnySong = true;
			daBeats = 0;
			for (section in altSong.notes) {
				for (noteJunk in section.sectionNotes) {
					var swagNote:Note = new Note(noteJunk[0], Std.int(noteJunk[1] % 4), null, false, false, noteJunk[3]);
					swagNote.isAlt = true;

					altUnspawnNotes.push(swagNote);

					swagNote.mustPress = false;
					swagNote.x -= 250;
				}
			}
			altUnspawnNotes.sort(sortByShit);
		}

		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(!dontMiddle.contains(SONG.song.toLowerCase()) && ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);

			if (!skipArrowStartTween)
			{
				babyArrow.y -= 60;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 60, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();

			arrowJunks.push([babyArrow.x, babyArrow.y]);
		}

		if (SONG.song.toLowerCase() == 'devastation') { // testing some stuff n shit
			swagThings = new FlxTypedGroup<FlxSprite>();

			for (i in 0...4)
			{
				var babyArrow:StrumNote = new StrumNote(!dontMiddle.contains(SONG.song.toLowerCase()) && ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);

				FlxTween.tween(babyArrow, {y: babyArrow.y + 60, scale: 0.5}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				babyArrow.alpha = 0.5;

				poopStrums.add(babyArrow);

				babyArrow.ID = i;

				strumLineNotes.add(babyArrow);
				babyArrow.postAddedToGroup();

				arrowJunks.push([babyArrow.x, babyArrow.y]);
				var hi = new FlxSprite(0, babyArrow.y);
				hi.ID = i;
				swagThings.add(hi);
			}	
		
			insert(members.indexOf(strumLineNotes), poopStrums);
			insert(members.indexOf(strumLineNotes), altNotes);

			poopStrums.forEach(function(spr:FlxSprite){
				spr.alpha = 0.5;
			});
		}
		/*
			if (SONG.song.toLowerCase() == 'devastation') {
			swagThings = new FlxTypedGroup<FlxSprite>();

			for (i in 0...4)
			{
				// FlxG.log.add(i);
				var babyArrow:StrumNote = new StrumNote(!dontMiddle.contains(SONG.song.toLowerCase()) && ClientPrefs.middleScroll ?  STRUM_X_MIDDLESCROLL : STRUM_X, altStrumLine.y, i, player);
				
				babyArrow.frames = Paths.getSparrowAtlas('polynote');
				babyArrow.animation.addByPrefix('greenScroll', 'green0');
				babyArrow.animation.addByPrefix('redScroll', 'red0');
				babyArrow.animation.addByPrefix('blueScroll', 'blue0');
				babyArrow.animation.addByPrefix('purpleScroll', 'purple0');

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
				babyArrow.updateHitbox();

				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				babyArrow.y -= 1000;

				babyArrow.ID = i;

				poopStrums.add(babyArrow);

				babyArrow.animation.play('static');
				babyArrow.x += 90;
				babyArrow.x -= 250;

				strumLineNotes.add(babyArrow);
				babyArrow.postAddedToGroup();

				arrowJunks.push([babyArrow.x, babyArrow.y + 1000]);
				var hi = new FlxSprite(0, babyArrow.y);
				hi.ID = i;
				swagThings.add(hi);
			}
		
			add(poopStrums);
			/*poopStrums.forEach(function(spr:FlxSprite){
				spr.alpha = 0;
			});* /
		
			add(altNotes);
		}*/
	}

	private var swagThings:FlxTypedGroup<FlxSprite>;
	
	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
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
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	private var poipInMahPahntsIsGud:Bool = true;

	private var banduJunk:Float = 0;
	private var dadFront:Bool = false;
	private var hasJunked:Bool = false;
	private var wtfThing:Bool = false;
	private var orbit:Bool = true;
	private var unfairPart:Bool = false;
	private var noteJunksPlayer:Array<Float> = [0, 0, 0, 0];
	private var noteJunksDad:Array<Float> = [0, 0, 0, 0];
	private var what:FlxTypedGroup<FlxSprite>;
	private var wow2:Array<Array<Float>> = [];
	private var gasw2:Array<Float> = [];
	private var poiping:Bool = true;
	private var canPoip:Bool = true;
	private var lanceyLovesWow2:Array<Bool> = [false, false];
	private var whatDidRubyJustSay:Int = 0;


	override public function update(elapsed:Float)
	{
	elapsedtime += elapsed;


	if (curbg != null)
	{
		if (curbg.active) // only the furiosity background is active
		{
			var shad = cast(curbg.shader, Shaders.GlitchShader);
			shad.uTime.value[0] += elapsed;
		}
	}
	if(redTunnel != null)
	{
		redTunnel.angle += elapsed * 3.5;
	}
	banduJunk += elapsed * 2.5;
	if(badaiTime)
	{
		dad.angle += elapsed * 50;
	}

	if (SONG.song.toLowerCase() == 'devastation') {

		/*if (poiping) {
			what.forEach(function(spr:FlxSprite){
				spr.x += Math.abs(Math.sin(elapsed)) * gasw2[spr.ID];
				if (spr.x > 3000 && !lanceyLovesWow2[spr.ID]) {
					lanceyLovesWow2[spr.ID] = true;
					trace('whattttt ${spr.ID}');
					whatDidRubyJustSay++;
				}
			});
			if (whatDidRubyJustSay >= 2) poiping = false;
		}
		else if (canPoip) {
			trace("ON TO THE POIPIGN!!!");
			canPoip = false;
			lanceyLovesWow2 = [false, false];
			whatDidRubyJustSay = 0;
			new FlxTimer().start(FlxG.random.float(3, 6.3), function(tmr:FlxTimer){
				what.forEach(function(spr:FlxSprite){
					spr.visible = true;
					spr.x = FlxG.random.int(-2000, -3000);
					gasw2[spr.ID] = FlxG.random.int(600, 1200);
					if (spr.ID == 1) {
						trace("POIPING...");
						poiping = true;
						canPoip = true;
					}
				});
			});
		}
		what.forEach(function(spr:FlxSprite){
			var daCoords = wow2[spr.ID];
			daCoords[4] == 1 ? 
			spr.y = Math.cos(elapsedtime + spr.ID) * daCoords[3] + daCoords[1]: 
			spr.y = Math.sin(elapsedtime) * daCoords[3] + daCoords[1];
			spr.y += 45;
			var dontLookAtAmongUs:Float = Math.sin(elapsedtime * 1.5) * 0.05 + 0.95;
			spr.scale.set(dontLookAtAmongUs - 0.15, dontLookAtAmongUs - 0.15);
			if (dad.POOP) spr.angle += (Math.sin(elapsed * 2) * 0.5 + 0.5) * spr.ID == 1 ? 0.65 : -0.65;
		});*/

		playerStrums.forEach(function(spr:FlxSprite){
			noteJunksPlayer[spr.ID] = spr.y;
		});
		opponentStrums.forEach(function(spr:FlxSprite){
			noteJunksDad[spr.ID] = spr.y;
		});
		if (unfairPart) {
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin(elapsedtime + (spr.ID)) * 300);
				spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos(elapsedtime + (spr.ID)) * 300);
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 300);
				spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos((elapsedtime + (spr.ID)) * 2) * 300);
			});
		}
		if (SONG.notes[Math.floor(curStep / 16)] != null) {
			if (SONG.notes[Math.floor(curStep / 16)].altAnim && !unfairPart) {
				var krunkThing = 60;
				poopStrums.forEach(function(spr:StrumNote)
				{
					spr.x = arrowJunks[spr.ID + 4][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
					spr.y = swagThings.members[spr.ID].y + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;

					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;

					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);

					spr.scale.x += 0.2;
					spr.scale.y += 0.2;
					
					spr.scale.x *= 1.5;
					spr.scale.y *= 1.5;
				});

				altNotes.forEachAlive(function(spr:Note){
					spr.x = arrowJunks[(spr.noteData % 4) + 4][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing;
					#if debug
					if (FlxG.keys.justPressed.SPACE) {
						trace(arrowJunks[(spr.noteData % 4) + 4][0]);
						trace(spr.noteData);
						trace(spr.x == arrowJunks[(spr.noteData % 4) + 4][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing);
					}
					#end
				});
			}
			if (!SONG.notes[Math.floor(curStep / 16)].altAnim && wtfThing) {
				
				
			}
		}

		
	}



    //welcome to 3d sinning avenue
	if(funnyFloatyBoys.contains(dad.curCharacter.toLowerCase()) && canFloat && orbit)
	{
		switch(dad.curCharacter) 
		{
			case 'bandu-candy':
				dad.x += Math.sin(elapsedtime * 50) / 9;
			case 'bandu':
				dad.x = boyfriend.getMidpoint().x + Math.sin(banduJunk) * 500 - (dad.width / 2);
				dad.y += (Math.sin(elapsedtime) * 0.2);
	
				/*
				var deezScale =	(
					!dadFront ?
					Math.sqrt(
				boyfriend.getMidpoint().distanceTo(dad.getMidpoint()) / 500 * 0.5):
				Math.sqrt(
				(500 - boyfriend.getMidpoint().distanceTo(dad.getMidpoint())) / 500 * 0.5 + 0.5));
				dad.scale.set(deezScale, deezScale);
				dadmirror.scale.set(deezScale, deezScale);
				*/
	
				if ((Math.sin(banduJunk) >= 0.95 || Math.sin(banduJunk) <= -0.95) && !hasJunked){
					dadFront = !dadFront;
					hasJunked = true;
				}
				if (hasJunked && !(Math.sin(banduJunk) >= 0.95 || Math.sin(banduJunk) <= -0.95)) hasJunked = false;
	
				dad.visible = !dadFront;
			case 'badai':
				dad.angle += elapsed * 10;
				dad.y += (Math.sin(elapsedtime) * 0.6);
			default:
				dad.y += (Math.sin(elapsedtime) * 0.6);
		}
	}
	if(badai != null)
	{
		switch(badai.curCharacter) 
		{
			case 'bandu':
				badai.x = boyfriend.getMidpoint().x + Math.sin(banduJunk) * 500 - (dad.width / 2);
		    	badai.y += (Math.sin(elapsedtime) * 0.2);
	
				/*
				var deezScale =	(
					!dadFront ?
					Math.sqrt(
				boyfriend.getMidpoint().distanceTo(dad.getMidpoint()) / 500 * 0.5):
				Math.sqrt(
				(500 - boyfriend.getMidpoint().distanceTo(dad.getMidpoint())) / 500 * 0.5 + 0.5));
				dad.scale.set(deezScale, deezScale);
				dadmirror.scale.set(deezScale, deezScale);
				*/
	
				if ((Math.sin(banduJunk) >= 0.95 || Math.sin(banduJunk) <= -0.95) && !hasJunked){
					dadFront = !dadFront;
					hasJunked = true;
				}
				if (hasJunked && !(Math.sin(banduJunk) >= 0.95 || Math.sin(banduJunk) <= -0.95)) hasJunked = false;
	
				badai.visible = !dadFront;
			case 'badai':
				badai.angle = Math.sin(elapsedtime) * 15;
				badai.x += Math.sin(elapsedtime) * 0.6;
				badai.y += (Math.sin(elapsedtime) * 0.6);
			default:
				badai.y += (Math.sin(elapsedtime) * 0.6);
		}
	}
	if (littleIdiot != null) {
		if(funnyFloatyBoys.contains(littleIdiot.curCharacter.toLowerCase()) && canFloat && poipInMahPahntsIsGud)
		{
			littleIdiot.y += (Math.sin(elapsedtime) * 0.75);
			littleIdiot.x = 200 + Math.sin(elapsedtime) * 425;
		}
	}
	if (swaggy != null) {
		if(funnyFloatyBoys.contains(swaggy.curCharacter.toLowerCase()) && canSlide)
		{
			swaggy.x += (Math.sin(elapsedtime) * 1.4);
		}
	}
	if(funnySideFloatyBoys.contains(dad.curCharacter.toLowerCase()) && canSlide)
	{
		dad.x += (Math.cos(elapsedtime) * 0.6);
	}
	if(funnyFloatyBoys.contains(boyfriend.curCharacter.toLowerCase()) && canFloat)
	{
		boyfriend.y += (Math.sin(elapsedtime) * 0.6);
	}

	if (SONG.song.toLowerCase() == 'cheating') // fuck you
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x -= Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1);
				spr.x += Math.sin(elapsedtime) * 1.5;
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x += Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1);
				spr.x -= Math.sin(elapsedtime) * 1.5;
			});
		}
	if (SONG.song.toLowerCase() == 'technology')
	{
				playerStrums.forEach(function(spr:FlxSprite)
				{
				    spr.y += Math.sin(elapsedtime) * ((spr.ID % 0.2) == 0 ? 0.005 : -0.005);
				    spr.y -= Math.sin(elapsedtime) * 0.05;
					spr.x -= Math.sin(elapsedtime) * ((spr.ID % 0.1) == 0 ? 0 : -0);
					spr.x += Math.sin(elapsedtime) * 0.1;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
				    spr.y -= Math.sin(elapsedtime) * ((spr.ID % 0.2) == 0 ? 0.005 : -0.005);
				    spr.y += Math.sin(elapsedtime) * 0.05;
					spr.x -= Math.sin(elapsedtime) * ((spr.ID % 0.1) == 0 ? 0 : -0);
					spr.x += Math.sin(elapsedtime) * 0.1;
			    });
	}
	if (SONG.song.toLowerCase() == 'disposition')
		    {
				if (ClientPrefs.laneunderlay){
				    laneunderlay.x -= Math.sin(elapsedtime) * 1.3;
					laneunderlayOpponent.visible = false;
				}

				for(str in playerStrums)
				{
					str.angle = 60*Math.cos((elapsedtime*2)+str.ID*2);
					str.y = strumLine.y+(20*Math.sin((elapsedtime*2)+str.ID*2));
				}
			
				for(str in opponentStrums)
				{
					str.angle = 60*Math.cos((elapsedtime*2)+str.ID*2);
					str.y = strumLine.y+(20*Math.sin((elapsedtime*2)+str.ID*2));
				}

				playerStrums.forEach(function(spr:FlxSprite) // WHY DID THE FPS THING STOP WORKING GRGRGRGGRGRGRGRGGRRG
				{
					spr.x -= Math.sin(elapsedtime) * 1.3;
					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);
	
					spr.scale.x += 0.3;
					spr.scale.y += 0.3;
	
					spr.scale.x *= 1.15;
					spr.scale.y *= 1.15;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += Math.sin(elapsedtime) * 1.3;

					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);
	
					spr.scale.x += 0.3;
					spr.scale.y += 0.3;
	
					spr.scale.x *= 1.15;
					spr.scale.y *= 1.15;
				});
			}
	if (SONG.song.toLowerCase() == 'reality breaking' && ClientPrefs.chromaticAberration)
		{
			
			#if windows
			grain_shader.update(elapsed);
			if(stupidInt > 0 && !stupidBool)
				{
					grain_shader.shader.grainsize.value = [FlxG.random.float(1, 2)];
					grain_shader.shader.lumamount.value = [FlxG.random.float(1, 2)];
					if(ClientPrefs.chromaticAberration)
						{
							shader_chromatic_abberation.setChrome(FlxG.random.float(0.01, 0.015));
						}
					stupidInt -= 1;
				}
			else if(!stupidBool)
				{
					doneloll2 = false;
				}
			else
				{
					if(ClientPrefs.chromaticAberration)
						{
					shader_chromatic_abberation.setChrome(FlxG.random.float(0.01, 0.015));
						}
					grain_shader.shader.grainsize.value = [FlxG.random.float(1, 2)];
					grain_shader.shader.lumamount.value = [FlxG.random.float(1, 2)];
				}
			if(!doneloll2)
				{
					grain_shader.shader.grainsize.value = [0.01];
					grain_shader.shader.lumamount.value = [0.05];
					if(ClientPrefs.chromaticAberration)
						{
					shader_chromatic_abberation.setChrome(FlxG.random.float(0.003, 0.005));
						}
				}
			#end
		}
	if (SONG.song.toLowerCase() == 'unfairness') // fuck you x2
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin(elapsedtime + (spr.ID)) * 300);
					spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos(elapsedtime + (spr.ID)) * 300);
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 300);
					spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos((elapsedtime + (spr.ID)) * 2) * 300);
				});
			}

		if (oppositionMoment)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 12) - (spr.width / 7)) + (Math.sin(elapsedtime + (spr.ID)) * 500);
				spr.x += 500; 
				spr.y += Math.sin(elapsedtime) * Math.random();
				spr.y -= Math.sin(elapsedtime) * 1.3;
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 12) - (spr.width / 7)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 500);
				spr.x += 500; 
				spr.y += Math.sin(elapsedtime) * Math.random();
				spr.y -= Math.sin(elapsedtime) * 1.3;
			});

			for(str in playerStrums)
			{
				str.angle = -360*Math.cos((elapsedtime*2)+str.ID*2);
			}
			
			for(str in opponentStrums)
			{
				str.angle = 360*Math.cos((elapsedtime*2)+str.ID*2);
			}
		}
	/*if (SONG.song.toLowerCase() == 'furiosity') // is cool, ratio
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.y += Math.sin(elapsedtime) * Math.random();
					spr.y -= Math.sin(elapsedtime) * 0.3;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.y -= Math.sin(elapsedtime) * Math.random();
					spr.y += Math.sin(elapsedtime) * 0.3;
				});
			}*/ // leaving these here mostly for archive
	if(SONG.song.toLowerCase() == 'rebound')
	{
		for(str in playerStrums)
		{
			str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
			str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
		}

		for(str in opponentStrums)
		{
		    str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
			str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
		}
	}
	    	if (SONG.song.toLowerCase() == 'disruption') // deez all day
				{
				var krunkThing = 60;
	
				poop.alpha = Math.sin(elapsedtime) / 2.5 + 0.4;
	
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = arrowJunks[spr.ID + 4][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
					spr.y = arrowJunks[spr.ID + 4][1] + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
	
					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);

					spr.scale.x += 0.2;
					spr.scale.y += 0.2;

					spr.scale.x *= 1.5;
					spr.scale.y *= 1.5;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = arrowJunks[spr.ID][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
					spr.y = arrowJunks[spr.ID][1] + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
	
					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);
	
					spr.scale.x += 0.2;
					spr.scale.y += 0.2;
	
					spr.scale.x *= 1.5;
		     		spr.scale.y *= 1.5;
				});
	
				notes.forEachAlive(function(spr:Note){
					if (spr.mustPress) {
						spr.x = arrowJunks[spr.noteData + 4][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing;
						spr.y = arrowJunks[spr.noteData + 4][1] + Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1) * krunkThing;

						spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1)) / 4;

						spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) / 2);
	
						spr.scale.x += 0.2;
						spr.scale.y += 0.2;

						spr.scale.x *= 1.5;
						spr.scale.y *= 1.5;
						}
				     	else
					    {
						spr.x = arrowJunks[spr.noteData][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing;
						spr.y = arrowJunks[spr.noteData][1] + Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1) * krunkThing;

						spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1)) / 4;
	
						spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) / 2);
	
						spr.scale.x += 0.2;
						spr.scale.y += 0.2;
	
						spr.scale.x *= 1.5;
						spr.scale.y *= 1.5;
					}
				});
	    	}
			if(badai != null)
			{
				if ((badai.animation.finished || badai.animation.curAnim.name == 'idle') && badai.holdTimer <= 0 && curBeat % 2 == 0)
					badai.dance();
			}
			if (swaggy != null) {
				if (swaggy.holdTimer <= 0 && curBeat % 2 == 0 && swaggy.animation.finished)
					swaggy.dance();
			}
			if (swagBombu != null) {
				if (swagBombu.holdTimer <= 0 && curBeat % 2 == 0 && swagBombu.animation.finished)
					swagBombu.dance();
			}
			if (littleIdiot != null) {
				if (littleIdiot.animation.finished && littleIdiot.holdTimer <= 0 && curBeat % 2 == 0) littleIdiot.dance();
			}

		#if windows
		if (SONG.song.toLowerCase() != 'lacuna') {
	    	FlxG.camera.setFilters([new ShaderFilter(screenshader.shader)]); // this is very stupid but doesn't effect memory all that much so
		}
		if (SONG.song.toLowerCase() == 'lacuna') {
			camHUD.setFilters([new ShaderFilter(screenshader.shader)]);
		}
		#end
		if (shakeCam && eyesoreson)
		{
			if (SONG.song.toLowerCase() != 'lacuna') {
		    	FlxG.camera.shake(0.015, 0.015);
		    	if(gf.animOffsets.exists('scared')) {
	     			gf.playAnim('scared', true);
		    	}
		    }
			if (SONG.song.toLowerCase() == 'lacuna') {
				camHUD.shake(0.010, 0.010);
			}
		}
		if (shakeCamALT && eyesoreson)
		{
			FlxG.camera.shake(0.015, 0.015);
			if(gf.animOffsets.exists('scared')) {
				gf.playAnim('scared', true);
			}
			/*if(boyfriend.animOffsets.exists('scared')) {
				boyfriend.playAnim('scared', true);
			}*/
		}
		screenshader.shader.uTime.value[0] += elapsed;
		if (shakeCam && eyesoreson) {
			screenshader.shader.uampmul.value[0] = 1;
		} else {
			screenshader.shader.uampmul.value[0] -= (elapsed / 2);
		}
		screenshader.Enabled = shakeCam && eyesoreson;

		if (daspinlmao)
		{
			camHUD.angle += elapsed * 30;
		}

		if (daleftspinlmao)
		{
			camHUD.angle -= elapsed * 30;
		} 

	for(i in 0...notesHitArray.length)
	{
		var cock:Date = notesHitArray[i];
		if (cock != null)
			if (cock.getTime() + 2000 < Date.now().getTime())
			notesHitArray.remove(cock);
	}
	nps = Math.floor(notesHitArray.length / 2);

	/*if (FlxG.keys.justPressed.NINE)
	{
		iconP1.swapOldIcon();
	}*/
	switch (SONG.song.toLowerCase())
	{
		case 'devastation':
			switch (curBeat)
			{
				case 5: // 92
					//dad.POOP = true; // WORK WORK WOKR< WOKRMKIEPATNOLIKSEHGO:"IKSJRHDLG"H
					new FlxTimer().start(0.5, function(deez:FlxTimer){
						FlxTween.tween(swaggy, {x: swaggy.x + 1000}, 1.05, {ease:FlxEase.cubeInOut});
						swagThings.forEach(function(spr:FlxSprite){
							FlxTween.tween(spr, {y: spr.x + 1000}, 1.2, {ease:FlxEase.circOut});
						});
						poopStrums.forEach(function(spr:StrumNote){
							FlxTween.tween(spr, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * spr.ID)});
						});
					});
				case 6465:
					unfairPart = true;
					gfSpeed = 1;
					playerStrums.forEach(function(spr:FlxSprite){
						spr.scale.set(0.7, 0.7);
					});
					what.forEach(function(spr:FlxSprite){
						spr.alpha = 0;
					});
					gfSpeed = 1;
					wtfThing = false;
					var dumbStupid = new FlxSprite().loadGraphic(Paths.image('bambi/poop'));
					dumbStupid.scrollFactor.set();
					dumbStupid.screenCenter();
					littleIdiot.alpha = 0;
					littleIdiot.visible = true;
					add(dumbStupid);
					dumbStupid.cameras = [camHUD];
					dumbStupid.color = FlxColor.BLACK;
					health = 2;
					theFunne = false;
					poopStrums.visible = false;
					FlxTween.tween(dumbStupid, {alpha: 1}, 0.2, {onComplete: function(twn:FlxTween){
						FlxTween.tween(dumbStupid, {alpha: 0}, 1.2, {onComplete: function(twn:FlxTween){
							trace('hi'); // i actually forgot what i was going to put here
						}});
					}});
				case 11231:
					vocals.volume = 1;
				case 11659:
					FlxTween.tween(littleIdiot, {alpha: 1}, 1.4, {ease: FlxEase.circOut});
				case 6675:
					FlxTween.tween(littleIdiot, {"scale.x": littleIdiot.scale.x + 2.1, "scale.y": littleIdiot.scale.y + 2.1}, 1.35, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween){
						iconP2.animation.play('bambi-unfair');
						orbit = false;
						dad.visible = swaggy.visible = false;
						var derez = new FlxSprite(dad.getMidpoint().x, dad.getMidpoint().y).loadGraphic(Paths.image('bambi/monkey_guy'));
						derez.setPosition(derez.x - derez.width / 2, derez.y - derez.height / 2);
						derez.antialiasing = false;
						add(derez);
						var deez = new FlxSprite(swaggy.getMidpoint().x, swaggy.getMidpoint().y).loadGraphic(Paths.image('bambi/monkey_person'));
						deez.setPosition(deez.x - deez.width / 2, deez.y - deez.height / 2);
						deez.antialiasing = false;
						add(deez);
						var swagsnd = new FlxSound().loadEmbedded(Paths.sound('suck'));
						swagsnd.play(true);
						var whatthejunk = new FlxSound().loadEmbedded(Paths.sound('suckEnd'));
						littleIdiot.playAnim('inhale');
						littleIdiot.animation.finishCallback = function(d:String) {
							swagsnd.stop();
							whatthejunk.play(true);
							littleIdiot.animation.finishCallback = null;
						};
						new FlxTimer().start(0.2, function(tmr:FlxTimer){
							FlxTween.tween(deez, {"scale.x": 0.1, "scale.y": 0.1, x: littleIdiot.getMidpoint().x - deez.width / 2, y: littleIdiot.getMidpoint().y - deez.width / 2 - 400}, 0.65, {ease: FlxEase.quadIn});
							FlxTween.angle(deez, 0, 360, 0.65, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween) deez.kill()});

							FlxTween.tween(derez, {"scale.x": 0.1, "scale.y": 0.1, x: littleIdiot.getMidpoint().x - derez.width / 2 - 100, y: littleIdiot.getMidpoint().y - derez.width / 2 - 500}, 0.65, {ease: FlxEase.quadIn});
							FlxTween.angle(derez, 0, 360, 0.65, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween) derez.kill()});

							new FlxTimer().start(1, function(tmr:FlxTimer) poipInMahPahntsIsGud = true);
						});
					}});
			}
		case 'antagonism':
			if(ClientPrefs.flashing) FlxG.camera.shake(0.005, Conductor.crochet / 1000);
			switch(curBeat)
			{
				case 0:
					FlxTween.tween(badai, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redBG, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redTunnel, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
				case 292:
					FlxTween.tween(dad, {"scale.x": 0, "scale.y": 0}, 1, {ease: FlxEase.quadIn});
					redTunnel.active = true;
					redTunnel.visible = true;
					FlxTween.tween(FlxG.camera, {zoom: 0.67}, 3, {ease: FlxEase.expoOut,});	
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 5, {ease: FlxEase.circInOut});
				case 350:
					badai.visible = true;
					FlxTween.tween(badai, {"scale.x": 1, "scale.y": 1}, 1, {ease: FlxEase.cubeOut});
				case 356:
					dad.visible = false;
					badaiTime = true;
					redBG.visible = true;
					redBG.active = true;
					FlxG.camera.flash(FlxColor.WHITE, 1);
					iconP2.animation.play('badai');
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
				    FlxG.camera.flash(FlxColor.WHITE, 1);
			}
		case 'splitathon' | 'old-splitaton':
			switch (curStep)
			{
				case 4736:
					dad.animation.play('scared', true);
				case 4800:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					splitterThonDave('what');
					if (BAMBICUTSCENEICONHURHURHUR == null)
					{
						BAMBICUTSCENEICONHURHURHUR = new HealthIcon("dave", false);
						BAMBICUTSCENEICONHURHURHUR.y = healthBar.y - (BAMBICUTSCENEICONHURHURHUR.height / 2);
						add(BAMBICUTSCENEICONHURHURHUR);
						BAMBICUTSCENEICONHURHURHUR.cameras = [camHUD];
						BAMBICUTSCENEICONHURHURHUR.x = -100;
						FlxTween.linearMotion(BAMBICUTSCENEICONHURHURHUR, -100, BAMBICUTSCENEICONHURHURHUR.y, iconP2.x, BAMBICUTSCENEICONHURHURHUR.y, 0.3, true, {ease: FlxEase.expoInOut});
						new FlxTimer().start(0.3, FlingCharacterIconToOblivionAndBeyond);
					}
				case 5824:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					splitathonExpression('bambi-what', -100, 550);
				case 6080:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					splitterThonDave('happy');
				case 8384:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					splitathonExpression('bambi-corn', -100, 550);
			}
		case 'insanity':
			switch (curStep)
			{
				case 660 | 680:
					FlxG.sound.play(Paths.sound('static'), 0.1);
                    insanityRed.visible = true;
				case 664 | 684:
					insanityRed.visible = false;
				case 1176:
					FlxG.sound.play(Paths.sound('static'), 0.1);
					insanityRed.visible = true;
				case 1180:
					dad.animation.play('scared', true);
			}
		case 'furiosity':
			switch (curStep)
			{
				case 256:
					camZoomSnap = true;
				case 896:
					camZoomSnap = false;
				case 1305:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					redSky.visible = false;
					//redPlatform.visible = false;
					backyardnight.visible = true;
			}
		case 'acquaintance':
			switch (curStep)
			{
				case 0:
					blackScreendeez.alpha = 1;
				case 1:
					FlxTween.tween(blackScreendeez, {alpha:0}, 1);
					camZooming = true;
				case 504:
					defaultCamZoom = 1.25;
					FlxTween.tween(blackBG, {alpha:1}, 1);
				case 508:
					defaultCamZoom = 2;	
				case 511:
					camHUD.alpha = 0;
				case 512:
					defaultCamZoom = 0.5;
					fartt = true;
					bALLS = true;
					camZoomSnap = true;
					autoCamZoom = false;
					FlxTween.tween(camHUD, {alpha:1}, 1);
				case 1535: // what the fuck??
			    	fartt = false;
					fartt2 = false;
					camZoomSnap = false;
					autoCamZoom = true;
					camHUD.angle = 0;
					camHUD.flash(FlxColor.WHITE, 1);
			}
		case 'polygonized':
			switch (curStep)
			{
				case 0:
					hideshit();
					add(blackScreen);
				case 1:
					FlxTween.tween(camHUD, {alpha:0}, 1);
				case 60:
					FlxTween.tween(blackScreen, {alpha:0}, 1);
				case 127:
					showshit();
					FlxTween.tween(camHUD, {alpha:1}, 1);
				case 1024 | 1312 | 1424 | 1552 | 1664:
					shakeCam = true;
				case 1152 | 1408 | 1472 | 1600 | 2048 | 2176:
					shakeCam = false;
				case 2175:
					defaultCamZoom = 1.45;	
					FlxTween.tween(gf, {alpha:0}, 1);
					FlxTween.tween(dad, {alpha:0}, 1);
					FlxTween.tween(blackScreendeez, {alpha:0.5}, 1);
					FlxTween.tween(blackBG, {alpha:1}, 1);
				case 2434:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					blackBG.alpha = 0;
					FlxTween.tween(camHUD, {alpha:0}, 2);
					redSky.visible = false;
					//redPlatform.visible = false;
					backyardnight.visible = true;
					blackScreendeez.alpha = 0;
					defaultCamZoom = 0.9;
					gf.alpha = 1;
					dad.alpha = 1;

			}
		case 'mealie':
			switch (curStep)
			{
		    	case 1855:
		    		camZoomSnap = true;
			}
		case 'rebound':
			switch (curStep)
			{
				case 0:
					hideshit();
				case 15:
					showonlystrums();
			}
		case 'shattered':
			switch (curStep)
			{
				case 0:
					hideshit();
				case 1:
					camHUD.alpha = 0;
					showshit();
				case 120:
					showHUDFade();
				case 895:
					add(blackScreen);
				case 896:
					FlxTween.tween(blackScreen, {alpha:0}, 10);
				case 1024:
					FlxTween.tween(blackScreen, {alpha:1}, 5);
				case 1090:
					FlxTween.tween(blackScreen, {alpha:0}, 2);
				case 1665:
					boyfriend.playAnim('hurt', true);
				case 1792:
					redGlow.visible = true;
			}
		case 'supplanted':
			switch (curStep)
			{
				case 128:
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					redGlow.visible = true;
				case 802:
					defaultCamZoom = 1.5;
				case 805:
					defaultCamZoom = 0.85;
				case 859:
					defaultCamZoom = 1.75;
				case 863:
					defaultCamZoom = 0.85;
				case 892:
					defaultCamZoom = 1.5;
				case 895:
					defaultCamZoom = 0.85;
				case 944 | 1343 | 2176:
					camZoomSnap = false;
				case 720 | 960 | 1856:
					camZoomSnap = true;
				case 1344:
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
				case 2368:
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					redGlow.visible = false;
					FlxTween.tween(camFollowPos, {y:camFollowPos.y -1000}, 5, {ease: FlxEase.expoOut,}); 
					camZooming = false;
				case 2384: // 2384
					add(blackScreen);
				case 2386: // 2386
					FlxTween.tween(blackScreen, {alpha:1}, 5);
					camZooming = true;
				case 2656: // 2656
			    	FlxTween.tween(blackScreen, {alpha:0}, 3);
				case 2688:
					redGlow.visible = true;
					camZooming = true;
				case 2960:
					dad.color = 0xFF000000;
					defaultCamZoom = 1.35;

			}
		/*case 'technology':
			switch (curBeat)
			{*/
			/*	case 317: // 317
				    swagSpeed = 1.6;*/
			/*	case 581:
					add(blackScreen);
				}
			}*/
		case '8-28-63':
			switch (curStep)
			{
				case 0:
					gf.alpha = 0;
				case 639 | 1920:
					FlxG.sound.play(Paths.sound('static'), 0.1);
					soscaryishitmypants.visible = true;
				case 1152 | 2432:
					soscaryishitmypants.visible = false;
			}
	    case 'roundabout':
			switch(curStep)
			{
				case 1:
			     	FlxTween.tween(FlxG.camera, {zoom:1.20}, 17);
				case 239:
					resyncVocals();
				case 256:
					camZoomSnap = true;
			//	case 240:
					//daCountDownMidSong(); // can someone do this idk how to make a good code of this lol
			}
		case 'fast-food':
			switch(curStep)
	    	{
				case 120:
					camZoomSnap = true;
				case 1567:
					camZoomSnap = false;
			}
		case 'upheaval':
			switch(curStep)
	    	{
				case 0:
					hideshit();
				case 1: // oh god
		     		healthBar.alpha = 0;
		      		healthBarBG.alpha = 0;
			    	iconP1.alpha = 0;
			       	iconP2.alpha = 0;
			    	scoreTxt.alpha = 0;
			    	judgementCounter.alpha = 0;
		    		songWatermark.alpha = 0;
			    	creditsWatermark.alpha = 0;
					timeBarBG.alpha = 0;
					timeBar.alpha = 0;
					timeTxt.alpha = 0;
				case 2:
					showshit();
					FlxTween.tween(FlxG.camera, {zoom: 0.7}, 1.85, {ease: FlxEase.expoOut,});
				case 133:
					FlxTween.tween(scoreTxt, {alpha:1}, 3);
					FlxTween.tween(judgementCounter, {alpha:1}, 3);
					FlxTween.tween(songWatermark, {alpha:1}, 3);
					FlxTween.tween(creditsWatermark, {alpha:1}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 164:
					FlxTween.tween(timeBarBG, {alpha:1}, 3);
					FlxTween.tween(timeBar, {alpha:1}, 3);
					FlxTween.tween(timeTxt, {alpha:1}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 197:
					FlxTween.tween(healthBar, {alpha:ClientPrefs.healthBarAlpha}, 3);
					FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 4);
				case 262:
					FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 293:
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
                case 325:
					if(ClientPrefs.flashing) camHUD.shake(0.0035, 2);
			}
		case 'lacuna':
			switch(curStep)
	    	{
                case 1032:
					oppositionMoment = true;
					if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 1);
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					shakeCam = true;
				case 2064:
					oppositionMoment = false;
					guh();
					if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 1);
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					shakeCam = false;
					camHUD.alpha = 0.75;
                case 2826:
					FlxTween.tween(camHUD, {alpha:1}, 0.75);
				case 3079:
					oppositionMoment = true;
					if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 1); 
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					shakeCam = true;
				case 4614:
		    		shakeCam = false;
				case 4873:
					FlxTween.tween(camHUD, {alpha:0}, 10);
					oppositionMoment = false;
					guh();
				case 5575:
					FlxTween.tween(dad, {alpha:0}, 0.3);
					FlxTween.tween(evilTrail, {alpha:0}, 0.3);
				case 5591:
					FlxTween.tween(gf, {alpha:0}, 0.3);
				case 5608:
					FlxTween.tween(poopBG, {alpha:0}, 0.3);
                case 5624:
					FlxTween.tween(boyfriend, {alpha:0}, 1);
			}
		/*case 'tutorial':
		    switch (curStep)
			{
			case 40:
				var file:String = Paths.json('tutorial' + '/dialogMid1'); 
				if (OpenFlAssets.exists(file)) {
					dialogueJson = DialogueBoxPsych.parseDialogue(file);
				}
	            dialogBullshitStart();
				trace("STARTED THE MID SONG DIALOGUE!!");
			} // testing*/
	}

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage) // didnt want to change this to rgb like on 2.5 (i hate rgb values )
		{
			case '3dRed' | '3dScary' | '3dFucked' | 'houseNight' | 'houseroof' | 'farmNight': // Dark character thing
                {
                    dad.color = 0xFF878787;
                    gf.color = 0xFF878787;
                    boyfriend.color = 0xFF878787;

					if (SONG.player2 == 'bambi-god2d')
					{
						dad.color = 0xFFFFFFFF;
					}
                }
			case 'spooky': // Darker character thing
				{
					dad.color = 0xFF383838;
					gf.color = 0xFF383838;
					boyfriend.color = 0xFF383838;
				}
			case 'bambersHell': // glowing guy
				{
					gf.color = 0xFF878787;
					boyfriend.color = 0xFF878787;
				}
			case 'farmSunset' | 'houseSunset': // sunset !!
				{
					dad.color = 0xFFFF8F65;
					gf.color = 0xFFFF8F65;
		    		boyfriend.color = 0xFFFF8F65;
				}
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

	// hi
	if(ClientPrefs.lang == 'English')
		{
			if(ratingName == '?') {
				if(!ClientPrefs.classicScore) {
					scoreTxt.text =	'NPS: ' + nps + ' | Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Accuracy: 0% | N/A';
				}
				if(ClientPrefs.classicScore) {
					scoreTxt.text = 'Score:' + songScore + ' | Misses:' + songMisses + ' | Accuracy:0%';
				}
	
			} else {
	
				if(!ClientPrefs.classicScore) {
					 scoreTxt.text =  'NPS: ' + nps + ' | Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%' + ' | (' + ratingFC + ') ' + ratingName;
				}
				if(ClientPrefs.classicScore) {
					scoreTxt.text = 'Score:' + songScore + ' | Misses:' + songMisses + ' | Accuracy:' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
				}
	
			}
	
			if(cpuControlled) {
				scoreTxt.text = 'BOTPLAY';
			}
	
			if(practiceMode) {
	
				if(!ClientPrefs.classicScore) {
					scoreTxt.text = 'NPS: ' + nps + ' | Combo Breaks: ' + songMisses + ' | Practice Mode ';
				}
	
				if(ClientPrefs.classicScore) {
					scoreTxt.text = 'Misses:' + songMisses + ' | Practice Mode ';
				}
	
			}
		} 
		else if(ClientPrefs.lang == 'Spanish/Espanol')
		{
			if(ratingName == '?') {
				if(!ClientPrefs.classicScore) {
					scoreTxt.text =	'NPS: ' + nps + ' | Puntos: ' + songScore + ' | Quiebres de Combo: ' + songMisses + ' | Presicion: 0% | N/A';
				}
				if(ClientPrefs.classicScore) {
					scoreTxt.text = 'Puntos:' + songScore + ' | Fallas:' + songMisses + ' | Precision:0%';
				}
	
			} else {
	
				if(!ClientPrefs.classicScore) {
					 scoreTxt.text =  'NPS: ' + nps + ' | Puntos: ' + songScore + ' | Quiebres de Combo: ' + songMisses + ' | Precision: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%' + ' | (' + ratingFC + ') ' + ratingName;
				}
				if(ClientPrefs.classicScore) {
					scoreTxt.text = 'Puntos:' + songScore + ' | Fallas:' + songMisses + ' | Presicion:' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
				}
	
			}
	
			if(cpuControlled) {
				scoreTxt.text = 'BOT';
			}
	
			if(practiceMode) {
	
				if(!ClientPrefs.classicScore) {
					scoreTxt.text = 'NPS: ' + nps + ' | Quiebres de Combo: ' + songMisses + ' | Modo Practica';
				}
	
				if(ClientPrefs.classicScore) {
					scoreTxt.text = 'Fallas:' + songMisses + ' | Modo Practica ';
				}
	
			}
		} // prob gonna rewrite this thing so it doesnt suck lololo

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					MusicBeatState.switchState(new GitarooPause());
				}
				else {
					if(FlxG.sound.music != null) {
						FlxG.sound.music.pause();
						vocals.pause();
					}
					PauseSubState.transCamera = camOther;
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
			
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
			{
                openChartEditor();
			}


			if (FlxG.keys.justPressed.F1 && !endingSong && !inCutscene) // if you have f1 as the debug key thing im so sorry
			{
				persistentUpdate = false;
				paused = true;
				cancelMusicFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				MusicBeatState.switchState(new CheaterState());
	
				#if desktop
		    	DiscordClient.changePresence("CHEATER FUCK YOU", null, null, true);
				#end
			}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.8)),Std.int(FlxMath.lerp(150, iconP1.height, 0.8)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.8)),Std.int(FlxMath.lerp(150, iconP2.height, 0.8)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
			FlxTween.tween(scoreTxt, {color:0xFFFF0000}, 0.05);
		}
		else if (healthBar.percent > 80)
		{
			iconP1.animation.curAnim.curFrame = 2;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
			FlxTween.tween(scoreTxt, {color:0xFFFFFFFF}, 0.03);
		}

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else if (healthBar.percent < 20)
			iconP2.animation.curAnim.curFrame = 2;
		else
			iconP2.animation.curAnim.curFrame = 0;

	/*	if(SONG.song.toLowerCase() == "ok")
			{
				if (healthBar.percent < 70)
				{
					FlxTween.tween(iconP1, {alpha:0}, 0.3);
     				FlxTween.tween(iconP2, {alpha:0}, 0.3);
				}
				else if (healthBar.percent > 80)
				{
					FlxTween.tween(iconP1, {alpha:1}, 0.3);
    				FlxTween.tween(iconP2, {alpha:1}, 0.3);
				}
				scoreTxt.alpha = 0.5;
				songWatermark.alpha = 0.5;
				creditsWatermark.alpha = 0.5;
				judgementCounter.alpha = 0.5;
			}*/

		if (FlxG.keys.justPressed.EIGHT && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

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

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Song and Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = SONG.song + ' (' + FlxStringUtil.formatTime(secondsTotal, false) + ')';
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			#if mac
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 0.97));
			camHUD.zoom = FlxMath.lerp(0.95, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 0.97));
			#else
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 0.97));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 0.97));
			#end
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		switch (curSong.toLowerCase())
		{
			case 'furiosity':
			switch (curBeat)
			{
				case 64:
					camZooming = true;
				case 287:
					camZooming = false;
			}
			case 'disposition':
				for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				opponentStrums.members[i].alpha = 0.2;
			}
	    }

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		var roundedSpeed:Float = FlxMath.roundDecimal(songSpeed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (altUnspawnNotes[0] != null)
		{
			if (altUnspawnNotes[0].strumTime - Conductor.songPosition < (SONG.song.toLowerCase() == 'unfairness' ? 15000 : 1500))
			{
				var dunceNote:Note = altUnspawnNotes[0];
				altNotes.add(dunceNote);
	
				var index:Int = altUnspawnNotes.indexOf(dunceNote);
				altUnspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					camFollowX = 0;
					camFollowY = 0;
					if(UsingNewCam) bfSingYeah = false;
					//boyfriend.animation.curAnim.finish();
				}
			}
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				if(!daNote.mustPress && ClientPrefs.middleScroll)
				{
					daNote.active = true;
					daNote.visible = false;
				}
				else if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// i am so fucking sorry for this if condition // i will not forig fve y ou
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if(daNote.mustPress) {
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				} else {
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;
				var center:Float = strumY + Note.swagWidth / 2;

				if(daNote.copyX) {
					daNote.x = strumX;
				}
				if(daNote.copyAngle) {
					daNote.angle = strumAngle;
				}
				if(daNote.copyAlpha) {
					daNote.alpha = strumAlpha;
				}
				if(daNote.copyY) {
					if (ClientPrefs.downScroll) {
						if (SONG.song.toLowerCase() == 'unfairness')
							daNote.y = (strumY
						    	+ (0.45 * FlxMath.roundDecimal(1 * daNote.LocalScrollSpeed, 2)) * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
						else
							daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

						if (daNote.isSustainNote) {
							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8;
								} else {
									daNote.y -= 19;
								}
							} 
							daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					} else {
						if (SONG.song.toLowerCase() == 'unfairness')
							daNote.y = (strumY
						    	+ (0.45 * FlxMath.roundDecimal(1 * daNote.LocalScrollSpeed, 2)) * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
						else
			     			daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

						if(daNote.mustPress || !daNote.ignoreNote)
						{
							if (daNote.isSustainNote
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					if (Paths.formatToSongPath(SONG.song) != 'tutorial')
						camZooming = true;

					if(daNote.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;

						} else if(!daNote.noAnimation) {
							var altAnim:String = "";
							var healthtolower:Float = 0.02;
	
							if (SONG.notes[Math.floor(curStep / 16)] != null)
							{
								if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation') {
									altAnim = '-alt';
								}
							}

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation') {
								altAnim = '-alt';
							}
						}

						if (SONG.notes[Math.floor(curStep / 16)] != null)
							{
								if (SONG.notes[Math.floor(curStep / 16)].altAnim)
									if (SONG.song.toLowerCase() != "cheating" || SONG.song.toLowerCase() != "disruption")
									{
										altAnim = '-alt';
									}
									else
									{
										healthtolower = 0.005;
									}
							}

						//'LEFT', 'DOWN', 'UP', 'RIGHT'
						var fuckingDumbassBullshitFuckYou:String;
						fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(daNote.noteData)) % 4];
						if(dad.nativelyPlayable)
						{
							switch(notestuffs[Math.round(Math.abs(daNote.noteData)) % 4])
							{
								case 'LEFT':
									fuckingDumbassBullshitFuckYou = 'RIGHT';
								case 'RIGHT':
									fuckingDumbassBullshitFuckYou = 'LEFT';
						    }
					    }
						(SONG.song.toLowerCase() == 'devastation' && !SONG.notes[Math.floor(curStep / 16)].altAnim && !wtfThing && dad.POOP) ? { // hi
							if (littleIdiot != null) littleIdiot.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true); 
							littleIdiot.holdTimer = 0;}: {
								if(badaiTime)
								{
									badai.holdTimer = 0;
									badai.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true);
								}
								dad.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true);
								dad.holdTimer = 0;
							}

						var char:Character = dad;
						var animToPlay:String = '';
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								animToPlay = 'singLEFT';
								switch (curSong.toLowerCase())
									{
									case 'sucked':
										if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
								    	if(ClientPrefs.flashing) FlxTween.tween(camHUD,{x: -25}, 0.1, {ease: FlxEase.expoOut});
									}
								if(ClientPrefs.followarrow) dadCamFollowY = 0;
								if(ClientPrefs.followarrow)	dadCamFollowX = -25;
							case 1:
								animToPlay = 'singDOWN';
								switch (curSong.toLowerCase())
									{
									case 'sucked':
										if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
										if(ClientPrefs.flashing) FlxTween.tween(camHUD,{y: 25}, 0.1, {ease: FlxEase.expoOut});
									}
								if(ClientPrefs.followarrow) dadCamFollowY = 25;
								if(ClientPrefs.followarrow)	dadCamFollowX = 0;
							case 2:
								animToPlay = 'singUP';
								switch (curSong.toLowerCase())
									{
									case 'sucked':
										if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
										if(ClientPrefs.flashing) FlxTween.tween(camHUD,{y: -25}, 0.1, {ease: FlxEase.expoOut});
									}
								if(ClientPrefs.followarrow) dadCamFollowY = -25;
								if(ClientPrefs.followarrow)	dadCamFollowX = 0;
							case 3:
								animToPlay = 'singRIGHT';
								switch (curSong.toLowerCase())
									{
									case 'sucked':
										if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
										if(ClientPrefs.flashing) FlxTween.tween(camHUD,{x: 25}, 0.1, {ease: FlxEase.expoOut});
									}
								if(ClientPrefs.followarrow) dadCamFollowY = 0;
								if(ClientPrefs.followarrow)	dadCamFollowX = 25;
							}

							//if(note.gfNote) {
							//	char = gf;
						//	}
				
							//if(char != null)
						//	{
							//	char.playAnim(animToPlay, true);
							//	char.holdTimer = 0;
						//	}

						if (UsingNewCam && !bfSingYeah) {
					    	isDadGlobal = true;
					    	moveCamera(true);
						}

						switch (curSong.toLowerCase()){
					    	case 'disposition' | 'disposition_but_awesome':
						      	if(ClientPrefs.flashing) camHUD.shake(0.0065, 0.1);
						    	if(health > 0.05) health -= 0.01;
						     	if(gf.animOffsets.exists('scared')) {
							    	gf.playAnim('scared', true); 
							    }
				      		case 'rebound':
					     		if(ClientPrefs.flashing) camHUD.shake(0.0025, 0.050);
					     		if(health > 0.5) health -= 0.01;
					    		if(gf.animOffsets.exists('scared')) {
						    		gf.playAnim('scared', true);
						    	}
				       	    case 'cheating':
						    	health -= healthtolower;		
					    		if(ClientPrefs.flashing) camHUD.shake(0.0045, 0.1);			
							case 'reality breaking':
								if(health > 0.5) health -= healthtolower;		
								if(ClientPrefs.flashing) camHUD.shake(0.0025, 0.050);
								if(ClientPrefs.chromaticAberration) doneloll2 = true;
								if(ClientPrefs.chromaticAberration) stupidInt = 10;				
					        case 'unfairness':
					     		health -= (healthtolower / 6);
						     	if(ClientPrefs.flashing) camHUD.shake(0.0045, 0.1);
								if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
				     		case 'disruption':
						    	health -= healthtolower / 2.65;
					    		if(ClientPrefs.flashing) camHUD.shake(0.0045, 0.1);
							case 'lacuna':
								if(health > 0.5) health -= 0.01;
								#if desktop
								if (oppositionMoment) {
									shakewindow(); // this shit kinda fuck ups the framerate LOL, is it a good idea to keep it?
								}
								#end	
						}
						if (UsingNewCam) dadSingYeah = true;
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
					daNote.hitByOpponent = true;

					callOnLuas('opponentNoteHit', [notes.members.indexOf(daNote), Math.abs(daNote.noteData), daNote.noteType, daNote.isSustainNote]);

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					switch (SONG.song.toLowerCase())
					{
						case 'devastation':
							if (unfairPart)
							{
								daNote.y = ((daNote.mustPress ? noteJunksPlayer[daNote.noteData] : noteJunksDad[daNote.noteData])- (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(1 * daNote.LocalScrollSpeed, 2))); // couldnt figure out this stupid mystrum thing
							}
							else
							{
								if (FlxG.save.data.downscroll)
									daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(songSpeed * 1, 2)));
								else
									daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(songSpeed * 1, 2)));
							}
						case 'algebra':
							if (FlxG.save.data.downscroll)
								daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(swagSpeed * daNote.LocalScrollSpeed, 2)));
							else
								daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(swagSpeed * daNote.LocalScrollSpeed, 2)));
						default:
							if (FlxG.save.data.downscroll)
								daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(songSpeed * daNote.LocalScrollSpeed, 2)));
							else
								daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(songSpeed * daNote.LocalScrollSpeed, 2)));
					}
					// trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.songSpeed));
	
					var strumliney = daNote.MyStrum != null ? daNote.MyStrum.y : strumLine.y;
	
					if (SONG.song.toLowerCase() == 'devastation') {
						if (unfairPart) strumliney = daNote.MyStrum != null ? daNote.MyStrum.y : strumLine.y;
						else strumliney = strumLine.y;
					}
	
					if (((daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumliney + 106 && FlxG.save.data.downscroll) && SONG.song.toLowerCase() != 'devastation') 
						|| (SONG.song.toLowerCase() == 'devastation' && unfairPart && daNote.y >= strumliney + 106) 
						|| (SONG.song.toLowerCase() == 'devastation' && !unfairPart && (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumliney + 106 && FlxG.save.data.downscroll)))
					{
						/*
						trace((SONG.song.toLowerCase() == 'devastation' && unfairPart && daNote.y >= strumliney + 106) );
						trace(daNote.y);
						*/
	
						daNote.active = false;
						daNote.visible = false;
	
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}
				// trace(daNote.y);

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * songSpeed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll || SONG.song.toLowerCase() == 'unfairness') doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
			if (isFunnySong) {
				altNotes.forEachAlive(function(daNote:Note)
				{
					if (daNote.y > FlxG.height * 2)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

                    if (curSong.toLowerCase() != 'sunshine')
				    	daNote.y = (altStrumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal((songSpeed + 1) * 1, 2)));

					if (daNote.wasGoodHit)
					{
						swaggy.playAnim('sing' + notestuffs[Math.round(Math.abs(daNote.noteData)) % 4], true);
						swaggy.holdTimer = 0;

						poopStrums.forEach(function(sprite:StrumNote)
						{
							if (Math.abs(Math.round(Math.abs(daNote.noteData)) % 4) == sprite.ID)
							{
								sprite.animation.play('confirm', true);
								if (sprite.animation.curAnim.name == 'confirm' && !curStage.startsWith('school') || !isPixelStage)
									{
									sprite.centerOffsets();
									sprite.offset.x -= 13;
									sprite.offset.y -= 13;
								}
								else
								{
									sprite.centerOffsets();
								}
								sprite.animation.finishCallback = function(name:String)
								{
									sprite.animation.play('static',true);
									sprite.centerOffsets();
								}
								
							}
						});

						if (SONG.needsVoices)
							vocals.volume = 1;

						daNote.kill();
						altNotes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
		}
		checkEventNote();
		moveCamera(isDadGlobal);

		#if debug
		if (FlxG.keys.justPressed.F3)
		{
			BAMBICUTSCENEICONHURHURHUR = new HealthIcon("bambi", false);
			BAMBICUTSCENEICONHURHURHUR.y = healthBar.y - (BAMBICUTSCENEICONHURHURHUR.height / 2);
			add(BAMBICUTSCENEICONHURHURHUR);
			BAMBICUTSCENEICONHURHURHUR.cameras = [camHUD];
			BAMBICUTSCENEICONHURHURHUR.x = -100;
			FlxTween.linearMotion(BAMBICUTSCENEICONHURHURHUR, -100, BAMBICUTSCENEICONHURHURHUR.y, iconP2.x, BAMBICUTSCENEICONHURHURHUR.y, 0.3, true, {ease: FlxEase.expoInOut});
			new FlxTimer().start(0.3, FlingCharacterIconToOblivionAndBeyond);
		}
		#end
		if (updatevels)
		{
			stupidx *= 0.98;
			stupidy += elapsed * 6;
			if (BAMBICUTSCENEICONHURHURHUR != null)
			{
				BAMBICUTSCENEICONHURHURHUR.x += stupidx;
				BAMBICUTSCENEICONHURHURHUR.y += stupidy;
			}
		}
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		for (i in shaderUpdates){
			i(elapsed);
		}
		#end
	}

	public function openChartEditor()
	{
		switch (curSong.toLowerCase())
		{
			case 'supernovae' | 'glitch':
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
				PlayState.SONG = Song.loadFromJson("cheating-hard", "cheating"); // you dun fucked up
				FlxG.save.data.cheatingFound = true;
				shakeCam = false;
				screenshader.Enabled = false;
				FlxG.switchState(new PlayState());
				return;
				// FlxG.switchState(new VideoState('assets/videos/fortnite/fortniteballs.webm', new CrasherState()));
			/*case 'disposition':
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
				PlayState.SONG = Song.loadFromJson("disposition_but_awesome", "disposition_but_awesome"); // funny secret
				shakeCam = false;
				#if windows
				screenshader.Enabled = false;
				#end
				FlxG.switchState(new PlayState());
				return;*/
			case 'cheating':
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
				PlayState.SONG = Song.loadFromJson("unfairness-hard", "unfairness"); // you dun fucked up again
				FlxG.save.data.unfairnessFound = true;
				shakeCam = false;
				screenshader.Enabled = false;
				FlxG.switchState(new PlayState());
				return;
			case 'unfairness':
				shakeCam = false;
				screenshader.Enabled = false;
				FlxG.switchState(new SusState());
				return;
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
			default:
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				persistentUpdate = false;
				paused = true;
				cancelMusicFadeTween();
				shakeCam = false;
				screenshader.Enabled = false;
				MusicBeatState.switchState(new ChartingState());
				chartingMode = true;
		
				#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
				#end
		}
	}

	public var isDead:Bool = false;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				if(shakeCam)
				{
					stupidThing = new Boyfriend(0, 0, "bambi3d");
					unlockCharacter("Expunged", "bambi3d", "3D Bambi", FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]), true);	
				}

				shakeCam = false;
				screenshader.Enabled = false;

				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;

			case 'Quick note spin':
				strumLineNotes.forEach(function(note)
					{
						quickSpin(note);
					});
			case 'Flash effect':
				var flashId:Int = Std.parseInt(value1);
				switch (flashId)
				{
                    case 0:
						if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					case 1:
						if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.BLACK, 1);
					case 2:
						if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 1);
					case 3:
						if(ClientPrefs.flashing) camHUD.flash(FlxColor.BLACK, 1);
				}
			case 'Hide or Show HUD elements':
				var top10awesomeId:Int = Std.parseInt(value1);
				switch (top10awesomeId)
				{
                    case 0:
						hideshit();
					case 1:
						showonlystrums();
					case 2:
						showshit();
				}
			case 'Hide or Show HUD elements with Fade':
				var vsEvilCorruptedBambiDay4Id:Int = Std.parseInt(value1);
				switch (vsEvilCorruptedBambiDay4Id)
				{
                    case 0:
						hideHUDFade();
					case 1:
						showHUDFade();
				}
			case 'Toggle Eyesores':
				var a1000YOMAMAjokesCanYouWatchThemAllquestionmarkId:Int = Std.parseInt(value1);
				switch (a1000YOMAMAjokesCanYouWatchThemAllquestionmarkId)
				{
                    case 0:
						shakeCam = false;
					case 1: 
						shakeCam = true;
				}
			case 'turn that fuckin spin on':
				var iranoutoffunnynamesId:Int = Std.parseInt(value1);
				switch (iranoutoffunnynamesId)
				{
                    case 0:
						daspinlmao = false;
						daleftspinlmao = false;
						camHUD.angle = 0;
					case 1: 
						camHUD.angle = 0;
						daspinlmao = true;
						daleftspinlmao = false;
					case 2: 
						camHUD.angle = 0;
						daleftspinlmao = true;
						daspinlmao = false;
				}
			case 'Thunderstorm type black screen':
				var ballsId:Int = Std.parseInt(value1);
				switch (ballsId)
				{
					case 0: 
						FlxTween.tween(blackScreendeez, {alpha: 0}, Conductor.stepCrochet / 500);
					case 1:
						FlxTween.tween(blackScreendeez, {alpha: 0.35}, Conductor.stepCrochet / 500);
				}
			case 'Switch to Pixel or 3D UI':
				var soId:Int = Std.parseInt(value1);
				switch (soId)
				{
					case 0:
						isPixelStage = true;
						is3DStage = false;
					case 1: 
						isPixelStage = false;
						is3DStage = true;
					case 2:
						isPixelStage = false;
						is3DStage = false;
				}
			case 'Fling Icon To Oblivion And Beyond':
				if (BAMBICUTSCENEICONHURHURHUR == null)
				{
					BAMBICUTSCENEICONHURHURHUR = new HealthIcon('dave', false);
					BAMBICUTSCENEICONHURHURHUR.y = healthBar.y - (BAMBICUTSCENEICONHURHURHUR.height / 2);
					add(BAMBICUTSCENEICONHURHURHUR);
					BAMBICUTSCENEICONHURHURHUR.cameras = [camHUD];
					BAMBICUTSCENEICONHURHURHUR.x = -100;
					FlxTween.linearMotion(BAMBICUTSCENEICONHURHURHUR, -100, BAMBICUTSCENEICONHURHURHUR.y, iconP2.x, BAMBICUTSCENEICONHURHURHUR.y, 0.3, true, {ease: FlxEase.expoInOut});
					new FlxTimer().start(0.3, FlingCharacterIconToOblivionAndBeyond);
				}
			case 'Blammed Lights': // !!
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				if(lightId > 0 && curLightEvent != lightId) {
					if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch(lightId) {
						case 1: //Blue
							color = 0xff31a2fd;
						case 2: //Green
							color = 0xff31fd8c;
						case 3: //Pink
							color = 0xfff794f7;
						case 4: //Red
							color = 0xfff96d63;
						case 5: //Orange
							color = 0xfffba633;
					}
					curLightEvent = lightId;

					if(blammedLightsBlack.alpha == 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
								//FlxTween.tween(blammedFunny, {alpha: 1}, Conductor.stepCrochet / 500);
							}
						});

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
								chars[i].colorTween = null;
								//FlxTween.tween(blammedFunny, {alpha: 0}, Conductor.stepCrochet / 500);
							}, ease: FlxEase.quadInOut});
						}
					} else {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = null;
						}
						dad.color = color;
						boyfriend.color = color;
						blammedFunny.color = color;
						gf.color = color;
					}
					
					if(curStage == 'philly') {
						if(phillyCityLightsEvent != null) {
							phillyCityLightsEvent.forEach(function(spr:BGSprite) {
								spr.visible = false;
							});
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				} else {
					if(blammedLightsBlack.alpha != 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});
					}

					if(curStage == 'philly') {
						phillyCityLights.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if(memb != null) {
							memb.visible = true;
							memb.alpha = 1;
							if(phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
								phillyCityLightsEventTween = null;
							}, ease: FlxEase.quadInOut});
						}
					}

					var chars:Array<Character> = [boyfriend, gf, dad];
					for (i in 0...chars.length) {
						if(chars[i].colorTween != null) {
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							chars[i].colorTween = null;
						}, ease: FlxEase.quadInOut});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}
				if(SONG.song.toLowerCase() == 'rebound' || SONG.song.toLowerCase() == 'mealie') {
		     		FlxTween.angle(iconP1, -30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			    	FlxTween.angle(iconP2, 30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				}
			case 'Change the Default Camera Zoom': // not to be confused with the one above!
					var mZoom:Float = Std.parseFloat(value1);
					if(Math.isNaN(mZoom)) mZoom = 0.09;

					defaultCamZoom = mZoom;
			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				if(ClientPrefs.flashing)
				{
		    		var valuesArray:Array<String> = [value1, value2];
		     		var targetsArray:Array<FlxCamera> = [camGame, camHUD];
			    	for (i in 0...targetsArray.length) {
		     			var split:Array<String> = valuesArray[i].split(',');
		     			var duration:Float = Std.parseFloat(split[0].trim());
				    	var intensity:Float = Std.parseFloat(split[1].trim());
			    		if(Math.isNaN(duration)) duration = 0;
			    		if(Math.isNaN(intensity)) intensity = 0;

			    		if(duration > 0 && intensity != 0) {
		     				targetsArray[i].shake(intensity, duration);
				    	}
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
								if(!CharacterSelectionState.notBF || (isStoryMode || isPurStoryMode))
									{
										if(boyfriend.curCharacter != value2) {
											if(!boyfriendMap.exists(value2)) {
												addCharacterToList(value2, charType);
											}
				
											var lastAlpha:Float = boyfriend.alpha;
											boyfriend.alpha = 0.00001;
											boyfriend = boyfriendMap.get(value2);
											boyfriend.alpha = lastAlpha;
											iconP1.changeIcon(boyfriend.healthIcon);
										}
										setOnLuas('boyfriendName', boyfriend.curCharacter);
									}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
				reloadTimeBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();

				case 'Change Scroll Speed':
				if(ClientPrefs.scroll || songSpeedType == "constant")
					return;
					
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		var bfplaying:Bool = false;
		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.y += dadCamFollowY;
			camFollow.x += dadCamFollowX;

			notes.forEachAlive(function(daNote:Note)
			{
				if (!bfplaying)
				{
					camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					camFollow.y += dadCamFollowY;
					camFollow.x += dadCamFollowX;

					if (daNote.mustPress)
					{
						bfplaying = true;
					}
				}
			});
			if (UsingNewCam && bfplaying)
			{
				return;
			}
		}
		if(isDad)
		{
			focusOnChar(badaiTime ? badai : dad);

			switch (dad.curCharacter)
			{
				case 'bandu':
					dad.POOP ? {
					!SONG.notes[Math.floor(curStep / 16)].altAnim ? {
					camFollowPos.setPosition(littleIdiot.getMidpoint().x, littleIdiot.getMidpoint().y - 300);
					defaultCamZoom = 0.35;
					} :
					    camFollowPos.setPosition(swaggy.getMidpoint().x + 150, swaggy.getMidpoint().y - 100);
				   	} :
				    camFollowPos.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				case 'dave-3d' | 'wtf-dave' | 'dave-insanity-3d' | 'bambi-expunged' | 'expunged-tilt':
					camFollow.y = dad.getMidpoint().y;
				case 'bambi-3d' | 'bambi-unfair':
					camFollow.y = dad.getMidpoint().y - 350;
				case 'bombu':
					camFollow.y = dad.getMidpoint().y;
					camFollow.x = dad.getMidpoint().x;
			}

			if (SONG.song.toLowerCase() == 'roundabout')
			{
				defaultCamZoom = 0.65;
			}

			if (SONG.song.toLowerCase() == 'rebound' || SONG.song.toLowerCase() == 'disposition' || SONG.song.toLowerCase() == 'upheaval')
			{
				defaultCamZoom = 0.55;
			}

			if (SONG.song.toLowerCase() == 'lacuna') {
				defaultCamZoom = 0.45;
			}

			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.y += dadCamFollowY;
			camFollow.x += dadCamFollowX;
		}
			
		if(!isDad)
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.y += camFollowY;
			camFollow.x += camFollowX;
	
			switch(boyfriend.curCharacter)
			{
				case 'dave-3d' | 'dave-insanity-3d' | 'wtf-dave':
					camFollow.y = boyfriend.getMidpoint().y;
				case 'bambi-3d' | 'bambi-unfair':
					camFollow.y = boyfriend.getMidpoint().y - 350;
			}
	
			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}

			if (SONG.song.toLowerCase() == 'roundabout')
			{
				defaultCamZoom = 0.75;
			}

			if (SONG.song.toLowerCase() == 'rebound' || SONG.song.toLowerCase() == 'disposition' || SONG.song.toLowerCase() == 'upheaval')
			{
				defaultCamZoom = 0.7;
			}

			if (SONG.song.toLowerCase() == 'lacuna') {
				defaultCamZoom = 0.65;
			}
		}
	}

	function focusOnChar(char:Character) {
		camFollow.set(char.getMidpoint().x + 150, char.getMidpoint().y - 100);
		// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
	
		switch (char.curCharacter)
		{
			case 'bandu':
				char.POOP ? {
				!SONG.notes[Math.floor(curStep / 16)].altAnim ? {
				camFollow.set(littleIdiot.getMidpoint().x, littleIdiot.getMidpoint().y - 300);
				defaultCamZoom = 0.35;
				} :
					camFollow.set(swaggy.getMidpoint().x + 150, swaggy.getMidpoint().y - 100);
			} :
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
		}
	}

	function tweenCamIn() {
		if (cameraTwn == null && FlxG.camera.zoom != 1.3 && SONG.song.toLowerCase() == 'tutorial') {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		switch (curSong.toLowerCase()) // ENDING DIALOGUE STUFF WITHOUT LUA
		{
	            case 'insanity' | 'maze' | 'splitathon': // ADD YOUR SONGS WITH ENDING DIALOGUE HERE
					if (isStoryMode || isPurStoryMode || ClientPrefs.freeplayCuts) 
					{
                        hideshit();
	         	        canPause = false;
	                    endingSong = true;
	                 	camZooming = false;
		                inCutscene = false;
						deathCounter = 0;
						seenCutscene = false;
						updateTime = false;
						FlxG.sound.music.volume = 0;
						vocals.volume = 0;
						if(!isModded) {
							if(ClientPrefs.lang == 'English') {
								eteSechStartDialogue(eteSechDialogueJson);
							}
							if(ClientPrefs.lang == 'Spanish--Espanol') {
								eteSechStartDialogue(esEteSechDialogueJson);
							}
							if(ClientPrefs.lang == 'Portuguese--Portugues') {
								eteSechStartDialogue(prEteSechDialogueJson);
							}
						} else {
							eteSechStartDialogue(eteSechDialogueJson);
						}
					}
					else // ELSE IF DEEZ NUTS IN YOUR MOUTH (FUNNY)
					{
						updateTime = false;
						FlxG.sound.music.volume = 0;
						vocals.volume = 0;
						vocals.pause();
						if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
							finishCallback();
						} else {
							finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
								finishCallback();
							});
						}
					}
	    	default:
				updateTime = false;
				FlxG.sound.music.volume = 0;
				vocals.volume = 0;
				vocals.pause();
				if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
					finishCallback();
				} else {
					finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
						finishCallback();
					});
				}
      	}
	}

	function FlingCharacterIconToOblivionAndBeyond(e:FlxTimer = null):Void
	{
		iconP2.changeIcon(dad.healthIcon);
		BAMBICUTSCENEICONHURHURHUR.animation.play(SONG.player2, true, false, 1);
		stupidx = -5;
		stupidy = -5;
		updatevels = true;
	}

	function THROWPHONEMARCELLO(e:FlxTimer = null):Void
	{
		STUPDVARIABLETHATSHOULDNTBENEEDED.animation.play("throw_phone");
		new FlxTimer().start(5.5, function(timer:FlxTimer)
		{ 
			FlxG.switchState(new FreeplayState());
		});
	}

	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat --CHEAT LIKE CHEATING HARD - DAVE ENGINE (KE 1.2) DO YOU WANT DO YOU WANT PHONE PHONE PHONE PHONE FSUOHIOFDSOUDFSAHOUFDSAOHUDHOUIGFSDHOJUSDFHOJSDF (im going insane in this line of code)
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		#if android
		androidc.visible = false;
		#end
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;


		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'whatthefuck_how', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end
		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning)
		{
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}


			if (chartingMode)
			{
				openChartEditor();
				return;
			}
			switch(curSong.toLowerCase())
				{
					case "bonus-song" | "bonus song":
						stupidThing = new Boyfriend(0, 0, "dave");
						unlockCharacter("Dave", "dave", null, FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]));
						if(characterUnlockObj != null)
							return;
					case "polygonized":
						if(storyDifficulty == 2)
							{
								stupidThing = new Boyfriend(0, 0, "dave-3d");
								unlockCharacter("3D Dave", "dave3d", null, FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]));
								if(characterUnlockObj != null)
									return;
							}
				}

			if (isStoryMode || isPurStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					cancelMusicFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
			switch (curSong.toLowerCase())
				{
					case 'polygonized':
						stupidThing = new Boyfriend(0, 0, "tristan");
						unlockCharacter("Tristan", "tristan", null, FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]));
						if(characterUnlockObj != null)
							return;
						if (health >= 0.1)
						FlxG.switchState(new EndingState('goodEnding', 'good-ending'));
						else if (health < 0.1)
							{
								FlxG.switchState(new EndingState('vomit_ending', 'bad-ending'));
							}
						else
						FlxG.switchState(new EndingState('badEnding', 'bad-ending'));
					default:
						if (isStoryMode){
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
					    	MusicBeatState.switchState(new StoryMenuState());
						}
						else if (isPurStoryMode){
							FlxG.sound.playMusic(Paths.music('purFreakyMenu'));
							MusicBeatState.switchState(new NewStoryPurgatory());
						}
				}

					// if ()
					if(!practiceMode || !cpuControlled) {
						if (isStoryMode){
				    		StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

					    	if (SONG.validScore)
					    	{
					    		Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
				    		}
     
				    		FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
					    	FlxG.save.flush();
						}
						else if (isPurStoryMode){
							NewStoryPurgatory.weekCompleted.set(PurWeekData.weeksList[storyWeek], true);

					    	if (SONG.validScore)
					    	{
					    		Highscore.saveWeekScore(PurWeekData.getWeekFileName(), campaignScore, storyDifficulty);
				    		}
     
				    		FlxG.save.data.weekCompleted = NewStoryPurgatory.weekCompleted;
					    	FlxG.save.flush();
						}
					}
					practiceMode = false;
					changedDifficulty = false;
					cpuControlled = false;
					chartingMode = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];



					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							//resetSpriteCache = true;
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						//resetSpriteCache = true;
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY');
				cancelMusicFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				switch (curSong.toLowerCase())
				{
		    	case 'ok':
					PlayState.SONG = Song.loadFromJson("ok-hard", "ok");
					FlxG.save.data.idkFound = true;
					shakeCam = false;
					screenshader.Enabled = false;
					FlxG.switchState(new PlayState()); // song looping, idk if it will get used again
				    return;
				default:
					scoreMultipliersThing = [1, 1, 1, 1];
					if (isFreeplay){
			    		MusicBeatState.switchState(new FreeplayState());
				      	FlxG.sound.playMusic(Paths.music('freakyMenu'));
						practiceMode = false;
				    	changedDifficulty = false;
				    	cpuControlled = false;
						chartingMode = false;
					}
					if (isFreeplayPur){
			    		MusicBeatState.switchState(new PurFreeplayState());
				      	FlxG.sound.playMusic(Paths.music('purFreakyMenu'));
						practiceMode = false;
				    	changedDifficulty = false;
				    	cpuControlled = false;
						chartingMode = false;
					}
				}
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving da Achievement: ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end
	

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var hits:Array<Float> = [];

	public var timeShown = 0;
	public var currentTimingShown:FlxText = null;
	private function popUpScore(note:Note = null):Void
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8); 
			//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));
	
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			if(ClientPrefs.ratinginHud) {
				coolText.x = FlxG.width * 0.35;
			} else { 
				coolText.x = FlxG.width * 0.55;
			}
			//
	
			var rating:FlxSprite = new FlxSprite();
	
			//tryna do MS based judgment due to popular demand
			var daRating:String = Conductor.judgeNote(note, noteDiff);
	
			switch (daRating)
			{
				case "shit": // shit
					totalNotesHit += 0;
					shits++;
				case "bad": // bad
					totalNotesHit += 0.5;
					bads++;
				case "good": // good
					totalNotesHit += 0.75;
					goods++;
				case "sick": // sick
					totalNotesHit += 1;
					sicks++;
			}
	
	
			if(daRating == 'sick' && !note.noteSplashDisabled)
			{
				spawnNoteSplashOnNote(note);
			}
	
			if(!practiceMode && !cpuControlled) {
				if(isFreeplay || isFreeplayPur)
					{
						songScore += freeplayScore;
					}
				else
					{
						songScore += score;
					}
				songHits++;
				totalPlayed++;
				RecalculateRating();
	
				if(ClientPrefs.scoreZoom)
				{
					if(scoreTxtTween != null) {
						scoreTxtTween.cancel();
					}
					scoreTxt.scale.x = 1.075;
					scoreTxt.scale.y = 1.075;
					scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
						onComplete: function(twn:FlxTween) {
							scoreTxtTween = null;
						}
					});
				}
			}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		var polyShitPart1:String = "";
		var polyShitPart2:String = '';

	    	if (curStage.startsWith('school') || isPixelStage)
			{
				pixelShitPart1 = 'pixelUI/';
				pixelShitPart2 = '-pixel';
			}
	
			if (curStage.startsWith('3d') || is3DStage)
			{
				polyShitPart1 = 'polygonized/polyUI/';
				polyShitPart2 = '-poly';
			}

			if(is3DStage) {
				rating.loadGraphic(Paths.image(polyShitPart1 + daRating + polyShitPart2));
			} else {
				rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			}
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			rating.visible = !ClientPrefs.hideHud;
			if(ClientPrefs.ratinginHud) {
				rating.x += ClientPrefs.comboOffset[0];
				rating.y -= ClientPrefs.comboOffset[1];
			}

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if(cpuControlled) msTiming = 0;		

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;

			if (ClientPrefs.ratinginHud) {
			    currentTimingShown.setFormat(Paths.font("comic-sans.ttf"), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		        currentTimingShown.size = 26;
			} else {
				currentTimingShown.setFormat(Paths.font("comic-sans.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		        currentTimingShown.size = 32;
			}
			currentTimingShown.borderSize = 2;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.visible = !ClientPrefs.hideHud;

			if (msTiming >= 0.03)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming); // kade wtf was this

				var total = 0.0;

				for(i in hits)
					total += i;
		    }

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			insert(members.indexOf(strumLineNotes), currentTimingShown);
			
		var comboSpr:FlxSprite = new FlxSprite();

			comboSpr.loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.visible = !ClientPrefs.hideHud;
			comboSpr.velocity.x += FlxG.random.int(1, 10);

			currentTimingShown.screenCenter();
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
			if(ClientPrefs.ratinginHud) currentTimingShown.cameras = [camHUD];
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			currentTimingShown.updateHitbox();
			if(ClientPrefs.ratinginHud) {
				currentTimingShown.x += ClientPrefs.comboOffset[0] + 30;
				currentTimingShown.y -= ClientPrefs.comboOffset[1] + 30;
			} else {
				currentTimingShown.x = coolText.x + 115;
				currentTimingShown.y -= 30;
			}

		if(is3DStage) {
			comboSpr.loadGraphic(Paths.image(polyShitPart1 + 'combo' + polyShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.visible = !ClientPrefs.hideHud;
			comboSpr.velocity.x += FlxG.random.int(1, 10);
		}

			insert(members.indexOf(strumLineNotes), rating);
	
			if (curStage.startsWith('school') || isPixelStage)
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = ClientPrefs.globalAntialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
			}
		
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			insert(members.indexOf(strumLineNotes), rating);
	
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
		    if(ClientPrefs.ratinginHud) {
		    	comboSpr.cameras = [camHUD];
		    	rating.cameras = [camHUD];
			}
	
			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');
	

	    	if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
			}

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite(); 

					numScore.loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			    	numScore.screenCenter();
			    	numScore.x = coolText.x + (43 * daLoop) - 90;
			    	numScore.y += 80;
	
					if(ClientPrefs.ratinginHud) {
			        	numScore.x += ClientPrefs.comboOffset[2];
				        numScore.y -= ClientPrefs.comboOffset[3];
					}
	
				if(is3DStage) {
			    	numScore.loadGraphic(Paths.image(polyShitPart1 + 'num' + Std.int(i) + polyShitPart2));
				    numScore.screenCenter();
		     		numScore.x = coolText.x + (43 * daLoop) - 90;
			    	numScore.y += 80;
				
	
					if(ClientPrefs.ratinginHud) {
			        	numScore.x += ClientPrefs.comboOffset[2];
				        numScore.y -= ClientPrefs.comboOffset[3];
					}
				}
	
				if (curStage.startsWith('school') || isPixelStage)
				{
					numScore.antialiasing = false;
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				else
				{
					numScore.antialiasing = ClientPrefs.globalAntialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				if(ClientPrefs.ratinginHud) numScore.cameras = [camHUD];
				numScore.visible = !ClientPrefs.hideHud;
	
				insert(members.indexOf(strumLineNotes), numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					timeShown++;
				}
			});

			FlxTween.tween(currentTimingShown, {alpha:0}, 0.5);
	
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
		}

			private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = false; // turn this shit from true to false to turn off that STUPID UGLy anti mash
					}
				    if(SONG.song.toLowerCase() == "unfairness")
					{
						canMiss = true; // cry about it
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];
		
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				camFollowX = 0;
				camFollowY = 0;
				if(UsingNewCam) bfSingYeah = false;
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false) {
		if (statement) {
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		health -= daNote.missHealth * healthLoss;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		if (combo > 10 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		
		totalPlayed++;
		RecalculateRating();

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		} else if(!boyfriend.hasMissAnimations) {
			boyfriend.color = 0xFF000084;

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))];
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void  //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 10 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			vocals.volume = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;
			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			} else if(!boyfriend.hasMissAnimations) {
				boyfriend.color = 0xFF000084;

				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))], true);
			}
		}
	}

	var nps:Int = 0;

	function goodNoteHit(note:Note):Void
	{
		
		if (!note.isSustainNote)
			notesHitArray.push(Date.now());

		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
				{
					freeplayScore = Std.int(score * scoreMultipliersThing[note.noteData]);
					popUpScore(note);
					
					if(ClientPrefs.hitsounds)
					{
						FlxG.sound.play(Paths.sound('hitsounds/' + ClientPrefs.hitsoundtype, 'shared'), ClientPrefs.hitsoundVolume);
					}

					combo += 1;
					if(combo > 9999) combo = 9999;
				}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = '';
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						animToPlay = 'singLEFT';
						switch (curSong.toLowerCase())
						{
						case 'sucked':
						   camHUD.x = 0;
						   camHUD.y = 0;
					    }
							if(ClientPrefs.followarrow) camFollowY = 0;
							if(ClientPrefs.followarrow)	camFollowX = -25;
					case 1:
						animToPlay = 'singDOWN';
						switch (curSong.toLowerCase())
						{
						case 'sucked':
						   camHUD.x = 0;
						   camHUD.y = 0;
					    }
							if(ClientPrefs.followarrow) camFollowY = 25;
							if(ClientPrefs.followarrow)	camFollowX = 0;
					case 2:
						animToPlay = 'singUP';
						switch (curSong.toLowerCase())
						{
						case 'sucked':
						   camHUD.x = 0;
						   camHUD.y = 0;
					    }
							if(ClientPrefs.followarrow) camFollowY = -25;
							if(ClientPrefs.followarrow)	camFollowX = 0;
					case 3:
						animToPlay = 'singRIGHT';
						switch (curSong.toLowerCase())
						{
						case 'sucked':
						   camHUD.x = 0;
						   camHUD.y = 0;
					    }
							if(ClientPrefs.followarrow) camFollowY = 0;
							if(ClientPrefs.followarrow)	camFollowX = 25;
				}

			/*	if(note.gfNote) 
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else*/
			//	{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
			//	}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}

				if(!boyfriend.hasMissAnimations) {
			    	if (hasBfDarkLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
			    		boyfriend.color = 0xFF878787;
			    	}
		     		if(hasBfSunsetLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
			    		boyfriend.color = 0xFFFF8F65;
			    	}
			    	if(hasBfDarkerLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
				    	boyfriend.color = 0xFF383838;
			     	}
			    	else
		     		{
			    		boyfriend.color = FlxColor.WHITE;
			    	}
				}
				if (UsingNewCam) bfSingYeah = true;
			}

			if (UsingNewCam && !dadSingYeah) {
			    isDadGlobal = false;
			    moveCamera(false);
		    }

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}
	
	// welcome to function zone

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	function shakewindow()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x + FlxG.random.int( -10, 10),Lib.application.window.y + FlxG.random.int( -2, 2));
		}, 20);
	}

	function guh()
	{
		playerStrums.forEach(function(spr:FlxSprite)
			{
				if(!ClientPrefs.downScroll) {
					spr.y = 40;
				}
				if(ClientPrefs.downScroll) {
					spr.y = 550;
				}
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				if(!ClientPrefs.downScroll) {
					spr.y = 40;
				}
				if(ClientPrefs.downScroll) {
					spr.y = 550;
				}
			});
	}

	function dialogBullshitStart() {
		if(!isModded) {
			if(ClientPrefs.lang == 'English') {
				startDialogue(dialogueJson);
			}
			if(ClientPrefs.lang == 'Spanish--Espanol') {
				startDialogue(esDialogueJson);
			}
			if(ClientPrefs.lang == 'Portuguese--Portugues') {
				startDialogue(prDialogueJson);
			}
		} else {
			startDialogue(dialogueJson);
		}
	}

	function hideshit() // basically a camHUD.visible = false; except it doesnt fuck up dialogue (and i didnt want to do another camera for the dialogue)
	{
		if(!ClientPrefs.hideHud) {
			songWatermark.visible = false;
			healthBar.visible = false;
			healthBarBG.visible = false;
			iconP1.visible = false;
			iconP2.visible = false;
		} 
		creditsWatermark.visible = false;
		judgementCounter.visible = false;
		strumLineNotes.visible = false;
		grpNoteSplashes.visible = false;
		notes.visible = false;
		scoreTxt.visible = false;
		if(!ClientPrefs.hideTime) {
	    	timeBar.visible = false;
	    	timeBarBG.visible = false;
		    timeTxt.visible = false;
		}
	}
	
	function showshit()
	{
		if(!ClientPrefs.hideHud) {
			songWatermark.visible = true;
			healthBar.visible = true;
			healthBarBG.visible = true;
			iconP1.visible = true;
			iconP2.visible = true;
		} 
		creditsWatermark.visible = true;
		judgementCounter.visible = true;
		strumLineNotes.visible = true;
		grpNoteSplashes.visible = true;
		notes.visible = true;
		scoreTxt.visible = true;
		if(!ClientPrefs.hideTime) {
	    	timeBar.visible = true;
	    	timeBarBG.visible = true;
		    timeTxt.visible = true; 
		}
	}
	
	function showonlystrums() // does the thing that it says
	{
		songWatermark.visible = true;
		creditsWatermark.visible = true;
		judgementCounter.visible = true;
		if(!ClientPrefs.hideHud) {
	    	healthBar.visible = false;
	     	healthBarBG.visible = false;
	        iconP1.visible = false;
	    	iconP2.visible = false;
		}
	   	scoreTxt.visible = false;
		strumLineNotes.visible = true;
		grpNoteSplashes.visible = true;
		notes.visible = true;
		if(!ClientPrefs.hideTime) {
	     	timeBar.visible = true;
	     	timeBarBG.visible = true;
	     	timeTxt.visible = true;
		}
	}

	function hideHUDFade() // DONT USE THIS AT STEP 0!!!
	{
		FlxTween.tween(camHUD, {alpha:0}, 1);
	}
	
	function showHUDFade()
	{
		FlxTween.tween(camHUD, {alpha:1}, 1);
	}
	

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.danced = false; //Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}
		if(gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (curSong == '8-28-63' || curSong == 'prejudice')
		{
			if (curStep >= 576 && curStep < 608 || curStep >= 1856 && curStep < 1888)
			{
					if (curBeat % 0.5 == 0)
					{
						defaultCamZoom += 0.01;	
						
					}
			}
			if (curStep >= 624 && curStep < 640 || curStep >= 1904 && curStep < 1920 )
			{
					if (curBeat % 0.5 == 0)
					{
						defaultCamZoom -= 0.02;	
					}
			}
			switch (curStep)
			{			
			    case 640, 1920:
					defaultCamZoom = 1.2;
				case 1152, 2432:
					defaultCamZoom = 0.8;
			}
		}

        switch (SONG.song.toLowerCase())
        {
			case 'furiosity':
				switch (curStep)
				{
					case 512 | 768:
						shakeCam = true;
					case 640 | 896:
						shakeCam = false;
					case 1305:
						var position = dad.getPosition();
						FlxG.camera.flash(FlxColor.WHITE, 0.25);
						FlxTween.linearMotion(dad, dad.x, dad.y, 350, 260, 0.6, true);
				}
			case 'old-furiosity':
				switch (curStep)
				{
					case 512 | 768:
						shakeCamALT = true;
					case 640 | 896:
						shakeCamALT = false;
				}
			case 'polygonized':
				switch(curStep)
				{
					case 1024 | 1312 | 1424 | 1552 | 1664:
						shakeCam = true;
					case 1152 | 1408 | 1472 | 1600 | 2048 | 2176:
						shakeCam = false;
				}
			case 'glitch':
				switch (curStep)
				{
					case 480 | 681 | 1390 | 1445 | 1515 | 1542 | 1598 | 1655:
						shakeCam = true;
						camZooming = true;
					case 512 | 688 | 1420 | 1464 | 1540 | 1558 | 1608 | 1745:
						shakeCam = false;
						camZooming = false;
				}
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

	    switch (SONG.song.toLowerCase())
     	{
			case 'reality breaking':
				switch (curBeat)
				{
					case 128:
						camHUD.flash(FlxColor.WHITE, 0.25);
						#if windows
						if(ClientPrefs.chromaticAberration)
						{
				     		if(ClientPrefs.chromaticAberration)
							{
								camHUD.setFilters([new ShaderFilter(shader_chromatic_abberation.shader), new ShaderFilter(grain_shader.shader)]);
							}
					     	else
							{
								camHUD.setFilters([new ShaderFilter(grain_shader.shader)]);
							}
						}
						#end
					case 256 | 512:
						if(ClientPrefs.chromaticAberration) stupidBool = true;
						FlxG.camera.flash(FlxColor.WHITE, 0.25);
						if(ClientPrefs.chromaticAberration) doneloll2 = true;
					case 384:
						if(ClientPrefs.chromaticAberration) stupidBool = false;
						FlxG.camera.flash(FlxColor.WHITE, 0.25);
						if(ClientPrefs.chromaticAberration) doneloll2 = false;
					case 640:
						if(ClientPrefs.chromaticAberration) stupidBool = false;
						FlxG.camera.flash(FlxColor.WHITE, 0.25);
						if(ClientPrefs.chromaticAberration) doneloll2 = false;
						camHUD.setFilters([]);
				}
	    	case 'devastation':
		    	switch (curBeat)
		    	{
			    	case 20: // 320
			    	    FlxTween.tween(swagBombu, {y: swagBombu.y - 1450}, 0.65, {ease:FlxEase.cubeInOut});
			    		wtfThing = true;
			    		what.forEach(function(spr:FlxSprite){
			     			spr.frames = Paths.getSparrowAtlas('bambi/minion');
			    			spr.animation.addByPrefix('hi', 'poip', 12, true);
			    			spr.animation.play('hi');
				    	});
			   	    	camHUD.flash(FlxColor.WHITE, 1);
				    	dad.POOP = true; // WORK WORK WOKR< WOKRMKIEPATNOLIKSEHGO:"IKSJRHDLG"H
				    	poopStrums.visible = true; // ??????
				    	var derez = new FlxSprite(swaggy.getMidpoint().x, swaggy.getMidpoint().y).loadGraphic(Paths.image('bambi/monkey_guy'));
			     		derez.setPosition(-350, 100);
			    		derez.antialiasing = false;
			    		add(derez);
			     		FlxTween.angle(derez, 0, -360, 0.65);
				    	var burgeez:FlxSprite = new FlxSprite(dad.getMidpoint().x, dad.getMidpoint().y).loadGraphic(Paths.image('bambi/marcel'));
			    		burgeez.setPosition(burgeez.x - burgeez.width / 2, burgeez.y - burgeez.height / 2);
			    		burgeez.antialiasing = false;
			    		add(burgeez);
				     	FlxTween.angle(burgeez, 0, 360, 0.65);
			    		FlxTween.tween(derez, {y: derez.y - 1500}, 1.05);
				    	FlxTween.tween(burgeez, {y: burgeez.y - 1500}, 1.05);
				    	dad.visible = swaggy.visible = false;
				     	//FlxTween.tween(computer, {x: computer.x - 1450}, 1.05, {type:LOOPING});
	    		}
				case 'splitathon':
					switch (curBeat)
					{
						case 1 | 92 | 107 | 124 | 144 | 336 | 720 | 1008 | 1200 | 1648 | 2032 | 2348:
							  camZoomSnap = true;
						case 80 | 95 | 112 | 128 | 209 | 592 | 848 | 1168 | 1520 | 1904 | 2290 | 2384:
							camZoomSnap = false;
					}
	    }

		if (!UsingNewCam)
		{
			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if (curBeat % 4 == 0)
				{
					// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
				}

				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					isDadGlobal = true;
					moveCamera(true);
				}

				if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					isDadGlobal = false;
					moveCamera(false);
				}
			}
		}
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, SONG.song.toLowerCase() == 'unfairness' || ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && autoCamZoom && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curBeat % 4 == 0 && SONG.song.toLowerCase() == "lacuna") // i swear i didnt watch gaming man's vid before doing this we had the same idea :sob
		{
			if(fartt) {
		    	FlxTween.tween(camHUD, {angle: 180}, 0.20, {ease: FlxEase.quadOut});
				FlxTween.tween(FlxG.camera, {angle: 2.5}, 0.20, {ease: FlxEase.quadOut});
				fartt = false;
				fartt2 = true;
			} else if (fartt2) {
				FlxTween.tween(camHUD, {angle: 0}, 0.20, {ease: FlxEase.quadOut});
				FlxTween.tween(FlxG.camera, {angle: -2.5}, 0.20, {ease: FlxEase.quadOut});
				fartt = true;
				fartt2 = false;
			}
		}

		if (curBeat % 4 == 0 && SONG.song.toLowerCase() == "acquaintance" && bALLS)
	    {
			if(fartt) {
		    	FlxTween.tween(camHUD, {angle: 1.5}, 0.075, {ease: FlxEase.quadOut});
				fartt = false;
		  		fartt2 = true;
			} else if (fartt2) {
			    	FlxTween.tween(camHUD, {angle: -1.5}, 0.075, {ease: FlxEase.quadOut});
				fartt = true;
				fartt2 = false;
			}
	    }

		if (camZoomSnap) {
	     	if (ClientPrefs.camZooms && camZooming && FlxG.camera.zoom < 1.35) {
		    	FlxG.camera.zoom += 0.015;
		    	camHUD.zoom += 0.03;
	     	}
	    }

		if (curBeat % 4 == 0) // icon bop coollll shittt t t t t 
		{
			FlxTween.angle(iconP1, -30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.angle(iconP2, 30, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
		}

		var funny:Float = (healthBar.percent * 0.01) + 0.01;

		//icon squish funny haha
		iconP1.setGraphicSize(Std.int(iconP1.width + (50 * funny)),Std.int(iconP2.height - (25 * funny)));
		iconP2.setGraphicSize(Std.int(iconP1.width + (50 * funny)),Std.int(iconP2.height - (25 * funny)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if(curBeat % 2 == 0)
		{
	    	if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
	     	{
		    	boyfriend.dance();
		    	camFollowX = 0;
		    	camFollowY = 0;
		    	if(UsingNewCam) bfSingYeah = false;

				boyfriend.playAnim('idle', true);
				if(!boyfriend.hasMissAnimations) {
			    	if (hasBfDarkLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
			    		boyfriend.color = 0xFF878787;
			    	}
		     		if(hasBfSunsetLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
			    		boyfriend.color = 0xFFFF8F65;
			    	}
			    	if(hasBfDarkerLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
				    	boyfriend.color = 0xFF383838;
			     	}
			    	else
		     		{
			    		boyfriend.color = FlxColor.WHITE;
			    	}
				}
	    	}
		    if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		    {
		    	dad.dance();
		    	dadCamFollowX = 0;
		       	dadCamFollowY = 0;
		    	if(UsingNewCam) dadSingYeah = false;
	    	}
		}

		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating()
	{
	    if(!cpuControlled || !practiceMode)
    	{
    		setOnLuas('score', songScore);
	    	setOnLuas('misses', songMisses);
	     	setOnLuas('hits', songHits);

	    	var ret:Dynamic = callOnLuas('onRecalculateRating', []);
	    	if(ret != FunkinLua.Function_Stop)
	    	{
	    		if(totalPlayed < 1) //Prevent divide by 0
	    			ratingName = '?';
	    		else
		    	{
			    	// Rating Percent
			    	ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
			      	//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

			     	// Rating Name
			    	if(ratingPercent >= 1)
			    	{
			  	    	ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
			    	}
			    	else
			    	{
				    	for (i in 0...ratingStuff.length-1)
			    		{
					    	if(ratingPercent < ratingStuff[i][1])
			    			{
					    		ratingName = ratingStuff[i][0];
					    		break;
				     		}
			     		}
			    	}
	    		}

	    		// Rating FC
		    	ratingFC = "";
	     		if (sicks > 0) ratingFC = "SFC";
		    	if (goods > 0) ratingFC = "GFC";
	     		if (bads > 0 || shits > 0) ratingFC = "FC";
		    	if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
	     		if (songMisses >= 10) ratingFC = "Clear";
	       		if (songMisses >= 30) ratingFC = "Clear";
		    	if (songMisses >= 65) ratingFC = "Clear - Skill issue";
	     		if (songMisses >= 500) ratingFC = "Skill Issue";
	    		else if (songMisses >= 1000) ratingFC = "vers good";
    		}
	    	setOnLuas('rating', ratingPercent);
      		setOnLuas('ratingName', ratingName);
	     	setOnLuas('ratingFC', ratingFC);
    		judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${songMisses}';
     	}
	}

	public function addSplitathonChar(char:String):Void
		{
			boyfriend.stunned = true; //hopefully this stun stuff should prevent BF from randomly missing a note
			remove(dad);
			dad = new Character(100, 100, char);
			add(dad);
			dad.color = 0xFF878787;
			switch (dad.curCharacter)
			{
				case 'dave-splitathon':
					{
						dad.y += 160;
						dad.x += 250;
					}
				case 'bambi-splitathon':
					{
						dad.x += 100;
						dad.y += 450;
					}
			}
			boyfriend.stunned = false;
		}
	
		public function splitterThonDave(expression:String):Void
		{
			boyfriend.stunned = true; //hopefully this stun stuff should prevent BF from randomly missing a note
			//stupid bullshit cuz i dont wanna bother with removing thing erighkjrehjgt
			thing.x = -9000;
			thing.y = -9000;
			if(daveExpressionSplitathon != null)
				remove(daveExpressionSplitathon);
			daveExpressionSplitathon = new Character(-200, 260, 'dave-splitathon');
			add(daveExpressionSplitathon);
			daveExpressionSplitathon.color = 0xFF878787;
			daveExpressionSplitathon.playAnim(expression, true);
			boyfriend.stunned = false;
		}
	
		public function preload(graphic:String) //preload assets
		{
			if (boyfriend != null)
			{
				boyfriend.stunned = true;
			}
			var newthing:FlxSprite = new FlxSprite(9000,-9000).loadGraphic(Paths.image(graphic));
			add(newthing);
			remove(newthing);
			if (boyfriend != null)
			{
				boyfriend.stunned = false;
			}
		}
	
		var characterUnlockObj:CharacterUnlockObject = null;

		public function unlockCharacter(characterToUnlock:String, characterIcon:String, characterDisplayName:String = null, color:FlxColor = FlxColor.BLACK, botplayUnlocks:Bool = false)
			{
				if(!chartingMode || botplayUnlocks)
					{if(!FlxG.save.data.unlockedCharacters.contains(characterToUnlock))
						{
							if(characterDisplayName == null)
								characterDisplayName = characterToUnlock;
							characterUnlockObj = new CharacterUnlockObject(characterDisplayName, camOther, characterIcon, color);
							characterUnlockObj.onFinish = characterUnlockEnd;
							add(characterUnlockObj);
							FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
							FlxG.save.data.unlockedCharacters.push(characterToUnlock);
						}
					}
			}
		
		function characterUnlockEnd():Void
		{
			characterUnlockObj = null;
			if(endingSong && !inCutscene) {
				endSong();
			}
		}
	
		public function splitathonExpression(expression:String, x:Float, y:Float):Void
		{
			if (SONG.song.toLowerCase() == 'splitathon' || SONG.song.toLowerCase() == 'old-splitathon')
			{
				if(daveExpressionSplitathon != null)
				{
					remove(daveExpressionSplitathon);
				}
				if (expression != 'lookup')
				{
					camFollowPos.setPosition(dad.getGraphicMidpoint().x + 100, boyfriend.getGraphicMidpoint().y + 150);
				}
				boyfriend.stunned = true;
				thing.color = 0xFF878787;
				thing.x = x;
				thing.y = y;
				remove(dad);
	
				switch (expression)
				{
					case 'bambi-what':
						thing.frames = Paths.getSparrowAtlas('splitathon/Bambi_WaitWhatNow');
						thing.animation.addByPrefix('uhhhImConfusedWhatsHappening', 'what', 24);
						thing.animation.play('uhhhImConfusedWhatsHappening');
					case 'bambi-corn':
						thing.frames = Paths.getSparrowAtlas('splitathon/Bambi_ChillingWithTheCorn');
						thing.animation.addByPrefix('justGonnaChillHereEatinCorn', 'cool', 24);
						thing.animation.play('justGonnaChillHereEatinCorn');
				}
				if (!splitathonExpressionAdded)
				{
					splitathonExpressionAdded = true;
					add(thing);
				}
				thing.antialiasing = true;
				boyfriend.stunned = false;
			}
		}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String>):String { // dont bully me for this, this was like this on psych engine 0.4.2 :sadbau:
		if(chartingMode || cpuControlled || practiceMode) return null;

		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName)) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 || CoolUtil.difficultyString() == 'HARD' && CoolUtil.difficultyString() == 'FINALE' && storyPlaylist.length <= 1 && !changedDifficulty && !practiceMode)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
							/*	case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;*/ // dont ask for this u will see later heheheh hehh hh hhhh
							}
						}
						if(isPurStoryMode && campaignMisses + songMisses < 1 || CoolUtil.difficultyString() == 'HARD' && CoolUtil.difficultyString() == 'FINALE' && storyPlaylist.length <= 1 && !changedDifficulty && !practiceMode)
							{
								var weekName:String = PurWeekData.getWeekFileName();
								switch(weekName) // dsf9uvhfdsgfduibgui
								{
									case 'week4':
										if(achievementName == 'week4_nomiss') unlock = true;
									case 'week5':
										if(achievementName == 'week5_nomiss') unlock = true;
									case 'week6':
										if(achievementName == 'week6_nomiss') unlock = true;
									case 'week7':
										if(achievementName == 'week7_nomiss') unlock = true;
									case 'week8':
										if(achievementName == 'week8_nomiss') unlock = true;
									case 'week9':
										if(achievementName == 'week9_nomiss') unlock = true;
									case 'week10':
										if(achievementName == 'week10_nomiss') unlock = true;
								}
							}
					case 'whatthefuck_how':
						if(campaignMisses + songMisses < 1 && storyPlaylist.length <= 1)
						{
							switch (curSong.toLowerCase()) //troll face
							{
								case 'opposition':
									if(achievementName == 'whatthefuck_how') unlock = true;
							}
						}
					case 'cheater':
						if(campaignMisses + songMisses < 1 && storyPlaylist.length <= 1)
						{
							switch (curSong.toLowerCase()) 
							{
								case 'cheating':
									if(achievementName == 'cheater') unlock = true;
							}
						}
					case 'unfaircheat':
						if(campaignMisses + songMisses < 1 && storyPlaylist.length <= 1)
						{
							switch (curSong.toLowerCase())
							{
								case 'unfairness':
									if(achievementName == 'unfaircheat') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode && !cpuControlled) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !practiceMode && !cpuControlled) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 20 && !practiceMode) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !practiceMode) {
							unlock = true;
						}
					case 'two_keys':
						if(!practiceMode) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}