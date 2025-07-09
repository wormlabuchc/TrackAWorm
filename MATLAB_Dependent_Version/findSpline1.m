function [x,y]=findSpline1(xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,prevx,prevy)
% figure
% plot(xSeq,ySeq);
% hold on
% plot(xSeq2,ySeq2);
%the below code finds the concave corner associated with the head and tail
%point
[possCorners]=findConcaveCorners(xSeq,ySeq);
headDist=zeros(1,length(possCorners));
tailDist=zeros(1,length(possCorners));
for i=1:length(possCorners)
    headDist(i)=ptDist(xSeq(headPt),ySeq(headPt),xSeq(possCorners(i)),ySeq(possCorners(i)));
    tailDist(i)=ptDist(xSeq(tailPt),ySeq(tailPt),xSeq(possCorners(i)),ySeq(possCorners(i)));
end
headCorner=find(headDist==min(headDist));
headDist=headDist(headCorner);
headCorner=possCorners(headCorner);
tailCorner=find(tailDist==min(tailDist));
tailDist=tailDist(tailCorner);
tailCorner=possCorners(tailCorner);
len=length(xSeq);

%START HEAD DETECTION
if cwFrom(headPt,headCorner,len) 
    if headCorner<5
        d=5-headCorner;
        points=[len-d+1:len 1:headCorner]
    else
        points=headCorner-4:headCorner;
    end
elseif ~cwFrom(headPt,headCorner,len)
    if len-headCorner<5
        d=len-headCorner;
        points=[len-d:len 1:headCorner];
    else
        points=headCorner:headCorner+5;
    end
end

slope=[mean(diff(xSeq(points))) mean(diff(ySeq(points)))];


perpSlope=[slope(2) -slope(1)]; perpSlope=perpSlope/norm(perpSlope);
ln=1:40;
lnx=xSeq(headCorner)+perpSlope(1)*ln;
lny=ySeq(headCorner)+perpSlope(2)*ln;
[X0,Y0,I,J]=intersections(xSeq,ySeq,lnx,lny,0);
if isempty(I)
    %should have a curve or some other strategy to find the other side
    xsTemp=[xSeq(10:end) xSeq(1:9)];
    ysTemp=[ySeq(10:end) ySeq(1:9)];
    [X0,Y0,I,J]=intersections(xsTemp,ysTemp,lnx,lny,0);
    I=round(I);
    ind=intersect(find(xSeq==xsTemp(I)),find(ySeq==ysTemp(I)));
    I=ind;

end

if length(I)>1
    disp('Multiple intersections found')
    I=min(I);
end

I=round(I);

if headCorner>I && headCorner-I<len+I-headCorner
    %corner is clockwise from headPt
    x1=xSeq(I:headPt);
    y1=ySeq(I:headPt);
    x2=xSeq(headPt:headCorner);
    y2=ySeq(headPt:headCorner);
elseif headCorner<I && headCorner+len-I<I-headCorner
    %corner is clockwise from headPt
    xt=[xSeq(I:end) xSeq(1:headCorner)];
    yt=[ySeq(I:end) ySeq(1:headCorner)];
    newHead=intersect(find(xt==xSeq(headPt)),find(yt==ySeq(headPt)));
    x1=xt(1:newHead);
    y1=yt(1:newHead);
    x2=xt(newHead:end);
    y2=yt(newHead:end);
elseif headCorner<I && I-headCorner<headCorner+len-I
    %corner is counterclockwise from headPt
    x1=xSeq(headCorner:headPt);
    y1=ySeq(headCorner:headPt);
    x2=xSeq(headPt:I);
    y2=ySeq(headPt:I);
elseif headCorner>I && len-headCorner+I<headCorner-I
    %corner is counterclockwise from headPt
    xt=[xSeq(headCorner:end) xSeq(1:I)];
    yt=[ySeq(headCorner:end) ySeq(1:I)];
    newHead=intersect(find(xt==xSeq(headPt)),find(yt==ySeq(headPt)));
    x1=xt(1:newHead);
    y1=yt(1:newHead);
    x2=xt(newHead:end);
    y2=yt(newHead:end);
end
x1=fliplr(x1); y1=fliplr(y1);

    
if ptDist(x1(1),y1(1),x1(end),y1(end))<20 || ptDist(x2(1),y2(1),x2(end),y2(end))<20
    [mx,my]=midpoint(x1(end),y1(end),x2(end),y2(end));
    headx=[x1(1) mx];
    heady=[y1(1) my];
else
    [headx,heady]=buildSegment(x1,y1,x2,y2);
    
end

% plot(headx,heady)



%END HEAD DETECTION


%START TAIL DETECTION
if cwFrom(tailPt,headCorner,len) 
    if tailPt<5
        d=5-headCorner;
        points=[len-d+1:len 1:headCorner]
    else
        points=headCorner-4:headCorner;
    end
elseif ~cwFrom(tailPt,headCorner,len)
    if len-headCorner<5
        d=len-headCorner;
        points=[len-d:len 1:headCorner];
    else
        points=headCorner:headCorner+5;
    end
end

slope=[mean(diff(xSeq(points))) mean(diff(ySeq(points)))];


perpSlope=[slope(2) -slope(1)]; perpSlope=perpSlope/norm(perpSlope);
ln=1:40;
lnx=xSeq(headCorner)+perpSlope(1)*ln;
lny=ySeq(headCorner)+perpSlope(2)*ln;
[X0,Y0,I,J]=intersections(xSeq,ySeq,lnx,lny,0);

if isempty(I) || length(I)>1
    %should have a curve or some other strategy to find the other side
end
I=round(I);

if headCorner>I && headCorner-I<len+I-headCorner
    %corner is clockwise from tailPt
    x1=xSeq(I:tailPt);
    y1=ySeq(I:tailPt);
    x2=xSeq(tailPt:headCorner);
    y2=ySeq(tailPt:headCorner);
elseif headCorner<I && headCorner+len-I<I-headCorner
    %corner is clockwise from tailPt
    xt=[xSeq(I:end) xSeq(1:headCorner)];
    yt=[ySeq(I:end) ySeq(1:headCorner)];
    newTail=intersect(find(xt==xSeq(tailPt)),find(yt==ySeq(tailPt)));
    x1=xt(1:newTail);
    y1=yt(1:newTail);
    x2=xt(newTail:end);
    y2=yt(newTail:end);
elseif headCorner<I && I-headCorner<headCorner+len-I
    %corner is counterclockwise from tailPt
    x1=xSeq(headCorner:tailPt);
    y1=ySeq(headCorner:tailPt);
    x2=xSeq(tailPt:I);
    y2=ySeq(tailPt:I);
elseif headCorner>I && len-headCorner+I<headCorner-I
    %corner is counterclockwise from tailPt
    xt=[xSeq(headCorner:end) xSeq(1:I)];
    yt=[ySeq(headCorner:end) ySeq(1:I)];
    newTail=intersect(find(xt==xSeq(tailPt)),find(yt==ySeq(tailPt)));
    x1=xt(1:newTail);
    y1=yt(1:newTail);
    x2=xt(newTail:end);
    y2=yt(newTail:end);
end
x1=fliplr(x1); y1=fliplr(y1);

if ptDist(x1(1),y1(1),x1(end),y1(end))<20 || ptDist(x2(1),y2(1),x2(end),y2(end))<20
    [mx,my]=midpoint(x1(end),y1(end),x2(end),y2(end));
    tailx=[x1(1) mx];
    taily=[y1(1) my];
else
    [tailx,taily]=buildSegment(x1,y1,x2,y2);
    
end


% plot(tailx,taily)

[bodyx,bodyy]=buildBody(xSeq,ySeq,xSeq2,ySeq2);
[bodyx,bodyy]=removeJump(headx,heady,tailx,taily,bodyx,bodyy);
% plot(bodyx,bodyy)

[x,y]=stichTogether(headx,heady,bodyx,bodyy,tailx,taily,xSeq,ySeq,prevx,prevy);
% plot(x,y,'LineWidth',2)



function [mx,my]=buildSegment(x1,y1,x2,y2)
if length(x1)<length(x2)
    x=x1;
    y=y1;
    xp=x2;
    yp=y2;
else
    x=x2;
    y=y2;
    xp=x1;
    yp=y1;
end

px=[];
pxp=[];
mx=[];
my=[];
for i=10:3:length(x)-2
    slope=[mean(diff(x(i-2:i+2))) mean(diff(y(i-2:i+2)))];
    perpSlope=[-slope(2) slope(1)];
    perpSlope=perpSlope/norm(perpSlope);
    ln=-25:25;
    lnx=x(i)+ln*perpSlope(1);
    lny=y(i)+ln*perpSlope(2);
    [X0,Y0,I,J]=intersections(xp,yp,lnx,lny);
    I=round(I);
    I=min(I);
    
    [mxNew,myNew]=midpoint(x(i),y(i),xp(I),yp(I));
    mx=[mx mxNew];
    my=[my myNew];
end
[endx,endy]=midpoint(x1(end),y1(end),x2(end),y2(end));

mx=[x1(1) mx endx];
my=[y1(1) my endy];

function done=checkIfDone(x1,y1,x2,y2,previousPoint,edges,L)
if isempty(edges)
    done=0;
    return
end

if isempty(previousPoint)
    done=1;
    return
end


if abs(length(x1)-length(x2))/min([length(x1) length(x2)]) < 3
    
    lastPoint1=[x1(end) y1(end)];
    lastPoint2=[x2(end) y2(end)];
    
    dist1=ptDist(lastPoint1(1),lastPoint1(2),previousPoint(1),previousPoint(2));
    dist2=ptDist(lastPoint2(1),lastPoint2(2),previousPoint(1),previousPoint(2));
    
    if dist1<L*.8 || dist2<L*.8
        done=1;
    else
        done=0;
    end
else
    done=1;
end

function [bodyx,bodyy]=buildBody(xSeq,ySeq,xSeq2,ySeq2);

LL=length(xSeq2);
interval=round(LL/20);
positions=interval:interval:LL;
midx=[];
midy=[];
j=1;
pos=positions(j);
done=0;
while ~done
    dx=mean(diff(xSeq2(pos-ceil(interval/2):pos+floor(interval/2))));
    dy=mean(diff(ySeq2(pos-ceil(interval/2):pos+floor(interval/2))));
    slope=[dx dy]; slope=slope/norm(slope);
    perpSlope=[-slope(2) slope(1)];
    ln=5:40;
    lnx=xSeq2(pos)+perpSlope(1)*ln;
    lny=ySeq2(pos)+perpSlope(2)*ln;
    [X0,Y0,I,J] = intersections(xSeq,ySeq,lnx,lny,0);
    I=round(I);
    if length(I)>1
%         plot(lnx,lny)
%         plot(xSeq(I),ySeq(I),'rx')
        I=min(I);
    end
    [mx,my]=midpoint(xSeq2(pos),ySeq2(pos),xSeq(I),ySeq(I));
    midx=[midx mx];
    midy=[midy my];
    j=j+1;
    if j<=length(positions)
        pos=positions(j);
        if pos+floor(interval/2)>LL
            done=1;
        end
    else
        done=1;
    end
    
end
pointDistances=zeros(1,length(midx));

for i=2:length(midx)
    pointDistances(i)=ptDist(midx(i-1),midy(i-1),midx(i),midy(i));
end
pointDistances(1)=ptDist(midx(end),midy(end),midx(1),midy(1));

% jump=find(pointDistances==max(pointDistances));
% midx=[midx(jump:end) midx(1:jump-1)];
% midy=[midy(jump:end) midy(1:jump-1)];
bodyx=midx;
bodyy=midy;

function [x,y]=stichTogether(headx,heady,bodyx,bodyy,tailx,taily,xSeq,ySeq,prevx,prevy);
if ~isempty(prevx)
    crossPrev=crosses(prevx,prevy);


    spline1x=[headx bodyx fliplr(tailx)];
    spline1y=[heady bodyy fliplr(taily)];
    cross1=crosses(spline1x,spline1y);

    spline2x=[headx fliplr(bodyx) fliplr(tailx)];
    spline2y=[heady fliplr(bodyy) fliplr(taily)];
    cross2=crosses(spline2x,spline2y);
    
    
    if crossPrev
        if cross1 && ~cross2
            x=spline1x;
            y=spline1y;
        elseif cross2 && ~cross1
            x=spline2x;
            y=spline2y;
        end
    elseif ~crossPrev
        if ~cross1 && cross2
            x=spline1x;
            y=spline1y;
        elseif ~cross2 && cross1
            x=spline2x;
            y=spline2y;
        end
    end
elseif isempty(prevx)
%     a=[headx(end)-headx(end-1) heady(end)-heady(end-1)];
%     b=[tailx(end)-tailx(end-1) taily(end)-taily(end-1)];
%     c=[bodyx(2)-bodyx(1) bodyy(2)-bodyy(1)];
%     d=[bodyx(end-1)-bodyx(end) bodyy(end-1)-bodyy(end)];
    
    headPt=intersect(find(xSeq==headx(1)),find(ySeq==heady(1)));
    tailPt=intersect(find(xSeq==tailx(1)),find(ySeq==taily(1)));
    
    bodyx=bodyx(2:end-1);
    bodyy=bodyy(2:end-1);
    
    headx=headx(1:end-1);
    heady=heady(1:end-1);
    tailx=tailx(1:end-1);
    taily=taily(1:end-1);
    
    slope1=[bodyx(2)-bodyx(1) bodyy(2)-bodyy(1)];
    slope1=slope1/norm(slope1);
    perp2=[-slope1(2) slope1(1)];
    ln=0:25;
    lnx=bodyx(1)+perp2(1)*ln;
    lny=bodyy(1)+perp2(2)*ln;
    [X0,Y0,I,J] = intersections(xSeq,ySeq,lnx,lny,0);
    bound1=round(min(I));
    
    slope2=[bodyx(end)-bodyx(end-1) bodyy(end)-bodyy(end-1)];
    slope2=slope2/norm(slope2);
    perp2=[-slope2(2) slope2(1)];
    ln=0:25;
    lnx=bodyx(end)+perp2(1)*ln;
    lny=bodyy(end)+perp2(2)*ln;
    [X0,Y0,I,J] = intersections(xSeq,ySeq,lnx,lny,0);
    bound2=round(min(I));

    %find the closest point, either head or tail, that is CCW from bound1
    diff1=acuteDiff(xSeq,ySeq,bound1,headPt);
    diff2=acuteDiff(xSeq,ySeq,bound1,tailPt);
    diff3=acuteDiff(xSeq,ySeq,bound2,headPt);
    diff4=acuteDiff(xSeq,ySeq,bound2,tailPt);
        
    
    if diff1<diff2 && diff4<diff3 %head is closest to bound1, tail closest to bound2
        cx1=xSeq(headPt:bound1);
        cy1=ySeq(headPt:bound1);
        cx2=xSeq(bound2:tailPt);
        cy2=ySeq(bound2:tailPt);
        if isempty(cx1)
            cx1=[xSeq(headPt:end) xSeq(1:bound1)];
            cy1=[ySeq(headPt:end) ySeq(1:bound1)];
        end
        if isempty(cx2)
            cx2=[xSeq(bound2:end) xSeq(1:tailPt)];
            cy2=[ySeq(bound2:end) ySeq(1:tailPt)];
        end
    elseif diff2<diff1 && diff3<diff4 %head is closest to bound2, tail closest to bound1
        cx1=xSeq(bound2:headPt);
        cy1=ySeq(bound2:headPt);
        cx2=xSeq(tailPt:bound1);
        cy2=ySeq(tailPt:bound1);
        if isempty(cx1)
            cx1=[xSeq(bound2:end) xSeq(1:headPt)];
            cy1=[ySeq(bound2:end) ySeq(1:headPt)];
        end
        if isempty(cx2)
            cx2=[xSeq(tailPt:end) xSeq(1:bound1)];
            cy2=[ySeq(tailPt:end) ySeq(1:bound1)];
        end
                
    else
        disp('error in segment lengths')
    end
    
    slop1=[headx(end)-headx(end-1) heady(end)-heady(end-1)];
    slop1=slop1/norm(slop1);
    ln=-25:25;
    perpSlop1=[-slop1(2) slop1(1)];
    lnx=headx(end)+ln*perpSlop1(1);
    lny=heady(end)+ln*perpSlop1(2);
    [X0,Y0,I1,J] = intersections(cx1,cy1,lnx,lny,0);
    I1=round(min(I1));
    
    slop2=[tailx(end)-tailx(end-1) taily(end)-taily(end-1)];
    slop2=slop2/norm(slop2);
    ln=-25:25;
    perpSlop2=[-slop2(2) slop2(1)];
    lnx=tailx(end)+ln*perpSlop2(1);
    lny=taily(end)+ln*perpSlop2(2);
    [X0,Y0,I2,J] = intersections(cx2,cy2,lnx,lny,0);
    I2=round(min(I2));
    
    if diff1<diff2 && diff4<diff3
        cx1=cx1(I1:end);
        cy1=cy1(I1:end);
        
        cx2=cx2(1:I2);
        cy2=cy2(1:I2);
    elseif diff2<diff1 && diff3<diff4
        cx1=cx1(1:I1);
        cy1=cy1(1:I1);
        
        cx2=cx2(I2:end);
        cy2=cy2(I2:end);
    end

    curv1=lineCurvature(cx1',cy1');
    curv2=lineCurvature(cx2',cy2');
    if curv1>20 && curv2>20
        cross=0;
    else
        cross=1;
    end
    
    tempx=[headx bodyx fliplr(tailx)];
    tempy=[heady bodyy fliplr(taily)];
    
    if cross && crosses(tempx,tempy)
        x=tempx;
        y=tempy;
    else
        x=[headx fliplr(bodyx) fliplr(tailx)];
        y=[heady fliplr(bodyy) fliplr(taily)];
    end
        
    
    
end



function diff=acuteDiff(xSeq,ySeq,a,b);
l=length(xSeq);
d=a-b;
if a<b && a+l-b<b-a
    diff=a+l-b;
elseif a>b && a-b<b+l-a
    diff=a-b;
elseif a>b && b+l-a<a-b
    diff=b+l-a;
elseif b>a && b-a
    diff=b-a;
end

function [bodyx,bodyy]=removeJump(headx,heady,tailx,taily,bodyx,bodyy);
hx=headx(end);
hy=heady(end);

tx=tailx(end);
ty=taily(end);

disth=zeros(1,length(bodyx));
distt=disth;
for i=1:length(bodyx)
    dh=ptDist(hx,hy,bodyx(i),bodyy(i));
    disth(i)=dh;
    dt=ptDist(tx,ty,bodyx(i),bodyy(i));
    distt(i)=dt;
end

minh=find(disth==min(disth));
mint=find(distt==min(distt));

if mint==minh
    if disth(minh)<distt(mint)
        jump=minh;
        if jump~=1 && jump~=length(distt)
            distt=[distt(1:jump-1) 1e6 distt(jump+1:end)];
        elseif jump==1
            distt=[1e6 distt(2:end)];
        elseif jump==length(distt)
            distt=[distt(1:end-1) 1e6];
        end
        mint=find(distt==min(distt));
        
    else
        jump=mint;
        if jump~=1 && jump~=length(disth)
            disth=[disth(1:jump-1) 1e6 disth(jump+1:end)];
        elseif jump==1
            disth=[1e6 disth(2:end)];
        elseif jump==length(disth)
            disth=[disth(1:end-1) 1e6];
        end
        minh=find(disth==min(disth));
        
        
    end
end

hx=[headx(end) bodyx(minh)];
hy=[heady(end) bodyy(minh)];

tx=[tailx(end) bodyx(mint)];
ty=[taily(end) bodyy(mint)];

if crosses(hx,hy,tx,ty)
    mins=[minh mint];
    minh=mins(2);
    mint=mins(1);
end

if minh<mint && mint-minh<minh+length(bodyx)-mint
    bodyx=[bodyx(mint:end) bodyx(1:minh)];
    bodyy=[bodyy(mint:end) bodyy(1:minh)];
elseif minh<mint && minh+length(bodyx)-mint<mint-minh
    bodyx=bodyx(minh:mint);
    bodyy=bodyy(minh:mint);
elseif mint<minh && minh-mint<mint+length(bodyx)-minh
    bodyx=[bodyx(minh:end) bodyx(1:mint)];
    bodyy=[bodyy(minh:end) bodyy(1:mint)];
elseif mint<minh && mint+length(bodyx)-minh<minh-mint
    bodyx=bodyx(mint:minh);
    bodyy=bodyy(mint:minh);
end

if ptDist(headx(end),heady(end),bodyx(1),bodyy(1))<25 || ptDist(headx(end),heady(end),bodyx(end),bodyy(end))<25 || ptDist(tailx(end),taily(end),bodyx(1),bodyy(1))<25 || ptDist(tailx(end),taily(end),bodyx(end),bodyy(end))<25
    bodyx=bodyx(2:end-1);
    bodyy=bodyy(2:end-1);
end