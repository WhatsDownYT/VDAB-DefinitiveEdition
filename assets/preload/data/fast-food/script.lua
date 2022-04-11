-- actually no they are stinky!!!
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
        setProperty('camHUD.angle',0 - 1 * math.cos((currentBeat*0.25)*math.pi) )
        setProperty('camGame.angle',0 - 0.5 * math.cos((currentBeat*0.25)*math.pi) )
    end
end

function onStepHit()
    if curStep == 120 then
        anglefunny = true
        poopoop = false
        uhh = false
    end
end