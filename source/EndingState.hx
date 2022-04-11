package;
import CharacterSelectionState.CharacterUnlockObject;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * omg aer you bbpanzu???????????????????????????????????
 */
class EndingState extends MusicBeatState
{

	var _ending:String;
	var _song:String;
	public var stupidThing:Boyfriend;
	
	public function new(ending:String,song:String) 
	{
		super();
		_ending = ending;
		_song = song;
	}
	
	override public function create():Void 
	{
		super.create();
		var end:FlxSprite = new FlxSprite(0, 0);
		end.loadGraphic(Paths.image("dave/" + _ending));
		FlxG.sound.playMusic(Paths.music(_song),1,true);
		add(end);
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
		if(_ending == "vomit_ending")
			{
				stupidThing = new Boyfriend(0, 0, "bambi");
				unlockCharacter("Bambi", "bambi", null, FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]));
			}
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (FlxG.keys.pressed.ENTER)
		{
			endIt();
		}
		
	}

	var characterUnlockObj:CharacterUnlockObject = null;
	
	public function unlockCharacter(characterToUnlock:String, characterIcon:String, characterDisplayName:String = null, color:FlxColor = FlxColor.BLACK, botplayUnlocks:Bool = false)
		{
			if(!PlayState.chartingMode || botplayUnlocks)
				{if(!FlxG.save.data.unlockedCharacters.contains(characterToUnlock))
					{
						if(characterDisplayName == null)
							characterDisplayName = characterToUnlock;
						characterUnlockObj = new CharacterUnlockObject(characterDisplayName, FlxG.camera, characterIcon, color);
						add(characterUnlockObj);
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
						FlxG.save.data.unlockedCharacters.push(characterToUnlock);
					}
				}
		}
	
	public function endIt()
	{
		trace("ENDING");
		MusicBeatState.switchState(new MainMenuState());
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}
	
}