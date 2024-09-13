function [dx,dy,newTheta]=findVector(xSeq,ySeq,previousPoint,headPoint,tailPoint,L,previousTheta)

x1=[xSeq(headPoint:end) xSeq(1:headPoint-1)];
y1=[ySeq(headPoint:end) ySeq(1:headPoint-1)];
x2=[fliplr(xSeq(1:headPoint)) fliplr(xSeq(headPoint+1:end))];
y2=[fliplr(ySeq(1:headPoint)) fliplr(ySeq(headPoint+1:end))];

thetas=1:360;

thetaBounds=[];
if isempty(previousTheta)
    thetas=1:360;
else
    thetas=previousTheta-90:previousTheta+90;
end
for i=1:length(thetas)
    if thetas(i)<1
        thetas(i)=360+thetas(i);
    end
end

if ~isempty(previousTheta)
    dx=cos(previousTheta/180*pi);
    dy=sin(previousTheta/180*pi);
    previousVector=[dx dy]/norm([dx dy]);
    perpVector=[-previousVector(2);previousVector(1)];
    ln=perpVector*(-25:25);
    lnx=previousPoint(1)+ln(1,:);
    lny=previousPoint(2)+ln(2,:);
    [tempx,tempy,a,aa] = intersections(x1,y1,lnx,lny,0);  %all I care about is "a", the index of x1/y1 that intersects the perpendicular point
    [tempx,tempy,b,aa] = intersections(x2,y2,lnx,lny,0); %ditto for b
    a=round(a);b=round(b);

    a=min(a);b=min(b);
    x1=x1(a:end);y1=y1(a:end);
    x2=x2(b:end);y2=y2(b:end);

end


i=1;
for theta=thetas
    dx=L*cos(theta/180*pi);
    dy=L*sin(theta/180*pi);
    
    vector=[dx dy];
    newPoint=previousPoint+vector;
    [index1,pointOut1,distanceToPoint1]=closestPoint(xSeq,ySeq,newPoint);
    dist1(i)=distanceToPoint1;
    ind1(i)=index1;
    
    i=i+1;
end

[MAX,MIN1]=peakdet(dist1,0.5);

temp=MIN1(:,1);

a=temp(1);b=temp(2); %identifies the two thetas that contain the correct spline
thetaBounds=[0 0];
thetaBounds(1)=thetas(a); thetaBounds(2)=thetas(b);


% thetaBounds(1)=thetaBounds(1)+10;
% thetaBounds(2)=thetaBounds(2)-10;

% if thetaBounds(1)>360
%     thetaBounds(1)=thetaBounds(1)-360;
% end
% if thetaBounds(2)<1
%     thetaBounds(2)=thetaBounds(2)+360;
% end



% indices=ind(thetaBounds);
% thetaBounds=thetaBounds+thetas(1)-1;
figure(1)
plot(xSeq,ySeq)
hold on
% plot(xSeq(indices),ySeq(indices),'xr');
plot(previousPoint(1),previousPoint(2),'xr');

if length(thetaBounds)~=2
    disp('theta bounds is not 2')
end

% newTheta=mean(thetaBounds);
% dx=previousPoint(1)+L*cos(newTheta);
% dy=previousPoint(2)+L*sin(newTheta);


if thetaBounds(2)<thetaBounds(1)
    tb1=thetaBounds(1); tb2=thetaBounds(2);
    thetaBounds(1)=tb2; thetaBounds(2)=tb1;
end

ang1=thetaBounds(2)-thetaBounds(1);
ang2=thetaBounds(1)+360-thetaBounds(2);
%if ang1 is correct then the proper sequence of angles is
%thetaBounds1:thetaBounds2
%if ang2 is correct then the proper sequence of angles is
%thetaBounds2:thetaBounds1, with the caveat that you may cross over 360
%again.
if ang1<ang2
    t=thetaBounds(1):thetaBounds(2);
elseif ang2<ang1
    t=[thetaBounds(2):360 1:thetaBounds(1)];
end
    

area1=[];
area2=[];
i=1;
for theta=t
    dx=L*cos(theta/180*pi);
    dy=L*sin(theta/180*pi);
    
    vector=[dx dy];
    [a1,a2]=findArea(xSeq,ySeq,vector,previousPoint);
    area1=[area1 a1];
    area2=[area2 a2];
    i=i+1;
end
% theta=thetaBounds(1):thetaBounds(2);
area=abs(area1-area2);
loc=find(area==min(area));
splineAngle=t(loc);
dx=L*cos(splineAngle/180*pi);
dy=L*sin(splineAngle/180*pi);
newTheta=splineAngle;

plot(previousPoint(1)+dx,previousPoint(2)+dy,'rx','MarkerSize',12)

% figure(1);
% plot(dist);


function [area1,area2]=findArea(xSeq,ySeq,vector,start)
% close(figure(5))
% figure(5)
% plot(xSeq,ySeq)
% hold on
% plot([start(1) start(1)+vector(1)],[start(2) start(2)+vector(2)],'b');

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

% plot(xSeq(points),ySeq(points),'r','LineWidth',3)

xSeq=fliplr(xSeq);ySeq=fliplr(ySeq);
[closestx,closesty,distalBoundary]=minimizeDistance2([-vector(2) vector(1)],xSeq,ySeq,start(1)+vector(1),start(2)+vector(2));
[closestx,closesty,proximalBoundary]=minimizeDistance2([-vector(2) vector(1)],xSeq,ySeq,start(1),start(2));
if distalBoundary<proximalBoundary
    points=[proximalBoundary:length(xSeq) 1:distalBoundary];
else
    points=proximalBoundary:distalBoundary;

end
area2=polyarea([xSeq(points) start(1)+vector(1) start(1)],[ySeq(points) start(2)+vector(2) start(2)]);

% plot(xSeq(points),ySeq(points),'c','LineWidth',3)
% disp(area1)
% disp(area2)
% disp('done')

function [index,pointOut,distanceToPoint]=closestPoint(xSeq,ySeq,pointIn)
dist=zeros(1,length(xSeq));
for i=1:length(xSeq)
    dist(i)=norm([xSeq(i)-pointIn(1) ySeq(i)-pointIn(2)]);
end
index=find(dist==min(dist));

distanceToPoint=dist(index);
pointOut=[xSeq(index) ySeq(index)];
