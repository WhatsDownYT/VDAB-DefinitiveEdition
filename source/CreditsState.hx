package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color, yourmother
		['Dave & Bambi Original Mod'],
		['Check it out by pressing enter!',		    'daveandbamber',			'Support the Original Mod!',			                            'https://gamebanana.com/mods/43201',	    0xFF613BE0],
		[''],
		['VDABDE + Purgatory Team'],
		['WhatsDown',		    'whatsdown',			'Creator/Main Dev, Made most assets',			                            'https://www.youtube.com/channel/UCL3oNN5ss7sI8bHq8i9Unhg',	    0xFF613BE0],
		['ztgds',		    'ztgds',			'Dev/Programmer & Made a few assets', 'https://www.youtube.com/channel/UCUmuZE0RPjvUhB036T6omfQ',	    0xFFFFA845],
		['Voidsslime',	 'voidsslime',			'Artist/Playtester, Moral support',             'https://www.youtube.com/channel/UClS9epoMvsI8KWYnbc9Uc6Q',	    0xFFD153FF], // + being cool
		[''],
		['Contributors'],
		['Pyramix',			'pyramix',			'Composed Reality Breaking and Technology, Purgatory Contributor',				                        'https://www.youtube.com/channel/UCPKFkbgvQ5_3ETVd3l75wAA',		    0xFFFF0000],
		['Hortas',			'hortas',			'Composed a few songs, Purgatory Contributor',				                        'https://www.youtube.com/channel/UCvR1oxdjnB9hV-MLeH339Kg',		    0xFFFF0000], 
		['Reginald Reborn',      'reg',	        'Made Charts for a few songs, Moral support, Purgatory Contributor',                   '',		0xFFFF0000],
		['ShredBoi',			'shredboi',			'Composed Disposition, Purgatory Contributor',				                        'https://www.youtube.com/channel/UCcPW37b_Gb_j0CG3U1B89YQ',		    0xFFFF0000], // holy shit disposition is such a banger i loveit
		['rapparep lol',      'rapparep',	        'Made Gary sprites, Moral support, Purgatory Contributor',                   'https://www.youtube.com/c/rappareplol',		0xFFFF0000],
		['CyndaquilDAC',      'cynda',	        'Programmed a few additions, Composed Supplanted, Made 2d God Bambi & Joke Bambi Remastered Sprites',                   'https://www.youtube.com/channel/UCTaq4jni33NoaI1TfMXCRcA',		0xFFFF0000],
		['Maevings',      'maevings',	        'Composed Opposition, Purgatory Contributor',                   'https://www.youtube.com/c/Maevings',		0xFFFF0000],
		['Memory_001',			'memory',			'Created Bambi Corrupt Sprites, Purgatory Contributor',				                        '',		    0xFFFF0000],
		['Lancey',			'lancey',			'Applecore Artist, Created 3D Bambi God Sprites',				                        'https://www.youtube.com/c/Lancey170',		    0xFFFF0000], 
		['Grantare',			'grantare',			'Helped with the Alt Notes for Devastation (Coming Soon!), Purgatory Contributor',				                        'https://www.youtube.com/c/Grantare',		    0xFFFF0000], 
		['Gael',			'gael',			'Created some icons, Purgatory Contributor',				                        '',		    0xFFFF0000], 
		['NewPlayer',			'newplayer',			'Playtester, Hellscape Original Owner, Purgatory Contributor',				                        'https://www.youtube.com/channel/UCqxtnCuemVF_EXK7P0Mo3lw',		    0xFFFF0000],
		['That Pizza Tower Fan',      'tptf',	        "Composed Screwed",                   'https://www.youtube.com/c/ThatPizzaTowerFan',		0xFFFF0000],
		['Alexander Cooper 19',           'alexandercooper',			'Composed Mealie, Purgatory Contributor',                     'https://www.youtube.com/channel/UCNz20AHJq41rkBUsq8RmUfQ',		0xFFFF0000],
		['TheBuilderXD',			'tb',			'Created some icons, Purgatory Contributor',				                        '',		    0xFFFF0000], 
		[''],
		['Vs Dave And Bambi Team'],
		['  MoldyGH',			'nothing',			'Creator/Main Dev',				                        'https://www.youtube.com/channel/UCHIvkOUDfbMCv-BEIPGgpmA',		    0xFFFF0000],
		['  MissingTextureMan101','nothing',	  	'Secondary Dev',				                        'https://www.youtube.com/channel/UCCJna2KG54d1604L2lhZINQ',	0xFFFF0000],
		['  rapparep lol',      'nothing',			'Main Artist',				                            'https://www.youtube.com/channel/UCKfdkmcdFftv4pFWr0Bh45A',		0xFFFF0000],
		['  TheBuilderXD',      'nothing',			'Page Manager, Tristan Sprite Creator, and more',       'https://www.youtube.com/user/99percentMember',		0xFFFF0000],
		['  Erizur',            'nothing',			'Programmer, Week Icon Artist',                       'https://www.youtube.com/channel/UCdCAaQzt9yOGfFM0gJDJ4bQ',		0xFFFF0000], // ñ
		['  T5mpler',           'nothing',			'Dev/Programmer & Supporter',                           'https://www.youtube.com/channel/UCgNoOsE_NDjH6ac4umyADrw',		0xFFFF0000],
		['  CyndaquilDAC',      'nothing',	        'Contributor & Programmed a few new additions',                   'https://www.youtube.com/channel/UCTaq4jni33NoaI1TfMXCRcA',		0xFFFF0000], 
		['  Stats45',           'nothing',			'Minor programming, Moral support',                     'https://www.youtube.com/channel/UClb4YjR8i74G-ue2nyiH2DQ',		0xFFFF0000],
		['  Alexander Cooper 19',           'nothing',			'Mealie song, Beta Tester',                     'https://www.youtube.com/channel/UCNz20AHJq41rkBUsq8RmUfQ',		0xFFFF0000],
		['  Zmac',           'nothing',			'3D Background, Intro text help, EMFNF2 help',                     'https://www.youtube.com/channel/UCl50Xru1nLBENuLiQBt6VRg',		0xFFFF0000],
		[''],
		['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',						'https://twitter.com/Shadow_Mario_',	0xFFFF0000],
		['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',					'https://twitter.com/river_oaken',		0xFFC30085],
		['bb-panzu',			'bb-panzu',			'Additional Programmer of Psych Engine',				'https://twitter.com/bbsub3',			0xFFFF0000],
		[''],
		['Psych Engine Contributors'],
		['shubs',				'shubs',			'New Input System Programmer',							'https://twitter.com/yoshubs',			0xFFFF0000],
		['SqirraRNG',			'gedehari',			'Chart Editor\'s Sound Waveform base',					'https://twitter.com/gedehari',			0xFFFF0000],
		['iFlicky',				'iflicky',			'Delay/Combo Menu Song Composer\nand Dialogue Sounds',	'https://twitter.com/flicky_i',			0xFFFF0000],
		['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',							'https://twitter.com/polybiusproxy',	0xFFFF0000],
		['Keoiki',				'keoiki',			'Note Splash Animations',								'https://twitter.com/Keoiki_',			0xFFFF0000],
		[''],
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',	0xFFF73838],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',	0xFFFFBB1B],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',			0xFF53E52C],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',		0xFF6475F3],
		[''],
		['Special Thanks'],
		['mayo78',				'the',			'For creating a guide to separate BFs arrow skin from the CPUs arrow skin.',							'https://github.com/mayo78',			0xFFFF0000],
		['itsCapp',				'the',			'For creating a event to move the arrows.',							'https://github.com/ShadowMario/FNF-PsychEngine/discussions/893',			0xFFFF0000],
		['Punkinator7',				'the',			'For Creating a LUA script for custom notes and events.',							'https://gamebanana.com/members/1687904',			0xFFFF0000]
	];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("comic-sans.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = creditsStuff[curSelected][4];
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
