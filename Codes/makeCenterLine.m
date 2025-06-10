function [mX,mY,cX,cY,oX,oY]=makeCenterLine(x1,y1,x2,y2,keepTail,q)
if nargin==4
    keepTail=1;
    q=3;
end
    
n=8;
seg=25;

% if length(x1)<9 || length(x2)<9
%     factor=5;
%     [x1,y1]=upsample(x1,y1,5);
%     [x2,y2]=upsample(x2,y2,5);
% end

% figure
% plot(x1,y1);hold on;plot(x2,y2,'r')

if length(x1)>length(x2)  %testing - start line from the longer rather than shorter segment
    x=x2; y=y2;
    xp=x1; yp=y1;
else
    
    x=x1; y=y1;
    xp=x2; yp=y2;

end
l=length(x);

interval=floor(l/seg);

hX=x1(1);   %make the head the first point
hY=y1(1);
if x1(end)==x2(end) && y1(end)==y2(end)
    tX=x1(end);
    tY=y1(end);
else
    [tX,tY]=midpoint(x1(end),y1(end),x2(end),y2(end));
end

cX=[];
cY=[];
as=[];

i=2*interval;
while i<=length(x)-interval*1
        v=[-mean(diff(y(i-q:i+q))); mean(diff(x(i-q:i+q)))];
        vu=v/sqrt(v(1)^2+v(2)^2);   %vu is a unit vector
        
        
        if i==2*interval
            ln=-30:30;
            lnx=x(i)+vu(1)*ln;
            lny=y(i)+vu(2)*ln;
            [closestx,closesty,a,b] = intersections(xp,yp,lnx,lny,1);
            
            if isempty(a);
                i=4*interval;
                v=[-mean(diff(y(i-q:i+q))); mean(diff(x(i-q:i+q)))];
                vu=v/sqrt(v(1)^2+v(2)^2);

                lnx=x(i)+vu(1)*ln;
            	lny=y(i)+vu(2)*ln;

                [closestx,closesty,a,b] = intersections(xp,yp,lnx,lny,1);
                if isempty(a)
                    ln=-30:-2;
                    i=2*interval;
                    v=[-mean(diff(y(i-q:i+q))); mean(diff(x(i-q:i+q)))];
                    vu=v/sqrt(v(1)^2+v(2)^2);

                end
            end
        end
            
%         vup=vu*(-50:50);
        lnx=x(i)+vu(1)*ln;
        lny=y(i)+vu(2)*ln;
%         plot(lnx,lny)
        try
                [closestx,closesty,a,b] = intersections(xp,yp,lnx,lny,0);
        catch
                [closestx,closesty,a,b] = intersections(xp,yp,lnx,lny,1);
        end
        a=round(a);
        if length(a)==2
            if a(1)==a(2)
                a=a(1);
            elseif a(1)~=a(2)
                a=min(a);
            end
        elseif length(a)>2
            [closestx,closesty,a,b] = intersections(xp,yp,lnx,lny,1);
            a=round(a);
%             a=min(a);
        elseif isempty(a)
            ln=ln*1.5;
            lnx=x(i)+vu(1)*ln;
            lny=y(i)+vu(2)*ln;
            try
                [closestx,closesty,a,b] = intersections(xp,yp,lnx,lny,0);
            catch
                [closestx,closesty,a,b] = intersections(xp,yp,lnx,lny,1);
            end
            a=round(a);
        end

%         plot(lnx,lny)

        
        if length(a)~=1
            dist=[];
            for j=1:length(a)
                pt=a(j);
                d=ptDist(xp(pt),yp(pt),xp(as(end)),yp(as(end)));
                dist=[dist d];
            end
            minDist=find(dist==min(dist));
            a=a(minDist);
        end
        
        as=[as a];
        
        i=i+interval;
end
        %error check required
        %need to make sure the points are colinear and in order.  There
        %should be no sharp bends.
as=sort(as);
cX=xp(as);
cY=yp(as);
        
% angles=zeros(1,length(cX)-2);
% for i=2:length(cX)-1
%     va=[cX(i)-cX(i-1) cY(i)-cY(i-1)];
%     vb=[cX(i+1)-cX(i) cY(i+1)-cY(i)];
%     angle=acos(dot(va,vb)/norm(va)/norm(vb));
%     angle=angle/pi*180;
%     angles(i-1)=angle;
% end
% 
% sharpAngles=union(find(angles>90),find(isnan(angles)));  %remove all sharp angles
% for i=1:length(sharpAngles)
%     position=sharpAngles(i);
%     cX=[cX(1:position) cX(position+2:end)];
%     cY=[cY(1:position) cY(position+2:end)];
%     sharpAngles=sharpAngles-1;
% end

% cX=[cX x(end)]; %make the tail the last point
% cY=[cY y(end)];
% oX=[x(1) x(interval:interval:(seg-2)*interval) x(end)];
% oY=[y(1) y(interval:interval:(seg-2)*interval) y(end)];
oX=x(2*interval:interval:length(x)-1*interval);
oY=y(2*interval:interval:length(x)-1*interval);

mX=zeros(1,length(cX));
mY=zeros(1,length(cX));
for i=1:length(cX)
    [mX(i),mY(i)]=midpoint(cX(i),cY(i),oX(i),oY(i));
end

if keepTail
    mX=[hX mX tX];
    mY=[hY mY tY];
else
    mX=[hX mX];
    mY=[hY,mY];
end

% try
    mXi=interp(mX,n);   %interpolate to get a proper spline curve
    mYi=interp(mY,n);
    mXi=mXi(1:end-n+1);
    mYi=mYi(1:end-n+1);
    mX=mXi;
    mY=mYi;
% catch
%     disp('Failed centerline, returning simple head');
%     [mdx,mdy]=midpoint(x(end),y(end),xp(end),yp(end));
%     mX=[x(1) mdx];
%     mY=[y(1) mdy];
% end
% plot(mX,mY);
% f=figure;
% plot(x1,y1);
% hold on
% plot(x2,y2,'r');
% plot(mX,mY,'k');
% plot(hX,hY,'cx','MarkerSize',12)
% disp('Produced centerline successfully')
% delete(f)
% 
% 

function [xOut,yOut]=upsample(x,y,n)
l=length(x);
xOut=zeros(1,(l-1)*(n+1)+1);
yOut=zeros(1,(l-1)*(n+1)+1);
index=0:n;

for i=1:length(x)-1
    diff=x(i+1)-x(i);
    dx=diff/(n+1);
    out=x(i)+dx*index;
    xOut((i-1)*n+index+1*i)=out;
%     disp((i-1)*n+index+1*i);
    diff=y(i+1)-y(i);
    dy=diff/(n+1);
    out=y(i)+dy*index;
    yOut((i-1)*n+index+1*i)=out;

end
xOut(end)=x(end); yOut(end)=y(end); 