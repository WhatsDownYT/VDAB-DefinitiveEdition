local allowCountdown = false
function onStartCountdown()
    -- blocks the first countdown and starts a timer of 0.8 seconds bla bla wathever
    if not allowCountdown and isStoryMode and not seenCutscene then
        setPropety('isCutscene', true);
        runTimer('startDialogue', 0);
        allowCountdown = true;
        return Function_Stop;
    end
    return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsleft)
    if tag == 'startDialogue' then -- timer completed play dialogue svfshivisdfvsghouhovhfdohgodfh
        startDialogue('dialogue', 'a-new-day')
    end
end

-- dialogue when a dialogue is finished it calls startcounbtdown again thingy
function onNextDialogue(count)
    -- triggered when u press enter and skip a dialogue line that was strill bneing tiped cool
end

local allowEndShit = false

function onEndSong()
    if not allowEndShit and isStoryMode and not seenCutscene then
        setProperty('inCutscene', true);
        startDialogue('dialogue-end', 'a-new-day'); 
        allowEndShit = true;
       return Function_Stop;
    end
    return Function_Continue;
end