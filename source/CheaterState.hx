package;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
#if windows
import Discord.DiscordClient;
#end

/**
 * ...
 * // took this from pompom sorry sorry sorr s
 */
class CheaterState extends FlxState
{
	
	public function new(goodEnding:Bool = true) 
	{
		super();
		
	}
	
	override public function create():Void 
	{
		super.create();

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("CHEATER FUCK YOU", StringTools.replace(PlayState.SONG.song, '-', ' '));
		#end

		var end:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('dave/fuckyouscreen', 'shared'));
		FlxG.sound.playMusic(Paths.music("cheater", "shared"),1,false);
		add(end);
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
		
		
		new FlxTimer().start(24, endIt);
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
	}
	
	
	public function endIt(e:FlxTimer=null){
		trace("ENDING");
		FlxG.switchState(new PlayState());
	}
	
}