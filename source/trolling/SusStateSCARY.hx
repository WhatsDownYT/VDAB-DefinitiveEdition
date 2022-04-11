package trolling; // for some reason psych (or maybe cuz of haxe 4.2.4) didnt want to make this shit work like how it was before grgrgrg

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.*;
import flixel.util.FlxTimer;
import flash.system.System;
import openfl.Lib;

class SusStateSCARY extends FlxState
{
    public static var fartSong = true;

    var sus:FlxSprite;

    public function new()
    {
        super();
    }
    override public function create()
    {
        super.create();

        sus = new FlxSprite(0, 0);
        if(fartSong)
			FlxG.sound.playMusic(Paths.music("SCARYjumpscare3AMDONTWATCH", "preload"),1,true);
        sus.loadGraphic(Paths.image("dave/secret/ahh", "shared"));
        add(sus);
        #if desktop
        shakewindow();
        #end

        new FlxTimer().start(1, function(tmr:FlxTimer) {
           closeGame();
        });
    }
    public function closeGame(time:FlxTimer = null)
    {
        System.exit(0);
    }
    #if desktop
    function shakewindow()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x + FlxG.random.int( -600, 600),Lib.application.window.y + FlxG.random.int( -50, 50));
		}, 20);
	}
    #end
}