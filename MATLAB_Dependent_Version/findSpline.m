function [x1,y1,x2,y2]=findSpline2(xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,L,prevX,prevY)
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

figure
plot(xSeq,ySeq)
hold on
plot(xSeq2,ySeq2)
    
x1=[xSeq(headPt:end) xSeq(1:headPt-1)];
y1=[ySeq(headPt:end) ySeq(1:headPt-1)];
x2=[fliplr(xSeq(1:headPt)) fliplr(xSeq(headPt+1:end))];
y2=[fliplr(ySeq(1:headPt)) fliplr(ySeq(headPt+1:end))];
resolved=0;
justResolved=0;
while ~finished

    [newPoint,newTheta,newAngDiff,newWidth,newEdges]=findNextPoint(x1,y1,x2,y2,previousPoint,previousTheta,L);
    %find area
    newPoint
    newTheta

    if ~isempty(newPoint) && ~isempty(newTheta)
        vector=[newPoint(1)-previousPoint(1) newPoint(2)-previousPoint(2)];
    end

    angDiffs=[angDiffs newAngDiff];
    widths=[widths newWidth];
    points=[points newPoint'];
    thetas=[thetas newTheta];
    edges=[edges newEdges'];

    data.angDiffs=angDiffs;
    data.widths=widths;
    data.thetas=thetas;
    data.edges=edges;
    data.prevX=prevX;
    data.prevY=prevY;

    if ~isempty(previousTheta) && resolved==0
        if angDiffs(end)>2*mean(angDiffs(1:end-1)) || widths(end)>2*mean(widths(1:end-1)) || isempty(newTheta) || isempty(newPoint) %|| areas(end)>2*mean(areas(1:end-1)) 
            disp('possible branch point reached');
            data.headPt=headPt;

            if length(points(1,:))>1
                branchPoint=points(:,end-1);
                edgeBranchPoints=edges(:,end-1);
                data.edgeBranchPoints=edgeBranchPoints;

            elseif length(points(1,:))==1
                branchPoint=[xSeq(headPt);ySeq(headPt)];
            end
            [x1,y1,x2,y2]=resolveBranch(xSeq,ySeq,xSeq2,ySeq2,branchPoint,data);
            resolved=1;

            return
        else

        end
    end   

    if ~justResolved
        plot(previousPoint(1),previousPoint(2),'rx')
        plot(newPoint(1),newPoint(2),'rx')

        previousPoint=newPoint;
        previousTheta=newTheta;
    end
    justResolved=0;


end


function [newPoint,newTheta,angDiff,width,edges]=findNextPoint(x1,y1,x2,y2,previousPoint,previousTheta,L)
done=0;
LL=round(length(x1)/5);
x1o=x1; x2o=x2; y1o=y1; y2o=y2;

while ~done
    if ~isempty(previousTheta)
        dx=cos(previousTheta);
        dy=sin(previousTheta);
        previousVector=[dx dy]/norm([dx dy]);
        perpVector=[-previousVector(2);previousVector(1)];
        ln=perpVector*(-25:25);
        lnx=previousPoint(1)+ln(1,:);
        lny=previousPoint(2)+ln(2,:);

        [tempx,tempy,aCutoff,aa] = intersections(x1,y1,lnx,lny,0);  %all I care about is "aCutoff", the index of x1/y1 that intersects the perpendicular point
        [tempx,tempy,bCutoff,aa] = intersections(x2,y2,lnx,lny,0); %ditto for b
        aCutoff=round(aCutoff);bCutoff=round(bCutoff);
        aCutoff=min(aCutoff); bCutoff=min(bCutoff);
        plot(lnx,lny) 
        plot(x1(aCutoff),y1(aCutoff),'ko')
        plot(x2(bCutoff),y2(bCutoff),'ko')
        
        if isempty(aCutoff) || isempty(bCutoff) || mean([x1(aCutoff) y1(aCutoff)] == [x2(bCutoff) y2(bCutoff)])
            disp('straight line cutoff phase encountered an error')
            newPoint=[];
            newTheta=[];
            angDiff=[];
            width=[];
            edges=[];
            return
        else
            aCutoff=min(aCutoff);bCutoff=min(bCutoff);
            x1=x1(aCutoff:aCutoff+LL);y1=y1(aCutoff:aCutoff+LL);
            x2=x2(bCutoff:bCutoff+LL);y2=y2(bCutoff:bCutoff+LL);
            done=1;
        end

    else
        x1=x1(1:LL);
        y1=y1(1:LL);
        x2=x2(1:LL);
        y2=y2(1:LL);
        done=1;
    end

end

done=0;
tries=0;

while ~done
    thetas=0:2*pi/360:2*pi;
    dx=L*cos(thetas);
    dy=L*sin(thetas);
    curvex=previousPoint(1)+dx;
    curvey=previousPoint(2)+dy;
    plot(curvex,curvey)
    [tempx,tempy,a,aa] = intersections(x1,y1,curvex,curvey,0);  %all I care about is "a", the index of x1/y1 that intersects the curve
    [tempx,tempy,b,bb] = intersections(x2,y2,curvex,curvey,0);  %ditto

    if isempty(a) || isempty(b)
%         disp('curve cutoff phase encountered an error')
%         plot(lnx,lny)
%         L=L*1.25;
%         if tries==1
%             L=L*.5;
%         elseif tries==2
            newPoint=[];
            newTheta=[];
            angDiff=[];
            width=[];
            edges=[];
            return
%         end
%         tries=tries+1;

%         pause
    elseif ~isempty(a) && ~isempty(b)
        done=1;
    end
    
    
end

a=round(a); b=round(b); aa=round(aa); bb=round(bb);
angA=thetas(aa);
angA
angB=thetas(bb);
angB
plot(x1(a),y1(a),'rx')
plot(x2(b),y2(b),'rx')
width=ptDist(x1(a),y1(a),x2(b),y2(b));
[angA,angB]=reformatAngles(angA,angB);
if angB-angA<0
    angDiff=angB+2*pi-angA;
else
    angDiff=angB-angA;
end
angDiff*180/pi

newTheta=mod(angA+angDiff/2,2*pi);
dx=L*cos(newTheta);
dy=L*sin(newTheta);
newPoint=[previousPoint(1)+dx previousPoint(2)+dy];
edgeA=intersect(find(x1o==x1(a)),find(y1o==y1(a)));
edgeB=intersect(find(x2o==x2(b)),find(y2o==y2(b)));
edges=[edgeA edgeB];

function [angA,angB]=reformatAngles(ang1,ang2)
angs=[ang1,ang2];
ang1=min(angs);
ang2=max(angs);
angD=ang2-ang1;
angDReverse=ang1+2*pi-ang2;
if angDReverse<angD
    angA=ang2;
    angB=ang1;
else
    angA=ang1;
    angB=ang2;
end

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

function [x1,y1,x2,y2]=resolveBranch(xSeq,ySeq,xSeq2,ySeq2,branchPoint,data)
headPt=data.headPt;
edgeBranchPoints=data.edgeBranchPoints; edgeA=edgeBranchPoints(1); edgeB=edgeBranchPoints(2);
LL=round(length(xSeq)/10);

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
    case 3
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
I=round(I);
dist=[];
for i=1:length(I)
    ind=I(i);
    d=ptDist(x(mdpt),y(mdpt),x2(ind),y2(ind));
    dist=[dist d];
end
closest=find(dist==min(dist));
point=I(closest);

% function flip=decideToFlip(x2,y2,x1,y1)
