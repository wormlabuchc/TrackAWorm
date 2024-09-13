function [startPt, perpVector]=perpendicularAvg(xPoints,yPoints)

diffs=zeros(length(xPoints)-1,2);
for i=1:length(xPoints)-1
    dx=xPoints(i+1)-xPoints(i);
    dy=yPoints(i+1)-yPoints(i);
    
    dx2=dx/norm([dx dy]); %unit vector
    dy2=dy/norm([dx dy]);
    dx=dx2;dy=dy2;
    diffs(i,1)=dx;diffs(i,2)=dy;
end

avgDx=mean(diffs(:,1));
avgDy=mean(diffs(:,2));

perpVector=[-avgDy avgDx];
startPt=[median(xPoints) median(yPoints)];