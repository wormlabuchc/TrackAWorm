vid = videoinput('dcam', 1, 'Y8_640x480');
src=getselectedsource(vid);
triggerconfig(vid,'manual');
set(vid,'LoggingMode','memory')
set(src,'FrameRate','15')
set(vid,'FramesPerTrigger',3)
set(vid,'FrameGrabInterval',5)
set(vid,'TriggerRepeat',9)
set(vid,'TimeOut',30)
start(vid)
for i=1:10
    trigger(vid);
    wait(vid,30,'logging')
    eval(['[frames' num2str(i) ',timestamp' num2str(i) ']=getdata(vid);'])
end