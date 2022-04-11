import flixel.FlxSprite;
import flixel.FlxState;
import flixel.*;
import flixel.util.FlxTimer;
import flash.system.System;
import openfl.Lib;

class SusState extends FlxState
{
    public static var startSong = true;

    var sus:FlxSprite;

    public function new()
    {
        super();
    }
    override public function create()
    {
        super.create();

        sus = new FlxSprite(0, 0);
        if(startSong)
			FlxG.sound.playMusic(Paths.music("doom", "preload"),1,true);
        sus.loadGraphic(Paths.image("dave/secret/youactuallythoughttherewasasecrethere", "shared"));
        add(sus);
        new FlxTimer().start(5, jumpscare);
    }
    public function jumpscare(bruh:FlxTimer = null)
    {
        sus.loadGraphic(Paths.image("dave/secret/scary", "shared"));
        add(sus);
        FlxG.sound.play(Paths.sound("jumpscare", "preload"), 1, false);
        shakewindow();
        new FlxTimer().start(1, closeGame);
    }
    public function closeGame(time:FlxTimer = null)
    {
        System.exit(0);
    }
    function shakewindow()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x + FlxG.random.int( -10, 10),Lib.application.window.y + FlxG.random.int( -2, 2));
		}, 20);
	}
}