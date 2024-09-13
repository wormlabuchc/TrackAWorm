% [x1,y1,x2,y2]=resolveBranch(xSeq,ySeq,xSeq2,ySeq2,branchPoint,data)


curv1=curvature(x1b,y1b);
curv2=curvature(x2b,y2b);

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
%     midrange=round(length(xbr)/2)-1:round(length(xbr)/2)+1;
% midrange=round(length(xbr)/2);
% pointsToCheck=[1 midrange length(xbr)];

% flip=decideToFlip(xSeq2,ySeq2,unchangedX,unchangedY);

if ~isClockwise(unchangedX,unchangedY)
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
plot(x1,y1,'LineWidth',2)
plot(x2,y2,'r','LineWidth',2)

x1=[x1 tailX];
y1=[y1 tailY];
x2=[x2 tailX];
y2=[y2 tailY];