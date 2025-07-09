vid = videoinput('tisimaq_r2013_64',1,'RGB24 (640x480) [Skipping 2x]');
src = getselectedsource(vid);

triggerconfig(vid,'manual');
set(vid, 'LoggingMode','memory');
set(vid, 'TimeOut',30);

framerate = 15;
set(src,'FrameRate',18);

rectime = 300;

vid.FramesPerTrigger = 15;

tic

for i=1:rectime
    
    start(vid);
    trigger(vid);
    
    tempFrameFile = ['tempFrameFile_' num2str(i) '.bi'];
    tempFrameFile = fopen(tempFrameFile,'w');
    
    tempTimeFile = ['tempTimeFile_' num2str(i) '.bi'];
    tempTimeFile = fopen(tempTimeFile,'w');
    
    wait(vid,30);
    [f,t] = getdata(vid);
    
    fwrite(tempFrameFile,f,'uint8'); fwrite(tempTimeFile,t,'double');
    fclose('all');
    
end

toc

disp('THINKING');

pause(3);

fclose('all');

for i=1:rectime
    
    tempFrameFileName = ['tempFrameFile_' num2str(i) '.bi'];
    tempFrameFile = fopen(tempFrameFileName);
    
    tempTimeFileName = ['tempTimeFile_' num2str(i) '.bi'];
    tempTimeFile = fopen(tempTimeFileName);
    
    frameData = fread(tempFrameFile,Inf,'uint8');
    frameData = reshape(frameData,[480 640 3 15]);
    
    timeData = fread(tempTimeFile,15,'double');
    
    for j=1:size(frameData,4)
        
        frameNum = (j-1)*i+1;
        
        path = ['C:\Users\Connelly\Documents\MATLAB\Wormtracker - WORKING VERSION\testImages\testImage_' num2str(frameNum) '.bmp'];
        imwrite(uint8(frameData(:,:,:,j)),path,'bmp');
    end
    
    fclose('all');
    
    delete(tempFrameFileName); delete(tempTimeFileName);
    
end

toc

disp('SAVING COMPLETE');
