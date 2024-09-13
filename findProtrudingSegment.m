function [xHead,yHead]=findProtrudingSegment(x,y,headPt)
q=3;
x1=[x(headPt:end) x(1:headPt-1)];
y1=[y(headPt:end) y(1:headPt-1)];
x1=x1(1:round(end/2));
y1=y1(1:round(end/2));

x2=[fliplr(x(1:headPt)) fliplr(x(headPt:end))];
y2=[fliplr(y(1:headPt)) fliplr(y(headPt:end))];
x2=x2(1:round(end/2));
y2=y2(1:round(end/2));

%make a list of all concave angles
concaves=[];

xTemp=[x(end-q+1:end) x x(1:q)]; yTemp=[y(end-q+1:end) y y(1:q)];
for i=q+1:length(x)-q
    v1=[xTemp(i-q)-xTemp(i) yTemp(i-q)-yTemp(i)];
    v2=[xTemp(i+q)-xTemp(i) yTemp(i+q)-yTemp(i)];
    angle=findAngle(v1,v2);
%     plot(x(i),y(i),'+','MarkerSize',12)
    if ~isClockwise([xTemp(i-q) xTemp(i) xTemp(i+q)],[yTemp(i-q) yTemp(i) yTemp(i+q)]) && round(angle) ~= 180
        concaves=[concaves i-q];
    end
%     c=get(gca,'Children');
%     delete(c(1));
%     
end

con={};     %create a cell array of all concave points
for i=1:length(concaves)
    con{i}=[x(concaves(i)),y(concaves(i))];
end

%find angles between each point
alpha1=zeros(1,length(x1)-2*q);
for i=1+q:length(x1)-q
    v1=[x1(i-q)-x1(i) y1(i-q)-y1(i)];
    v2=[x1(i+q)-x1(i) y1(i+q)-y1(i)];
    angle=findAngle(v1,v2);
    alpha1(i-q)=angle;
end

%find the smallest angles
[MAXTAB,MINTAB]=peakdet(alpha1,20);
if ~isempty(MINTAB)
    found=0;
    while ~found% && length(MINTAB(:,1))>1
        ind=MINTAB(1,1);
        if existsIn([x1(ind),y1(ind)],con) %ensure that the angle you have found is concave
            cornerLoc1=ind;
            found=1;
        elseif length(MINTAB(:,1))>1 %if the min is not concave but you have more candidates, delete the first point and move down the list
            MINTAB=MINTAB(2:end,:);
        else %if you have exhausted all options without finding a concave local minimum, give up
            cornerLoc1=length(x1);
            found=1;
        end
    end
else
    cornerLoc1=length(x1);
    
end

alpha2=zeros(1,length(x1)-2*q);
for i=1+q:length(x2)-q
    v1=[x2(i-q)-x2(i) y2(i-q)-y2(i)];
    v2=[x2(i+q)-x2(i) y2(i+q)-y2(i)];
    angle=findAngle(v1,v2);
    alpha2(i-q)=angle;
end

[MAXTAB,MINTAB]=peakdet(alpha2,20);
if ~isempty(MINTAB)
    found=0;
    while ~found% && length(MINTAB(:,1))>1
        ind=MINTAB(1,1);
        if existsIn([x2(ind),y2(ind)],con) %ensure that the angle you have found is concave
            cornerLoc2=ind;
            found=1;
        elseif length(MINTAB(:,1))>1 %if the min is not concave but you have more candidates, delete the first point and move down the list
            MINTAB=MINTAB(2:end,:);
        else %if you have exhausted all options without finding a concave local minimum, give up
            cornerLoc2=length(x2);
            found=1;
        end
    end
else
    cornerLoc2=length(x2);
    
end

if cornerLoc1<cornerLoc2
    cornerLoc=cornerLoc1;
    xp=x1(cornerLoc1); yp=y1(cornerLoc1);
    xTarget=x2; yTarget=y2;
    xStart=x1; yStart=y1;
else
    cornerLoc=cornerLoc2;
    xp=x2(cornerLoc2); yp=y2(cornerLoc2);
    xTarget=x1; yTarget=y1;
    xStart=x2; yStart=y2;
end

%make perpendicular vector from the average of the previous 5 points
dx=mean(diff(xStart(cornerLoc-5:cornerLoc-1)));
dy=mean(diff(yStart(cornerLoc-5:cornerLoc-1)));
perpVector=[-dy dx]/norm([-dy dx]);

[closestx,closesty,pointNum]=minimizeDistance(perpVector,xTarget,yTarget,xp,yp);

x1=xStart(1:cornerLoc);
y1=yStart(1:cornerLoc);
x2=xTarget(1:pointNum);
y2=yTarget(1:pointNum);


[xHead,yHead,cX,cY,oX,oY]=makeCenterLine(x1,y1,x2,y2,0,1);
[xHead,yHead]=divideSpline(xHead,yHead,7);

figure(2);plot(x,y);hold on;plot(x1,y1,'LineWidth',3);plot(x2,y2,'r','LineWidth',3);plot(xHead,yHead,'b.-');

function angle=findAngle(v1,v2)
angle=acos(dot(v1,v2)/norm(v1)/norm(v2));
angle=angle/pi*180;

function yesno=existsIn(coordinate,cell)
yesno=0;
for i=1:length(cell)
    currCoord=cell{i};
    if coordinate(1)==currCoord(1) && coordinate(2)==currCoord(2)
        yesno=1;
    else
    end
end