function [xNew,yNew]=orderPoints(x,y,spurs)

ep=bwmorph(spurs,'end');
[epx,epy]=edgesToCoordinates(ep);
xOriginal=x;
yOriginal=y;

xCurve=[];
yCurve=[];
x=xOriginal;
y=yOriginal;
startPoint=intersect(find(epx(1)==x),find(epy(1)==y));
xPrev=x(startPoint);
yPrev=y(startPoint);  %This is a stupid way to do it but I'm leaving it like this for now.

for i=1:length(x)
    [xClosest,yClosest,xNew,yNew]=closestPoints(xPrev,yPrev,x,y);

    xCurve=[xCurve xClosest];
    yCurve=[yCurve yClosest];
    xPrev=xClosest;
    yPrev=yClosest;
    x=xNew;
    y=yNew;
end

xNew=xCurve;
yNew=yCurve;