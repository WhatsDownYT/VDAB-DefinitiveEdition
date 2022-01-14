package;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;

//too lazy to finish this rn
class CharacterSelectState extends MusicBeatState
{
	var physicalChars:Array<Boyfriend>;

	public var isDebug:Bool = false;
		
	/*//data goes char names, displayed char names, score multipliers (in order of left, up, right, down), voices extension (for custom voices for playables)
	var charData:Array<Map<Array<String>, Array<String>, Array<Float>, String>>;*/

	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();

		Conductor.changeBPM(110);

		if (FlxG.save.data.unlockedcharacters == null)
		{
			FlxG.save.data.unlockedcharacters = [true,true,false,false,false,false,false,false];
		}
		if(isDebug)	
		{
			FlxG.save.data.unlockedcharacters = [true,true,true,true,true,true,true,true]; //unlock everyone
		}

		FlxG.sound.playMusic(Paths.music("goodEnding"),1,true);
	}
}