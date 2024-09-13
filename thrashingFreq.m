%This function determines how many times the worm flips from dorsal to
%ventral and vice versa.  This is done by finding a best-fit circle for
%each frame and then finding the ventral/dorsal direction of the circle.
%Frequency is returned in thrashes per minute.

function [n,freq]=thrashingFreq(splinePath,f)


splineData=load(splinePath);
if length(splineData(1,:))==14 || length(splineData(1,:))==27
    ventralData=splineData(1:2:end-1,1);
    splineData=splineData(:,2:14);
else
    ventralData=ones(length(splineData),1);
    splineData=splineData(:,1:13);
end
totFrames=length(splineData(:,1))/2;

dontSegment=1;
currFrame=1;

if ventralData(1)==0
    ventralData=ventralData+1;
end

lastSign=0;
n=-1; %set n=-1 because the first iteration of the loop it will cause n to become 0.

while currFrame<=totFrames
    frames=(currFrame-1)*2+1:(currFrame-1)*2+2;

    x=splineData(frames(1),:);
    y=splineData(frames(2),:);
    ventralDir=ventralData(currFrame);
    [curvature,vd]=wormCurvature(x,y,ventralDir,dontSegment);
    
    currSign=sign(vd);
    if currSign~=lastSign
        n=n+1;
        lastSign=currSign;
    end
    
    currFrame=currFrame+1;
end

t=totFrames/f/60; %total recording time in minutes
freq=n/t; %thrashes per minute