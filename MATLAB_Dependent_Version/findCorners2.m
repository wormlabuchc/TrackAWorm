% function [xCorners,yCorners,xPoints,yPoints]=findCorners2(x,y,h)
function [xCorners,yCorners,headPt,tailPt]=findCorners2(x,y)

xPoints=x;  %x,yPoints are just the lowered resolution points.  This probably will not be needed later.
yPoints=y;
q=round(0.03*length(x));


xTemp=[x(end-q+1:end) x x(1:q)];
yTemp=[y(end-q+1:end) y y(1:q)];
dydx=[];

possibleCorners=[];
h=[];
for i=q+1:length(xTemp)-q;
    PQI=[xTemp(i)-xTemp(i+q) yTemp(i)-yTemp(i+q)];
    PQNQ=[xTemp(i-q)-xTemp(i+q) yTemp(i-q)-yTemp(i+q)];
    
    alpha=acos(dot(PQI,PQNQ)/norm(PQI)/norm(PQNQ));
    
    nq=ptDist(xTemp(i),yTemp(i),xTemp(i+q),yTemp(i+q));
    h=[h nq*sin(alpha)];
    if isClockwise([xTemp(i-q) xTemp(i) xTemp(i+q)],[yTemp(i-q) yTemp(i) yTemp(i+q)])
        possibleCorners=[possibleCorners i-q];
    end

end


%detect peaks in h
[MAXTAB, MINTAB] = peakdet(h, 5);
xCorners=[];
yCorners=[];
cornerLocations=[];
points=[];
for i=1:length(MAXTAB)
    if length(xCorners)<2
    %     index=find(h==max(MAXTAB(:,1)));
        indexMax=find(MAXTAB(:,2)==max(MAXTAB(:,2)));
        maxtemp=MAXTAB(:,1);
        index=maxtemp(indexMax);
        if ismember(index,possibleCorners)
            xCorners=[xCorners x(index)]; yCorners=[yCorners y(index)];
            cornerLocations=[cornerLocations index];
            points=[points index];
        end

        MAXTAB=[MAXTAB(1:indexMax-1,:); MAXTAB(indexMax+1:end,:)];
    end
end
if length(points)==2
    headPt=points(2); tailPt=points(1);
elseif length(points)==1
    headPt=points(1);
    tailPt=[];
elseif length(points)==0
    headPt=[];
    tailPt=[];
end