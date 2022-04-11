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
import Controls;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Eyesores, Flashing Lights\nAnd Shaking',
			"Uncheck this if you're sensitive to flashing lights\nand Fast flashing colors!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Enable Waving Backgrounds',
			"If Checked, Enables Waving backgrounds in stages with them",
			'waving',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Note Movement',
			'If checked it will enable a Camera Movement according to the Note Hit.',
			'followarrow',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Judgement Counter',
			"Shows a judgement counter at the left of the screen (Example: Sicks: 93,\nGoods:0, Bads: 1, 'Shits: 0)",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Longer Health Bar',
			"Makes the Health bar longer visually\n(This doesn't give you more health!)",
			'longAssBar',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			'Song and Time Left',
			['Song and Time Left', 'Song and Time Elapsed', 'Song Name']);
		addOption(option);

		var option:Option = new Option('Hide Time Bar',
			"If Checked, Hides the Time Bar",
			'hideTime',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
	
		super();
	}

	override function destroy()
	{
		super.destroy();
	}
}