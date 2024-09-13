function [cornerLocations]=findConcaveCorners(x,y)
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
    if ~isClockwise([xTemp(i-q) xTemp(i) xTemp(i+q)],[yTemp(i-q) yTemp(i) yTemp(i+q)])
        possibleCorners=[possibleCorners i-q];
    end

end

[MAXTAB, MINTAB] = peakdet(h, 5);
cornerLocations=[];
points=[];
for i=1:length(MAXTAB)
    if length(cornerLocations)<2
        indexMax=find(MAXTAB(:,2)==max(MAXTAB(:,2)));
        maxtemp=MAXTAB(:,1);
        index=maxtemp(indexMax);
        if ismember(index,possibleCorners)
            cornerLocations=[cornerLocations index];
        end

        MAXTAB=[MAXTAB(1:indexMax-1,:); MAXTAB(indexMax+1:end,:)];
    end
end
