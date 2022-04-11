--i said i wouldnt use lua but i forgot how to make this shit in haxe lmao
local angleshit = 2;
local anglevar = 2;
local anglefunny = false
local poopoop = false
local uhh = false
function onBeatHit()
	if uhh then    
		if curBeat % 2 == 0 then
			angleshit = anglevar;
		else
			angleshit = -anglevar;
		end

		setProperty('camHUD.angle',angleshit*0.05)
		setProperty('camGame.angle',angleshit*0.02)
		doTweenAngle('turn', 'camHUD', angleshit, stepCrochet*0.0005, 'circOut')
		doTweenX('tuin', 'camHUD', -angleshit*0.05, crochet*0.0003, 'linear')
		doTweenAngle('tt', 'camGame', angleshit, stepCrochet*0.0005, 'circOut')
		doTweenX('ttrn', 'camGame', -angleshit*0.02, crochet*0.0003, 'linear')
    end
end

function onUpdate()
    songPos = getSongPosition()
      local currentBeat = (songPos/1000)*(bpm/200)

    currentBeat = (songPos / 1000) * (bpm / 140)
    if anglefunny then
        setProperty('camHUD.angle',0 - 5 * math.cos((currentBeat*0.25)*math.pi) )
        setProperty('camGame.angle',0 - 3 * math.cos((currentBeat*0.25)*math.pi) )
    end
end

function onStepHit()
	if poopoop then
		if curStep % 4 == 0 then
			doTweenY('rrr', 'camHUD', -0.3, stepCrochet*0.0005, 'circOut')
			doTweenY('rtr', 'camGame.scroll', 0.1, stepCrochet*0.0003, 'sineIn')
            cameraShake('hud', 0.003, 0.2);
		end
		if curStep % 4 == 2 then
			doTweenY('rir', 'camHUD', 0, stepCrochet*0.0005, 'sineIn')
			doTweenY('ryr', 'camGame.scroll', 0, stepCrochet*0.0003, 'sineIn')
            cameraShake('hud', 0.003, 0.2);
		end
	end

    if curStep == 512 then
        anglefunny = true
        poopoop = false
        uhh = false
        print('fortnite battle pass')
    end

    if curStep == 767 then
        anglefunny = false
        poopoop = true
        uhh = true
        print('i just shit, out my ass')
    end

    if curStep == 1023 then
        anglefunny = true
        poopoop = false
        uhh = false
    end

    if curStep == 1280 then
        anglefunny = false
        poopoop = true
        uhh = true
    end

    if curStep == 1408 then
        anglefunny = true
        poopoop = false
        uhh = false
    end

    if curStep == 1920 then
        anglefunny = false
        poopoop = true
        uhh = true
    end

    if curStep == 2176 then
        anglefunny = false
        poopoop = false
        uhh = false
        print('bootin up my pc cuz i need need to get that fortnite battle pass')
    end

    if curStep == 2178 then
        stupid = false
        print('iyhufghsdbyiugfdighfedsru')
    end
end