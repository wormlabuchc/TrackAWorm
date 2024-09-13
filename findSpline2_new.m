function [xCenterLine,yCenterLine,xcross,ycross]=findSpline2_new(imgOrig,xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,L,prevX,prevY);

head=[xSeq(headPt),ySeq(headPt)];
tail=[xSeq(tailPt),ySeq(tailPt)];

imgThin=bwmorph(imgOrig,'thin',Inf);
bp=bwmorph(imgThin,'branch');
loop=bwmorph(imgThin,'spur',Inf);
spurs=imgThin-loop;

[thinx,thiny]=edgesToCoordinates(imgThin);
[branchx,branchy]=edgesToCoordinates(bp);

[loopx,loopy]=edgesToCoordinates(loop);
[loopx,loopy]=removeArtifacts(loopx,loopy);
[spurx,spury]=edgesToCoordinates(spurs);

if length(branchx)>1
    disp('branchx>1')
    %MUST ADDRESS THIS CASE
    
    pt=zeros(1,length(branchx));
    k=0;
    for i=1:length(branchx)
        p=intersect(find(loopx==branchx(i)),find(loopy==branchy(i)));
        if ~isempty(p)
            pt(i)=p;
            k=k+1;
        end
    end
    
%     if k==1
%         branchx=branchx(find(pt~=0));
%         branchy=branchy(find(pt~=0));
%     elseif k==0
% 
%     elseif k>1
        while ~isempty(branchx)
            spurs=bwmorph(spurs,'spur',3);
            spurs=bwareaopen(spurs,20);
            [spurx,spury]=edgesToCoordinates(spurs);
            bp=bwmorph(spurs,'branch');
            [branchx,branchy]=edgesToCoordinates(bp);
        end

%     end
    
end

[spurx,spury]=orderPoints(spurx,spury,spurs);
spur1=[spurx(1) spury(1)];
spure=[spurx(end) spury(end)];

if ~isempty(branchx)
    d=[0 0];
    d(1)=ptDist(spur1(1),spur1(2),branchx,branchy);
    d(2)=ptDist(spure(1),spure(2),branchx,branchy);
else
    d=[0 0];
    mlx=mean(loopx);
    mly=mean(loopy);
    d(1)=ptDist(spur1(1),spur1(2),mlx,mly);
    d(2)=ptDist(spure(1),spure(2),mlx,mly);
end


if d(1)<d(2)
    spurx=fliplr(spurx);
    spury=fliplr(spury);
end

d=[0 0];
if ~isempty(headPt) && ~isempty(tailPt)
    d(1)=ptDist(spurx(1),spury(1),xSeq(headPt),ySeq(headPt));
    d(2)=ptDist(spurx(1),spury(1),xSeq(tailPt),ySeq(tailPt));
    if d(2)<d(1)
        point=[xSeq(tailPt) ySeq(tailPt)];
    else
        point=[xSeq(headPt) ySeq(headPt)];
    end
elseif ~isempty(headPt)
    point=[xSeq(headPt) ySeq(headPt)];
elseif ~isempty(tailPt)
    point=[xSeq(tailPt) ySeq(tailPt)];
end

dx=abs(spurx(1)-point(1));
dy=abs(spury(1)-point(2));
if dx>5 || dy>5
    tempx=linInterp(point(1),spurx(1),10);
    tempy=linInterp(point(2),spury(1),10);
else
    tempx=point(1);
    tempy=point(2);
end



spurx=[tempx spurx];
spury=[tempy spury];

if ~isClockwise(loopx,loopy)
    loopx=fliplr(loopx);
    loopy=fliplr(loopy);
end

d=zeros(1,length(loopx));
for i=1:length(loopx)
    d(i)=ptDist(loopx(i),loopy(i),spurx(end),spury(end));
end
loopStart=find(d==min(d));
loopx=[loopx(loopStart:end) loopx(1:loopStart-1)];
loopy=[loopy(loopStart:end) loopy(1:loopStart-1)];


if isempty(prevX)
    vectorA=[mean(diff(spurx(end-5:end))) mean(diff(spury(end-5:end)))];
    vectorB=[mean(diff(loopx(1:5))) mean(diff(loopy(1:5)))];
    vectorC=[-mean(diff(loopx(end-5:end))) -mean(diff(loopy(end-5:end)))];

    AB=acos(dot(vectorA,vectorB)/norm(vectorA)/norm(vectorB));
    AC=acos(dot(vectorA,vectorC)/norm(vectorA)/norm(vectorC));

    if AC<AB
        loopx=fliplr(loopx);
        loopy=fliplr(loopy);
    end
else
    tx=prevX(end-6:end);
    ty=prevY(end-6:end);
    if ~isClockwise(tx,ty)
        loopx=fliplr(loopx);
        loopy=fliplr(loopy);
    end
    
    
    
end
xCenterLine=[spurx loopx];
yCenterLine=[spury loopy];

xcross=[spurx fliplr(loopx)];
ycross=[spury fliplr(loopy)];

%need to figure out if loop should be cw or ccw based on prevX/prevY
