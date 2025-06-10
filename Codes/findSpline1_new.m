function [xCenterLine,yCenterLine,xcross,ycross]=findSpline1_new(imgOrig,xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,prevX,prevY)

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

% figure;plot(xSeq,ySeq); hold on; plot(xSeq2,ySeq2)

[hx,hy,tx,ty]=splitSpur(spurx,spury,spurs,head,tail,branchx,branchy);

% plot(loopx,loopy,'k')

if ~isClockwise(loopx,loopy)
    loopx=fliplr(loopx);
    loopy=fliplr(loopy);
    disp('loop was counterclockwise)')
end

if ~isempty(prevX)
    [xCenterLine,yCenterLine,xcross,ycross]=buildWorm(hx,hy,tx,ty,loopx,loopy,prevX,prevY);
else
    figure;plot(hx,hy);hold on;plot(tx,ty,'r');plot(loopx,loopy,'k');
    xCenterLine=0; yCenterLine=0; xcross=0; ycross=0;
end
    
    
    function [headSpurX,headSpurY,tailSpurX,tailSpurY]=splitSpur(spurx,spury,spurs,head,tail,branchx,branchy)

%find the distance between the branches and head/tail

d=zeros(1,length(branchx));
for i=1:length(branchx)
    dh=ptDist(branchx(i),branchy(i),head(1),head(2));
    dt=ptDist(branchx(i),branchy(i),tail(1),tail(2));
    d(i)=dh+dt;
end
closestBranch=find(d==min(d));
proximalBranch=[branchx(closestBranch) branchy(closestBranch)];  %this is the branch that we will build spurs from

%construct the head spur below

atTheBranch=0;
lastPoint=head;
endpt=bwmorph(spurs,'endpoints');
[xe,ye]=edgesToCoordinates(endpt);
dh=zeros(1,length(xe));
for i=1:length(xe)
    dh(i)=ptDist(xe(i),ye(i),head(1),head(2));
end
closestToHead=find(dh==min(dh));
indClosest=intersect(find(spurx==xe(closestToHead)),find(spury==ye(closestToHead)));


closestToHead=[spurx(indClosest) spury(indClosest)];
headSpurX=[closestToHead(1)];
headSpurY=[closestToHead(2)];
currPoint=[closestToHead(1) 480-closestToHead(2)+1];
while ~atTheBranch
    spurs(currPoint(2),currPoint(1))=0;
    currMatrix=spurs(currPoint(2)-1:currPoint(2)+1,currPoint(1)-1:currPoint(1)+1);
    [m,n]=find(currMatrix==1);
    if length(m)>1 || isempty(m)
        atTheBranch=1;
    end
    nextPoint=[currPoint(1)+n-2 currPoint(2)+m-2];
    
    if ptDist(nextPoint(1),480-nextPoint(2)+1,proximalBranch(1),proximalBranch(2))<2
        atTheBranch=1;
    end
    headSpurX=[headSpurX nextPoint(1)];
    headSpurY=[headSpurY 480-nextPoint(2)+1];

    currPoint=nextPoint;
end
dx=abs(headSpurX(1)-head(1));
dy=abs(headSpurY(1)-head(2));
if dx>5 || dy>5
    tempx=linInterp(head(1),headSpurX(1),10);
    tempy=linInterp(head(2),headSpurY(1),10);
else
    tempx=head(1);
    tempy=head(2);
end

if ptDist(headSpurX(1),headSpurY(1),head(1),head(2))>2
    headSpurX=[tempx headSpurX];
    headSpurY=[tempy headSpurY];
end


% plot(headSpurX,headSpurY,'r')
%construct the tail spur below

atTheBranch=0;
lastPoint=tail;
dh=zeros(1,length(spurx));
for i=1:length(spurx)
    dh(i)=ptDist(spurx(i),spury(i),tail(1),tail(2));
end
closestToTail=find(dh==min(dh));
closestToTail=[spurx(closestToTail) spury(closestToTail)];
tailSpurX=[closestToTail(1)];
tailSpurY=[closestToTail(2)];
currPoint=[closestToTail(1) 480-closestToTail(2)+1];
while ~atTheBranch
    spurs(currPoint(2),currPoint(1))=0;
    currMatrix=spurs(currPoint(2)-1:currPoint(2)+1,currPoint(1)-1:currPoint(1)+1);
    [m,n]=find(currMatrix==1);
    if length(m)>1 || isempty(m)
        atTheBranch=1;
    else
        nextPoint=[currPoint(1)+n-2 currPoint(2)+m-2];
    
        if ptDist(nextPoint(1),480-nextPoint(2)+1,proximalBranch(1),proximalBranch(2))<2
            atTheBranch=1;
        end
        tailSpurX=[tailSpurX nextPoint(1)];
        tailSpurY=[tailSpurY 480-nextPoint(2)+1];

        currPoint=nextPoint;

    end
    
end

dx=abs(tailSpurX(1)-tail(1));
dy=abs(tailSpurY(1)-tail(2));
if dx>5 || dy>5
    tempx=linInterp(tail(1),tailSpurX(1),10);
    tempy=linInterp(tail(2),tailSpurY(1),10);
else
    tempx=tail(1);
    tempy=tail(2);
end

if ptDist(tailSpurX(1),tailSpurY(1),tail(1),tail(2))>2
    tailSpurX=[tempx tailSpurX];
    tailSpurY=[tempy tailSpurY];
end

% plot(tailSpurX,tailSpurY,'g')
    
function [x,y,xcross,ycross]=buildWorm(hx,hy,tx,ty,loopx,loopy,prevX,prevY)

xcDiff=mean(prevX)-mean([hx loopx tx]); ycDiff=mean(prevY)-mean([hy loopy ty]);
pxDelta=prevX-xcDiff;
pyDelta=prevY-ycDiff;
headDist=ptDist(hx(1),hy(1),pxDelta(1),pyDelta(1));
tailDist=ptDist(tx(1),ty(1),pxDelta(1),pyDelta(1));
if tailDist<headDist
    thx=hx; thy=hy;
    hx=tx; hy=ty;
    tx=thx; ty=thy;
end

dh=zeros(1,length(loopx));
for i=1:length(loopx)
    dh(i)=ptDist(hx(end),hy(end),loopx(i),loopy(i));
end
closestToHead=find(dh==min(dh));

cwLoopX=[loopx(closestToHead:end) loopx(1:closestToHead-1)];
cwLoopY=[loopy(closestToHead:end) loopy(1:closestToHead-1)];

ccwLoopX=[fliplr(loopx(1:closestToHead-1)) fliplr(loopx(closestToHead:end))];
ccwLoopY=[fliplr(loopy(1:closestToHead-1)) fliplr(loopy(closestToHead:end))];

cwX=[hx cwLoopX fliplr(tx)];
cwY=[hy cwLoopY fliplr(ty)];
[cwX,cwY]=smoothxy(cwX,cwY,5);

% plot(cwX,cwY,'c');

ccwX=[hx ccwLoopX fliplr(tx)];
ccwY=[hy ccwLoopY fliplr(ty)];
[ccwX,ccwY]=smoothxy(ccwX,ccwY,5);

% plot(ccwX,ccwY,'g');

%the following code draws a line across the crossing point for the new
%shape, and uses that line to find the looped part of prevX,prevY in order
%to compare and determine if cwX/cwY or ccwX/ccwY is the best spline.


headDist=ptDist(pxDelta(1),pyDelta(1),cwX(1),cwY(1));
tailDist=ptDist(pxDelta(1),pyDelta(1),cwX(end),cwY(end));
if headDist>tailDist %if the head and tail are not corresponding from previous to current frame, you need to correct that before doing anything with the loop
    pxDelta=fliplr(pxDelta);
    pyDelta=fliplr(pyDelta);
end

% distcw=zeros(1,length(pxDelta));
% distccw=distcw;
% indcw=distcw;
% indccw=distcw;
% for i=1:length(pxDelta)
%     [ind,dist]=findClosestPoint(pxDelta(i),pyDelta(i),cwX,cwY);
%     distcw(i)=dist;
%     indcw(i)=ind;
%     [ind,dist]=findClosestPoint(pxDelta(i),pyDelta(i),ccwX,ccwY);
%     distccw(i)=dist;
%     indccw(i)=ind;
% end
% tempcwx=cwX(sort(indcw));
% tempcwy=cwY(sort(indcw));
% tempccwx=ccwX(sort(indccw));
% tempccwx=ccwY(sort(indccw));

% plot(ccwX,ccwY,'g');

if crosses(cwX,cwY)
    tempx=cwX; tempy=cwY;
else
    tempx=ccwX; tempy=ccwY;
end

[X,Y,I,J]=intersections(tempx,tempy);
lx=[X loopx(closestToHead)];
ly=[Y loopy(closestToHead)];
slope=[lx(2)-lx(1) ly(2)-ly(1)];
slope=slope/norm(slope);
perp=[-slope(2) slope(1)];
ln=-50:50;
lnx=X+perp(1)*ln;
lny=Y+perp(2)*ln;

loopDecided=0;
[X,Y,I,J]=intersections(pxDelta,pyDelta,lnx,lny);
I=sort(I);
if length(I)==1
    pxDelta=pxDelta(ceil(I):end);
    pyDelta=pyDelta(ceil(I):end);
    loopDecided=1;
elseif length(I)==2
    pxDelta=pxDelta(ceil(I(1)):floor(I(2)));
    pyDelta=pyDelta(ceil(I(1)):floor(I(2)));
    loopDecided=1;
end

if ~loopDecided %this statement is for sets of prevX/prevY that, for some reason, intersected lnx/lny more than twice
    crossPrev=crosses(prevX,prevY);
    crossCurr=crosses(cwX,cwY);
    if crossPrev ~= crossCurr
        x=ccwX;
        y=ccwY;
        xcross=cwX;
        ycross=cwY;
        loopdirection=2;
    else
        x=cwX;
        y=cwY;
        xcross=ccwX;
        ycross=ccwY;
        loopdirection=1;
    end
else
    if isClockwise(pxDelta,pyDelta)
        x=cwX;
        y=cwY;
        xcross=ccwX;
        ycross=ccwY;
        loopdirection=1;
    else
        x=ccwX;
        y=ccwY;
        xcross=cwX;
        ycross=cwY;
        loopdirection=2;
    end
end
            


function [xs,ys]=smoothxy(x,y,n)
xs=[];
ys=[];
for i=1+n:n:length(x)-n
    mx=mean(x(i-n:i+n));
    my=mean(y(i-n:i+n));
    xs=[xs mx];
    ys=[ys my];
end

xs=[x(1) xs x(end)];
ys=[y(1) ys y(end)];

