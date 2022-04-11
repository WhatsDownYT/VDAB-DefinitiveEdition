package;

import flixel.group.FlxSpriteGroup;
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

class CharacterSelectionState extends MusicBeatState //This is not from the D&B source code, it's completely made by me (Delta).
{
	public static var characterData:Array<Dynamic> = [
        //["character name", /*forms are here*/[["form 1 name", 'character json name'], ["form 2 name (can add more than just one)", 'character json name 2']]/*forms end here*/, /*these are score multipliers for arrows*/[1.0, 1.0, 1.0, 1.0], /*hide it completely*/ true], 
        ["Boyfriend", [["Boyfriend", 'bf']], [1, 1, 1, 1], false], 
        ["Dave", [["Dave", 'dave'], ["Dave (Insanity)", 'dave-insanity'], ["Dave (Splitathon)", 'dave-splitathon'], ["Dave (Old)", 'dave-older']], [0.25, 2, 2, 0.25], false], 
        ["3D Dave", [["3D Dave", 'dave-3d'], ["3D Dave (Old)", 'dave-insanity3d']], [2, 0.25, 0.25, 2], false],
        ["Bambi", [["Bambi", 'bambi'], ["Bambi (Old)", 'bambi-old'], ["Bambi (Splitathon)", 'bambi-splitathon'], ["Bambi (Angry)", 'bambi-mad']], [0, 0, 3, 0], false],
        ["Tristan", [["Tristan", 'tristan']], [2, 0.5, 0.5, 0.5], false], 
        ["Drip Dave", [["Drip Dave", 'dave-drip']], [0.42, 0.69, 0.42, 0.69], true],
        ["Expunged", [["3D Bambi", 'bambi-3d'], ["Unfair Bambi", 'bambi-unfair']], [0, 0, 0, 3], false]
    ];
    var characterSprite:Boyfriend;
    public static var characterFile:String = 'bf';

	var nightColor:FlxColor = 0xFF878787;
    var curSelected:Int = 0;
    var curSelectedForm:Int = 0;
    var curText:FlxText;
    var controlsText:FlxText;
    var formText:FlxText;
    var entering:Bool = false;

    var otherText:FlxText;
    var yesText:FlxText;
    var noText:FlxText;
    var previewMode:Bool = false;
    var unlocked:Bool = true;

    public static var notBF:Bool = false;

    var arrowStrums:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

    var scoreMultipliersText:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

    public static var scoreMultipliers:Array<Float> = [1, 1, 1, 1];

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

    override function create() 
    {
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];
        scoreMultipliers = [1, 1, 1, 1];
        characterFile = 'bf';
        notBF = false;
        FlxG.sound.playMusic(Paths.music('good-ending'));
		Conductor.changeBPM(110);
        
        if(PlayState.isFreeplay)
            {
                var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/sky_night'));
                bg.antialiasing = true;
                bg.scrollFactor.set(0.9, 0.9);
                bg.active = false;
                add(bg);
            
                var stageHills:FlxSprite = new FlxSprite(-225, -125).loadGraphic(Paths.image('dave/hills_night'));
                stageHills.setGraphicSize(Std.int(stageHills.width * 1.25));
                stageHills.updateHitbox();
                stageHills.antialiasing = true;
                stageHills.scrollFactor.set(1, 1);
                stageHills.active = false;
                add(stageHills);
            
                var gate:FlxSprite = new FlxSprite(-225, -125).loadGraphic(Paths.image('dave/gate_night'));
                gate.setGraphicSize(Std.int(gate.width * 1.2));
                gate.updateHitbox();
                gate.antialiasing = true;
                gate.scrollFactor.set(0.925, 0.925);
                gate.active = false;
                add(gate);
                
                var stageFront:FlxSprite = new FlxSprite(-225, -125).loadGraphic(Paths.image('dave/grass_night'));
                stageFront.setGraphicSize(Std.int(stageFront.width * 1.2));
                stageFront.updateHitbox();
                stageFront.antialiasing = true;
                stageFront.scrollFactor.set(0.9, 0.9);
                stageFront.active = false;
                add(stageFront);
            }
        else
            {
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
            }

		FlxG.camera.zoom = 0.75;
		camHUD.zoom = 0.75;

        if(PlayState.SONG.player1 != "bf")
            {
                otherText = new FlxText(10, 150, 0, 'This song does not use BF as the player,\nor a different version of BF is used.\nDo you want to continue without changing character?\n', 20);
                otherText.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                otherText.size = 55;
                otherText.screenCenter(X);
                add(otherText);
                yesText = new FlxText(FlxG.width / 4, 400, 0, 'Yes', 20);
                yesText.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                yesText.size = 55;
                add(yesText);
                noText = new FlxText(FlxG.width / 1.5, 400, 0, 'No', 20);
                noText.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                noText.size = 55;
                add(noText);
                otherText.cameras = [camHUD];
                yesText.cameras = [camHUD];
                noText.cameras = [camHUD];
            }
        else {
            spawnSelection();
        }

        super.create();
    }

    var selectionStart:Bool = false;

    function spawnArrows()
        {
            for (i in 0...4)
                {
                    // FlxG.log.add(i);
                    var babyArrow:FlxSprite = new FlxSprite(0, 0);
                    
			        babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
			        babyArrow.animation.addByPrefix('green', 'arrowUP');
			        babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			        babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			        babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
    
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
                    babyArrow.scrollFactor.set();
                    babyArrow.ID = i;
    
                    babyArrow.animation.play('static');
                    babyArrow.x += 50;
                    babyArrow.x += ((FlxG.width / 3.5));
                    babyArrow.x -= 10;
                    babyArrow.y += 0;
                    arrowStrums.add(babyArrow);
                    var scoreMulti:FlxText;

                    scoreMulti = new FlxText(FlxG.width / 4, 350, 0, "x" + FlxStringUtil.formatMoney(characterData[curSelected][2][i]), 20);
                    scoreMulti.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                    scoreMulti.size = 20;
                    scoreMulti.x = babyArrow.x;
                    scoreMulti.y = babyArrow.y;
                    scoreMulti.x += 20;
                    scoreMulti.y += 20;
                    scoreMultipliersText.add(scoreMulti);
                }
        }

    function spawnSelection()
        {
            selectionStart = true;
            var tutorialThing:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.image('charSelectGuide'));
		    tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.25));
		    tutorialThing.antialiasing = true;
		    add(tutorialThing);

            curText = new FlxText(0, -100, 0, characterData[curSelected][1][0][0], 20);
            curText.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            curText.size = 50;
            
            controlsText = new FlxText(-125, 125, 0, 'Press P to enter preview mode.', 20);
            controlsText.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            controlsText.size = 20;

            spawnArrows();
            add(arrowStrums);
            add(scoreMultipliersText);

            characterSprite = new Boyfriend(0, 0, "bf");
            add(characterSprite);
            characterSprite.dance();
            characterSprite.screenCenter(XY);
            characterSprite.y += 250;
    
            add(curText);
            add(controlsText);
            curText.cameras = [camHUD];
            controlsText.cameras = [camHUD];
            tutorialThing.cameras = [camHUD];
            arrowStrums.cameras = [camHUD];
            scoreMultipliersText.cameras = [camHUD];
    
            curText.screenCenter(X);
            changeCharacter(0);
        }

    function checkPreview()
        {
            if(previewMode)
                {
                    controlsText.text = "PREVIEW MODE\nPress I to play idle animation.\nPress your controls to play an animation.\n";
                }
            else {
                controlsText.text = "Press P to enter preview mode.";
                characterSprite.playAnim('idle');
            }
        }
    override function update(elapsed)
    {
        if(FlxG.keys.justPressed.P && selectionStart && unlocked && !entering)
            {
                previewMode = !previewMode;
                checkPreview();
            }
        if(selectionStart && !previewMode)
            {
                if(controls.UI_RIGHT_P)
                    {
                        changeCharacter(1);
                    }
                if(controls.UI_LEFT_P)
                    {
                        changeCharacter(-1);
                    }
                if(controls.UI_DOWN_P && unlocked)
                    {
                        changeForm(1);
                    }
                if(controls.UI_UP_P && unlocked)
                    {
                        changeForm(-1);
                    }
                if(controls.ACCEPT && unlocked)
                    {
                        acceptCharacter();
                    }
            }
            else if (!previewMode)
            {
                if(controls.UI_RIGHT_P)
                    {
                        curSelected += 1;
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                    }
                if(controls.UI_LEFT_P)
                    {
                        curSelected =- 1;
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                    }
                if (curSelected < 0)
                    {
                        curSelected = 0;
                    }
                    if (curSelected >= 2)
                    {
                        curSelected = 0;
                    }
                switch(curSelected)
                {
                    case 0:
                        yesText.alpha = 1;
                        noText.alpha = 0.5;
                    case 1:
                        noText.alpha = 1;
                        yesText.alpha = 0.5;
                }
                if(controls.ACCEPT)
                    {
                        switch(curSelected)
                        {
                            case 0:
                                FlxG.sound.music.stop();
                                LoadingState.loadAndSwitchState(new PlayState());
                            case 1:
                                noText.alpha = 0;
                                yesText.alpha = 0;
                                otherText.alpha = 0;
                                curSelected = 0;
                                notBF = true;
                                spawnSelection();
                                
                        }
                    }
            }
            else
                {
                    if(controls.NOTE_LEFT_P)
                        {
                            if(characterSprite.animOffsets.exists('singLEFT'))
                                {
                                    arrowStrums.members[0].animation.play('confirm');
									arrowStrums.members[0].centerOffsets();
									arrowStrums.members[0].offset.x -= 13;
									arrowStrums.members[0].offset.y -= 13;
                                    characterSprite.playAnim('singLEFT');
                                }
                        }
                    if(controls.NOTE_DOWN_P)
                        {
                            if(characterSprite.animOffsets.exists('singDOWN'))
                                {
                                    arrowStrums.members[1].animation.play('confirm');
									arrowStrums.members[1].centerOffsets();
									arrowStrums.members[1].offset.x -= 13;
									arrowStrums.members[1].offset.y -= 13;
                                    characterSprite.playAnim('singDOWN');
                                }
                        }
                    if(controls.NOTE_UP_P)
                        {
                            if(characterSprite.animOffsets.exists('singUP'))
                                {
                                    arrowStrums.members[2].animation.play('confirm');
									arrowStrums.members[2].centerOffsets();
									arrowStrums.members[2].offset.x -= 13;
									arrowStrums.members[2].offset.y -= 13;
                                    characterSprite.playAnim('singUP');
                                }
                        }
                    if(controls.NOTE_RIGHT_P)
                        {
                            if(characterSprite.animOffsets.exists('singRIGHT'))
                                {
                                    arrowStrums.members[3].animation.play('confirm');
									arrowStrums.members[3].centerOffsets();
									arrowStrums.members[3].offset.x -= 13;
									arrowStrums.members[3].offset.y -= 13;
                                    characterSprite.playAnim('singRIGHT');
                                }
                        }
                    if(controls.NOTE_LEFT_R)
                        {
                            arrowStrums.members[0].animation.play('static');
                            arrowStrums.members[0].centerOffsets();
                        }
                    if(controls.NOTE_DOWN_R)
                        {
                            arrowStrums.members[1].animation.play('static');
                            arrowStrums.members[1].centerOffsets();
                        }
                    if(controls.NOTE_UP_R)
                        {
                            arrowStrums.members[2].animation.play('static');
                            arrowStrums.members[2].centerOffsets();
                        }
                    if(controls.NOTE_RIGHT_R)
                        {
                            arrowStrums.members[3].animation.play('static');
                            arrowStrums.members[3].centerOffsets();
                        }
                    if(FlxG.keys.justPressed.I)
                        {
                            characterSprite.playAnim('idle');
                        }
                }
        super.update(elapsed);
    }


    function changeCharacter(change:Int, playSound:Bool = true) 
    {
        
        if(!entering)
            {
        if(playSound)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }
        curSelectedForm = 0;
        curSelected += change;

        if (curSelected < 0)
        {
			curSelected = characterData.length - 1;
        }
		if (curSelected >= characterData.length)
        {
			curSelected = 0;
        }
        if(FlxG.save.data.unlockedCharacters.contains(characterData[curSelected][0]))
            {
                unlocked = true;
            }
        else
            {
                unlocked = false;
            }

        characterFile = characterData[curSelected][1][0][1];

        if(unlocked)
            {
                curText.text = characterData[curSelected][1][0][0];
                scoreMultipliers = characterData[curSelected][2];
                for (i in 0...characterData[curSelected][2].length)
                    {
                        scoreMultipliersText.members[i].text = "x" + FlxStringUtil.formatMoney(characterData[curSelected][2][i]);
                    }
                reloadCharacter();
            }
        else if(!characterData[curSelected][3])
            {
                curText.text = "???";
                scoreMultipliers = [0, 0, 0, 0];
                for (i in 0...characterData[curSelected][2].length)
                    {
                        scoreMultipliersText.members[i].text = "x?.??";
                    }
                reloadCharacter();
            }
        else
            {
                changeCharacter(change, false);
            }

        curText.screenCenter(X);
            }
    }

    function changeForm(change:Int) 
        {
            if(!entering)
            {
            if(characterData[curSelected][1].length >= 2)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                curSelectedForm += change;
    
                if (curSelectedForm < 0)
                {
                    curSelectedForm = characterData[curSelected][1].length;
                    curSelectedForm = curSelectedForm - 1;
                }
                if (curSelectedForm >= characterData[curSelected][1].length)
                {
                    curSelectedForm = 0;
                }
                curText.text = characterData[curSelected][1][curSelectedForm][0];
                characterFile = characterData[curSelected][1][curSelectedForm][1];

                reloadCharacter();
        
                curText.screenCenter(X);
            }
            }
        }

    function reloadCharacter()
        {
            characterSprite.destroy();
            characterSprite = new Boyfriend(0, 0, characterFile);
            add(characterSprite);
            characterSprite.updateHitbox();
            characterSprite.dance();

            characterSprite.screenCenter(XY);
            characterSprite.y += 250;
            if(!unlocked)
                {
                    characterSprite.color = FlxColor.BLACK;
                }
            switch(characterData[curSelected][0])
            {
                case "Bambi":
                    characterSprite.y += 50;
                case "Dave":
                    characterSprite.y -= 80;
                case "3D Dave":
                    characterSprite.y -= 110;
            }
            switch(characterData[curSelected][1][curSelectedForm][0])
            {
                case "3D Dave (Old)":
                    characterSprite.x -= 60;
                    characterSprite.y -= 120;
            }
        }


    function acceptCharacter() 
    {
        if(!entering)
        {
        entering = true;
        if(characterData[curSelected][1][0][0] != "Boyfriend")
            notBF = true;
        if(characterSprite.animOffsets.exists('hey') && characterSprite.animation.getByName('hey') != null)
            {
                characterSprite.playAnim('hey');
            }
        else
            {
                characterSprite.playAnim('singUP');
            }
        FlxG.sound.playMusic(Paths.music('gameOverEnd'));
        new FlxTimer().start(3, function(tmr:FlxTimer)
			{
                FlxG.sound.music.stop();
                PlayState.SONG.player1 = characterFile;
                LoadingState.loadAndSwitchState(new PlayState());
			});
        }
    }
}

class CharacterUnlockObject extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null, characterIcon:String, color:FlxColor = FlxColor.BLACK)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var characterBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, color);
		characterBG.scrollFactor.set();

		var characterIcon:HealthIcon = new HealthIcon(characterIcon, false);
        characterIcon.animation.curAnim.curFrame = 2;
        characterIcon.x = characterBG.x + 10;
        characterIcon.y = characterBG.y + 10;
		characterIcon.scrollFactor.set();
		characterIcon.setGraphicSize(Std.int(characterIcon.width * (2 / 3)));
		characterIcon.updateHitbox();
		characterIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var characterName:FlxText = new FlxText(characterIcon.x + characterIcon.width + 20, characterIcon.y + 16, 280, name, 16);
		characterName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterName.scrollFactor.set();

		var characterText:FlxText = new FlxText(characterName.x, characterName.y + 32, 280, "Play as this character in freeplay!", 16);
		characterText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterText.scrollFactor.set();

		add(characterBG);
		add(characterName);
		add(characterText);
		add(characterIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		characterBG.cameras = cam;
		characterName.cameras = cam;
		characterText.cameras = cam;
		characterIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}