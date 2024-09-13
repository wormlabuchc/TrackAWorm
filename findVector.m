function [dx,dy,newTheta]=findVector(xSeq,ySeq,xSeq2,ySeq2,omegaAnalysis,previousPoint,headPoint,tailPoint,L,previousTheta)

persistent lastAngDiff lastThetaBounds x1New y1New x2New y2New
if isempty(previousTheta)
    lastAngDiff=[];
    lastThetaBounds=[];
    x1New=[];
    y1New=[];
    x2New=[];
    y2New=[];
end

if ~isempty(x1New)
    x1=x1New;
    y1=y1New;
    x2=x2New;
    y2=y2New;
else
    x1=[xSeq(headPoint:end) xSeq(1:headPoint-1)];
    y1=[ySeq(headPoint:end) ySeq(1:headPoint-1)];
    x2=[fliplr(xSeq(1:headPoint)) fliplr(xSeq(headPoint+1:end))];
    y2=[fliplr(ySeq(1:headPoint)) fliplr(ySeq(headPoint+1:end))];
end


thetas=1:360;

thetaBounds=[];
% if isempty(previousTheta)
    thetas=1:360;
% else
%     thetas=previousTheta-90:previousTheta+90;
% end
for i=1:length(thetas)
    if thetas(i)<1
        thetas(i)=360+thetas(i);
    elseif thetas(i)>360
        thetas(i)=thetas(i)-360;
    end
end

LL=round(length(xSeq)/10);

%the below code removes the prior segments
if ~isempty(previousTheta)
    dx=cos(previousTheta/180*pi);
    dy=sin(previousTheta/180*pi);
    previousVector=[dx dy]/norm([dx dy]);
    perpVector=[-previousVector(2);previousVector(1)];
    ln=perpVector*(-25:25);
    lnx=previousPoint(1)+ln(1,:);
    lny=previousPoint(2)+ln(2,:);
    [tempx,tempy,aCutoff,aa] = intersections(x1,y1,lnx,lny,0);  %all I care about is "aCutoff", the index of x1/y1 that intersects the perpendicular point
    [tempx,tempy,bCutoff,aa] = intersections(x2,y2,lnx,lny,0); %ditto for b
    aCutoff=round(aCutoff);bCutoff=round(bCutoff);

    aCutoff=min(aCutoff);bCutoff=min(bCutoff);
    x1=x1(aCutoff:aCutoff+LL);y1=y1(aCutoff:aCutoff+LL);
    x2=x2(bCutoff:bCutoff+LL);y2=y2(bCutoff:bCutoff+LL);
else
    x1=x1(1:LL);
    y1=y1(1:LL);
    x2=x2(1:LL);
    y2=y2(1:LL);
end

dx=L*cos(thetas/180*pi);
dy=L*sin(thetas/180*pi);
curvex=previousPoint(1)+dx;
curvey=previousPoint(2)+dy;

[tempx,tempy,a,aa] = intersections(x1,y1,curvex,curvey,0);  %all I care about is "a", the index of x1/y1 that intersects the curve
[tempx,tempy,b,bb] = intersections(x2,y2,curvex,curvey,0);  %ditto
a=round(a); b=round(b); aa=round(aa); bb=round(bb);
angA=thetas(aa);
angA
angB=thetas(bb);
angB

if angA>angB
    angTemp=angA;
    angA=angB;
    angB=angTemp;
end
angDiff=min([mod(angB-angA,360) mod(angA-angB,360)]);
angDiff

% thetaBounds=[0 0];
thetaBounds(1)=angA;
thetaBounds(2)=angB;

if angDiff>1.5*lastAngDiff
    disp('branch point reached')
    
    %at this point a large operation needs to be undertaken to reformat the
    %worm shape in order to include the "hole"
    
    ltb1=lastThetaBounds(1); ltb2=lastThetaBounds(2);
    
    [ltb1,ltb2]=reformatAngles(ltb1,ltb2);
    [angA,angB]=reformatAngles(angA,angB);
    
    diff1=abs(ltb1-angA);
    diff2=abs(ltb2-angB);
    
    if ltb1==thetaBounds(1)  %if you flipped the thetaBounds during the reformat, you need to keep track of which side corresponds to which angle
        preserveSides=1;
    else
        preserveSides=0;
    end
    
    if diff1<diff2 && preserveSides
        %draw a line from the large-difference side: from the last boundary
        %point to the closest point on xSeq2/ySeq2
        
        xCont=x1;
        yCont=y1;
        xBreak=x2;
        yBreak=y2;
    
    
    elseif diff1<diff2 && ~preserveSides
        xCont=x2;
        yCont=y2;
        xBreak=x1;
        yBreak=y1;
        
        
        
    elseif diff2<diff1 && ~preserveSides
        xCont=x1;
        yCont=y1;
        xBreak=x2;
        yBreak=y2;
        
        
    elseif diff2<diff1 && preserveSides
        xCont=x2;
        yCont=y2;
        xBreak=x1;
        yBreak=y1;
        
        
    end
    
    figure
    plot(xCont,yCont)
    hold on
    plot(xBreak,yBreak,'g')
    plot(xSeq2,ySeq2,'b')
    
    pointIn=[xBreak(1) yBreak(1)];
    [index,pointOut,distanceToPoint]=closestPoint(xSeq2,ySeq2,pointIn);
    xSeq2=[xSeq2(index:end) xSeq2(1:index-1)];
    ySeq2=[ySeq2(index:end) ySeq2(1:index-1)];
    
    dx=pointOut(1)-pointIn(1);
    dy=pointOut(2)-pointIn(2);
    
    bridgeSlope=[dx dy];
    bridgeSlope=bridgeSlope/norm(bridgeSlope);
    ln=0:floor(distanceToPoint);
    bridgeX=pointIn(1)+ln*bridgeSlope(1);
    bridgeY=pointIn(2)+ln*bridgeSlope(2);
        
    xBreak=[bridgeX xSeq2];
    yBreak=[bridgeY ySeq2];
    
    x1temp=[xSeq(headPoint:end) xSeq(1:headPoint-1)];
    y1temp=[ySeq(headPoint:end) ySeq(1:headPoint-1)];
    x2temp=[fliplr(xSeq(1:headPoint)) fliplr(xSeq(headPoint+1:end))];
    y2temp=[fliplr(ySeq(1:headPoint)) fliplr(ySeq(headPoint+1:end))];

    if mean(xCont==x1) && mean(yCont==y1)
        x1New=x1temp;
        y1New=y1temp;
        x2New=[x2temp(1:bCutoff) xBreak];
        y2New=[y2temp(1:bCutoff) yBreak];
    elseif mean(xCont==x2) && mean(yCont==y2)
        x1New=[x1temp(1:aCutoff) xBreak];
        y1New=[y1temp(1:aCutoff) yBreak];
        x2New=x2temp;
        y2New=y2temp;
    end
        
    %at this point you have basically redefined the entire profile of the
    %worm so reassign it here as a persistent variable and use this instead
    %of xSeq/ySeq

    
    
    
%     xNew=xBreak;
%     yNew=yBreak;
    
    
    
    
    %Recalculate thetabounds with new information.

end

if ~isempty(x1New) && ~isempty(y1New) && ~isempty(x2New) && ~isempty(y2New)
    
    x1=x1New; y1=y1New; x2=x2New; y2=y2New;
    dx=cos(previousTheta/180*pi);
    dy=sin(previousTheta/180*pi);
    previousVector=[dx dy]/norm([dx dy]);
    perpVector=[-previousVector(2);previousVector(1)];
    ln=perpVector*(-25:25);
    lnx=previousPoint(1)+ln(1,:);
    lny=previousPoint(2)+ln(2,:);
    [tempx,tempy,aCutoff,aa] = intersections(x1,y1,lnx,lny,0);  %all I care about is "aCutoff", the index of x1/y1 that intersects the perpendicular point
    [tempx,tempy,bCutoff,aa] = intersections(x2,y2,lnx,lny,0); %ditto for b
    aCutoff=round(aCutoff);bCutoff=round(bCutoff);

    aCutoff=min(aCutoff);bCutoff=min(bCutoff);
    x1=x1(aCutoff:aCutoff+LL);y1=y1(aCutoff:aCutoff+LL);
    x2=x2(bCutoff:bCutoff+LL);y2=y2(bCutoff:bCutoff+LL);


end
% indices=ind(thetaBounds);
% thetaBounds=thetaBounds+thetas(1)-1;
figure(1)
plot(x1,y1)
hold on
plot(x2,y2)
% plot(xSeq(indices),ySeq(indices),'xr');
plot(previousPoint(1),previousPoint(2),'xr');


% if thetaBounds(2)<thetaBounds(1)
%     tb1=thetaBounds(1); tb2=thetaBounds(2);
%     thetaBounds(1)=tb2; thetaBounds(2)=tb1;
% end

% ang1=thetaBounds(2)-thetaBounds(1);
% ang2=thetaBounds(1)+360-thetaBounds(2);
%if ang1 is correct then the proper sequence of angles is
%thetaBounds1:thetaBounds2
%if ang2 is correct then the proper sequence of angles is
%thetaBounds2:thetaBounds1, with the caveat that you may cross over 360
%again.

if abs(angB-angA)>180   %you need to mess with the bounds if theta crosses over 360 deg, I'm sure this can be fixed by using radians in the future
    t=[thetaBounds(2):360 1:thetaBounds(1)];
else
    t=thetaBounds(1):thetaBounds(2);
end
    
if isempty(previousTheta)
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
else
    [angA,angB]=reformatAngles(angA,angB);
    splineAngle=angDiff/2+angA;
end    
splineAngle=mod(splineAngle,360);
dx=L*cos(splineAngle/180*pi);
dy=L*sin(splineAngle/180*pi);
newTheta=splineAngle;

plot(curvex,curvey,'k-')
plot(previousPoint(1)+dx,previousPoint(2)+dy,'rx','MarkerSize',12)

lastAngDiff=angDiff;
lastThetaBounds=thetaBounds;

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

function [angA,angB]=reformatAngles(ang1,ang2)
angs=[ang1,ang2];
ang1=min(angs);
ang2=max(angs);
angD=ang2-ang1;
angDReverse=ang1+360-ang2;
if angDReverse<angD
    angA=ang2;
    angB=ang1;
else
    angA=ang1;
    angB=ang2;
end
