package options;

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
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import purgatory.PurMainMenuState;
import Controls;

 // haxe culiao no me deja poner la ñ :((((((

using StringTools;

class MiscOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = "Misc Options";
		rpcTitle = 'Misc Options'; //for Discord Rich Presence

		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			#if android false #else true #end);
		addOption(option);
		option.onChange = onChangeFPSCounter;

		var option:Option = new Option('Language:',
			"Select your Language\nSelecciona tu Idioma\nSelecione Sua Lingua",
			'lang',
			'string',
			'English',
			['English', 'Spanish--Espanol', 'Portuguese--Portugues']);
		addOption(option);

		var option:Option = new Option('Enable Chromatic Aberration',
			'Disable if this is causing a crash',
			'chromaticAberration',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Freeplay Cutscenes',
			'If checked, enables Cutscenes on Freeplay',
			'freeplayCuts',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Classic Score Text',
			'Enable this to disable\nNPS and Ratings in the Score Text.\n(Shows Just score, misses and accuracy)',
			'classicScore',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

	    var option:Option = new Option('Ratings and Combo in the Hud',
			'Enable this to have the Ratings, Combo and MS in the Hud.',
			'ratinginHud',
			'bool',
			false);
		addOption(option);

		 var option:Option = new Option('Character Colored Bars',
			'Enable this to make the\nTime and Health Bars Colored\nby the Character json Color',
			'colorBars',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic)
	    {
		    if(MainMenuState.sexo3) {
		    	FlxG.sound.playMusic(Paths.music('freakyMenu'));
	    	} else if(PurMainMenuState.sexo4) {
				FlxG.sound.playMusic(Paths.music('purFreakyMenu'));
			}
		}
		super.destroy();
	}
	
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
}