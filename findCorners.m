function [xCorners,yCorners,xPoints,yPoints]=findCorners(x,y,h,bMin)
x=x(1:5:end);
y=y(1:5:end);
xPoints=x;  %x,yPoints are just the lowered resolution points.  This probably will not be needed later.
yPoints=y;
q=2;

xTemp=[x(end-9:end) x x(1:10)];
yTemp=[y(end-9:end) y y(1:10)];
dydx=[];
xCorners=[];
yCorners=[];

b=[];
for i=11:length(xTemp)-10;
    if isClockwise([xTemp(i-q) xTemp(i) xTemp(i+q)],[yTemp(i-q) yTemp(i) yTemp(i+q)])
        xMid=(xTemp(i+q)+xTemp(i-q))/2;
        yMid=(yTemp(i+q)+yTemp(i-q))/2;
        aP=abs(ptDist(xMid,yMid,xTemp(i-q),yTemp(i-q)));
        bP=abs(ptDist(xMid,yMid,xTemp(i),yTemp(i)));
    %     cP=abs(ptDist(xTemp(i-q),yTemp(i-q),xTemp(i),yTemp(i)));
    %     aN=abs(ptDist(xMid,yMid,xTemp(i+q),yTemp(i+q)));
    %     bN=bP;
    %     cN=abs(ptDist(xTemp(i+q),yTemp(i+q),xTemp(i),yTemp(i)));
    %     
    %     chkP=sqrt(aP^2+bP^2);
    %     chkN=sqrt(aN^2+bN^2);
    %     
    %     chkP=abs(chkP-cP);
    %     chkN=abs(chkN-cN);
%         b=[b bP];
        if bP>bMin    %if bP==0, the points are colinear
            xCorners=[xCorners xTemp(i)];
            yCorners=[yCorners yTemp(i)];
        end
    end
    
end
% figure;plot(b);

function I=isPositive(num)
if abs(num)==num
    I=1;
else
    I=0;
end