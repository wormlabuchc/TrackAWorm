%This fucntion will look at the curvesToInclude and pick the dominant
%(largest radius) curve among those included.  For example if you are
%interested in curves 1 and 2 for a thrashing worm, this function will
%return curvature for whichever is largest in magnitude for each frame.

function [curvature, n]=analyzeThrashing(filename, framerate, curvesToInclude)

fid=fopen(filename);
data=textscan(fid,'%s','Delimiter','\t');
i=1;
iEnd=length(data{1});
found1=0;
while ~found1 && i~=iEnd+1
    if strcmp(data{1}{i},'1')
        found1=1;
    else
        i=i+1;
    end
end
columns=i-1;
key=[];
for i=1:columns
    key=[key '%s '];
end
fid=fopen(filename);
data=textscan(fid,key,'Delimiter','\t'); %read the data in the correct columns
numCurves=(columns-1)/2;
frames=zeros(length(data{1})-1,1);
curves=zeros(length(frames),numCurves);
vd=[];
currColumn=0;

for i=[1 2:2:columns-1]
    vdColumn=[];
    for j=1:length(frames)
        if i==1
            frames(j)=str2num(data{1}{j+1});
        else
            if ~strcmp(data{i}{j+1},'-')
                curves(j,currColumn)=str2num(data{i}{j+1});
            else
                curves(j,currColumn)=NaN;
            end
            vdColumn=[vdColumn; data{i+1}(j+1)];
        end
    end
    currColumn=currColumn+1;
    vd=[vd vdColumn];
end

curves=curves(:,curvesToInclude);
vd=vd(:,curvesToInclude);

dominantCurve=zeros(length(frames),1);
dominantVD=dominantCurve;

for i=1:length(frames)
    maxCurve=find(curves(i,:)==max(curves(i,:)));
    dominantCurve(i)=curves(i,maxCurve);
    tempVD=vd(i,maxCurve);
    if strcmp(tempVD,'V')
        dominantCurve(i)=dominantCurve(i);
    elseif strcmp(tempVD,'D') || strcmp(tempVD,'U')
        dominantCurve(i)=-dominantCurve(i);
    end
end

time=0:length(dominantCurve)-1;
time=time/framerate;
C=abs(fft(dominantCurve));
df=framerate/(length(C)-1);
f=0:df:framerate;




%the below code will determine the frequency with which the curve flips from dorsal to ventral
n=0;
lastvd=sign(dominantCurve(1));
for i=2:length(frames)
    currvd=sign(dominantCurve(i));
    if currvd~=lastvd
        n=n+1;
        lastvd=currvd;
    end
end
curvature=dominantCurve;