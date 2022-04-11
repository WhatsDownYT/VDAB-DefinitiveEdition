package trolling;

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
        new FlxTimer().start(5, function(tmr:FlxTimer) {
            FlxG.switchState(new SusStateSCARY());
        });
    }
}