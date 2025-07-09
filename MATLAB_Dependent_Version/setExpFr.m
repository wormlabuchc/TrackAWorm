function setExpFr(vid, expValue, frameValue)
vid.FramesPerTrigger = frameValue;
if expValue == 1
    vid.TriggerFrameDelay = 0;    
elseif expValue == .5
    x = 2-frameValue;
    vid.TriggerFrameDelay = x;
elseif expValue == .25
    x = 3-frameValue;
    vid.TriggerFrameDelay = x;
elseif expValue == .2
    x = 4-frameValue;
    vid.TriggerFrameDelay = x;
elseif expValue == .1
    x = 8-frameValue;
    vid.TriggerFrameDelay = x;
end
    
            
            