local turn = 10
local turn2 = 20
local y = 0;
local x = 0;
local canFart = false
local Strums = 'opponentStrums'
function onCreate()
    math.randomseed(os.clock() * 1000);
    
    --doTweenAlpha("gone","camHUD",0,0.01)
end
function onBeatHit()
    if curBeat == 240 then
    turn = turn * 4
    end
    if curBeat % 2 == 0 and canFart then 
        turn2 = turn2 * -1
        for i = 0,7 do
            local uhhh = curBeat % 8 * (i + i)
            local swag = i % 4 * 2.5 - uhhh
            if i > 3 then
                x =  getPropertyFromGroup('opponentStrums', i-4, 'x');
            else
                x =  getPropertyFromGroup('playerStrums', i, 'x');
            end
            --noteTweenY("wheeeup"..i,i,y + turn,crochet*0.002,"sineInOut")
            noteTweenX("wheeeleft"..i,i,x + turn2,crochet*0.002,"sineInOut")
        end
    end
    if curBeat % 4 == 0 then
        turn = turn * -1
    end
end

function onStepHit()
    if curStep == 768 then
        canFart = true
        print('iyhufghsdbyiugfdighfedsru')
    end
end