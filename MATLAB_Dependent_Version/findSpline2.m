function [x,y]=findSpline2(xSeq,ySeq,xSeq2,ySeq2,headPt,L,prevX,prevY)
if sum(prevX)==0 || sum(prevY)==0 % || (prevX(1)-prevX(2)==0 && prevY(1)-prevY(2)==0)
    prevX=[];
    prevY=[];
end
finished=0;
previousPoint=[xSeq(headPt) ySeq(headPt)];
previousTheta=[];
angDiffs=[];
widths=[];
points=[];
thetas=[];
% areas=[];
edges=[];
LL=round(length(xSeq)/10);

% figure
% plot(xSeq,ySeq)
% hold on
% plot(xSeq2,ySeq2)
    
x1=[xSeq(headPt:end) xSeq(1:headPt-1)];
y1=[ySeq(headPt:end) ySeq(1:headPt-1)];
x2=[fliplr(xSeq(1:headPt)) fliplr(xSeq(headPt+1:end))];
y2=[fliplr(ySeq(1:headPt)) fliplr(ySeq(headPt+1:end))];
resolved=0;
justResolved=0;
    
[headx,heady,edges]=findSegment(x1,y1,x2,y2);


branchPoint=[headx(end),heady(end)];
data.headPt=headPt;
data.edges=edges;
data.edgeBranchPoints=edges(:,end);
data.prevX=prevX;
data.prevY=prevY;
[x,y]=resolveBranch(xSeq,ySeq,xSeq2,ySeq2,branchPoint,data);




function [area1,area2]=findArea(xSeq,ySeq,vector,start)

[closestx,closesty,distalBoundary]=minimizeDistance2([vector(2) -vector(1)],xSeq,ySeq,start(1)+vector(1),start(2)+vector(2));
[closestx,closesty,proximalBoundary]=minimizeDistance2([vector(2) -vector(1)],xSeq,ySeq,start(1),start(2));
xSeq=fliplr(xSeq);ySeq=fliplr(ySeq);
proximalBoundary=length(xSeq)-proximalBoundary;
distalBoundary=length(xSeq)-distalBoundary;
if distalBoundary<proximalBoundary
    points=[proximalBoundary:length(xSeq) 1:distalBoundary];
else
    points=proximalBoundary:distalBoundary;
end
area1=polyarea([xSeq(points) start(1)+vector(1) start(1)],[ySeq(points) start(2)+vector(2) start(2)]);
xSeq=fliplr(xSeq);ySeq=fliplr(ySeq);
[closestx,closesty,distalBoundary]=minimizeDistance2([-vector(2) vector(1)],xSeq,ySeq,start(1)+vector(1),start(2)+vector(2));
[closestx,closesty,proximalBoundary]=minimizeDistance2([-vector(2) vector(1)],xSeq,ySeq,start(1),start(2));
if distalBoundary<proximalBoundary
    points=[proximalBoundary:length(xSeq) 1:distalBoundary];
else
    points=proximalBoundary:distalBoundary;

end
area2=polyarea([xSeq(points) start(1)+vector(1) start(1)],[ySeq(points) start(2)+vector(2) start(2)]);

function [x,y]=resolveBranch(xSeq,ySeq,xSeq2,ySeq2,branchPoint,data)
headPt=data.headPt;
prevX=data.prevX;
prevY=data.prevY;
edgeBranchPoints=data.edgeBranchPoints; edgeA=edgeBranchPoints(1); edgeB=edgeBranchPoints(2);
LL=round(length(xSeq)/10);

if ~isempty(prevX) && ~isempty(prevY)
    iterations=2;
    curv1=0;
    curv2=1;
else
    iterations=1;
end

for i=1:iterations
    x1=[xSeq(headPt:end) xSeq(1:headPt-1)];
    y1=[ySeq(headPt:end) ySeq(1:headPt-1)];
    x2=[fliplr(xSeq(1:headPt)) fliplr(xSeq(headPt+1:end))];
    y2=[fliplr(ySeq(1:headPt)) fliplr(ySeq(headPt+1:end))];
    x1o=x1(1:edgeA);
    y1o=y1(1:edgeA);
    x2o=x2(1:edgeB);
    y2o=y2(1:edgeB);
    x1b=x1(edgeA+1:edgeA+LL);
    y1b=y1(edgeA+1:edgeA+LL);
    x2b=x2(edgeB+1:edgeB+LL);
    y2b=y2(edgeB+1:edgeB+LL);
    if iterations==1
        curv1=curvature(x1b,y1b);
        curv2=curvature(x2b,y2b);
    end
    if curv1>curv2   %sorry about all of this....
        xbr=x1b;
        ybr=y1b;
        xorig=x2b;
        yorig=y2b;
        fixedSide=1;
        unchangedX=x2;
        unchangedY=y2;
        headx=x1o;
        heady=y1o;
        fx=x1;
        fy=y1;
        ux=x2;
        uy=y2;
        edge=edgeA;
    else
        xbr=x2b;
        ybr=y2b;
        xorig=x1b;
        yorig=y1b;
        fixedSide=2;
        unchangedX=x1;
        unchangedY=y1;
        headx=x2o;
        heady=y2o;
        fx=x2;
        fy=y2;
        ux=x1;
        uy=y1;
        edge=edgeB;
    end

    cwU=isClockwise(unchangedX,unchangedY);
    cw2=isClockwise(xSeq2,ySeq2);
    if (cwU && ~cw2) || (~cwU && cw2)
        xSeq2=fliplr(xSeq2);
        ySeq2=fliplr(ySeq2);
    end
    point=findClosestPoint(xSeq2,ySeq2,[fx(edge) fy(edge)]);
    [bx,by]=makeBridge([fx(edge) fy(edge)],[xSeq2(point),ySeq2(point)]);

    [tailX,tailY]=midpoint(fx(edge),fy(edge),xSeq2(point),ySeq2(point));

    xNew=[headx bx xSeq2(point:end) xSeq2(1:point-1)];
    yNew=[heady by ySeq2(point:end) ySeq2(1:point-1)];

    point=findPerpPoint(xNew(end-5:end-1),yNew(end-5:end-1),ux,uy,isClockwise(xSeq2,ySeq2));

    ux=ux(1:point);
    uy=uy(1:point);
    switch fixedSide
        case 1
            x1=xNew;
            y1=yNew;
            x2=ux;
            y2=uy;
        case 2
            x2=xNew;
            y2=yNew;
            x1=ux;
            y1=uy;
    end

    x1=[x1 tailX];
    y1=[y1 tailY];
    x2=[x2 tailX];
    y2=[y2 tailY];
    
    curv1=1;
    curv2=0;
    if i==1
        x1orig=x1; y1orig=y1; x2orig=x2; y2orig=y2;
    end
end

if i==2
    try
        [xclo,yclo]=makeCenterLine(x1orig,y1orig,x2orig,y2orig);
        [xclo,yclo]=divideSpline(xclo,yclo,12);

    catch
        xclo=[1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 ];
        yclo=xclo;
    end
    
    try
        [xcl,ycl]=makeCenterLine(x1,y1,x2,y2);
        [xcl,ycl]=divideSpline(xcl,ycl,12);
    catch
        xcl=[1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 1e6 ];
        ycl=xcl;
    end
    
    d=[];
    do=[];
    for i=1:length(xcl)
        d=[d ptDist(xcl(i),ycl(i),prevX(i),prevY(i))];
        do=[do ptDist(xclo(i),yclo(i),prevX(i),prevY(i))];
    end
    d=sum(d); do=sum(do);
    cwprev=isClockwise(prevX(end-5:end),prevY(end-5:end));
    cwo=isClockwise(xclo(end-5:end),yclo(end-5:end));
    cw=isClockwise(xcl(end-5:end),ycl(end-5:end));

    if abs(do-d)>50 && d<do 
        x=xcl;
        y=ycl;
    elseif abs(d-do)>50 && do<d 
        x=xclo;
        y=yclo;
    else
        if (cwprev && cwo) || (~cwprev && ~cwo)
            x=xclo;
            y=yclo;
        else
            x=xcl;
            y=ycl;
        end
    end
%     figure;plot(x1orig,y1orig); hold on; plot(x2orig,y2orig,'r'); plot(xclo,yclo); figure; plot(x1,y1); hold on; plot(x2,y2,'r'); plot(xcl,ycl)
else
    [x,y]=makeCenterLine(x1,y1,x2,y2);
end

function curv=curvature(x,y)
angs=zeros(1,length(x)-1);
for i=2:length(x)-1
    va=[x(i)-x(i-1) y(i)-y(i-1)];
    vb=[x(i)-x(i+1) y(i)-y(i+1)];
    va=va/norm(va);
    vb=vb/norm(vb);
    dotprod=va(1)*vb(1)+va(2)*vb(2);
    ang=abs(pi-acos(dotprod/norm(va)/norm(vb)));
    angs(i-1)=ang;
end
curv=sum(angs);
% figure;plot(angs)

function point=findClosestPoint(x,y,point)
dist=zeros(1,length(x));
for i=1:length(x)
    d=ptDist(point(1),point(2),x(i),y(i));
    dist(i)=d;
end
point=find(dist==min(dist));

function [x,y]=makeBridge(pointA,pointB)
dx=pointB(1)-pointA(1);
dy=pointB(2)-pointA(2);
bridgeSlope=[dx dy];
bridgeSlope=bridgeSlope/norm(bridgeSlope);
distanceToPoint=ptDist(pointA(1),pointA(2),pointB(1),pointB(2));
ln=0:floor(distanceToPoint);
x=pointA(1)+ln*bridgeSlope(1);
y=pointA(2)+ln*bridgeSlope(2);

function point=findPerpPoint(x,y,x2,y2,clockwise)
if clockwise
    ln=0:50;
else
    ln=-50:0;
end
mdx=mean(diff(x));
mdy=mean(diff(y));
mdpt=round(length(x)/2);
perpVect=[-mdy mdx];
perpVect=perpVect/norm(perpVect);
% ln=-25:25;
lnx=x(mdpt)+perpVect(1)*ln;
lny=y(mdpt)+perpVect(2)*ln;
% plot(lnx,lny)
% pause
[X0,Y0,I,J] = intersections(x2,y2,lnx,lny,0);

% plot(lnx,lny)

I=round(I);
dist=[];
for i=1:length(I)
    ind=I(i);
    d=ptDist(x(mdpt),y(mdpt),x2(ind),y2(ind));
    dist=[dist d];
end
closest=find(dist==min(dist));
point=I(closest);

function Inew=findClosestIntersection(x,y,xSeq,ySeq,I);
I=round(I);
d=zeros(1,length(I));
for i=1:length(I)
    d(i)=ptDist(xSeq(I(i)),ySeq(I(i)),x,y);
end
minDist=find(d==min(d));
Inew=I(minDist);
