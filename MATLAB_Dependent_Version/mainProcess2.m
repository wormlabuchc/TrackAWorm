%main image processing function!
function [xCenterLine,yCenterLine]=mainProcess2(filename,swap,clow,chigh,threshold)

persistent headPt tailPt xSeq ySeq h
%keep these variables around, in case we need to grab them later for
%swapping head and tail

img=imread(filename);
img=img(1:end,1:end,1);

[imgFilled,img,imgSub,isOmega]=prepImage(filename,clow,chigh,threshold);


img=edge(img,'sobel');
imgFilled=edge(imgFilled,'sobel');
imgSub=edge(imgSub,'sobel');
if isOmega
    disp('Possible omega bend detected, changing algorithm');
    [x,y]=edgesToCoordinates(imgFilled);
    [xSeq,ySeq]=removeArtifacts(x,y);
    [xSeq,ySeq]=smoothxy(xSeq,ySeq);
    fewpoints=floor(length(xSeq)/3);
    if ~isClockwise(xSeq(1:fewpoints:end),ySeq(1:fewpoints:end));
        xSeq=fliplr(xSeq);
        ySeq=fliplr(ySeq);
    end
    
    
    
    [x2,y2]=edgesToCoordinates(imgSub);
    [xSeq2,ySeq2]=removeArtifacts(x2,y2);
    [xSeq2,ySeq2]=smoothxy(xSeq2,ySeq2);
    
    %this code will trace the inner circle and draw perpendicular lines to
    %the opposite side
    if ~isClockwise(xSeq2,ySeq2);
        xSeq2=fliplr(xSeq2);
        ySeq2=fliplr(ySeq2);
    end
    xSeq2=[xSeq2(end-9:end) xSeq2 xSeq2(1:10)];
    ySeq2=[ySeq2(end-9:end) ySeq2 ySeq2(1:10)];
    
    
    holeCenterline=zeros(1,length(xSeq2)-1);
    
    xMidpoint=zeros(1,length(xSeq2)-20);
    yMidpoint=zeros(1,length(ySeq2)-20);
    vectorLength=zeros(1,length(xMidpoint));
    
    for i=11:length(xSeq2)-10
        startPtX=xSeq2(i);startPtY=ySeq(2);
        [startPt, perpVector]=perpendicularAvg(xSeq2(i-10:i+10),ySeq2(i-10:i+10));
        [closestx,closesty,pointNum]=minimizeDistance(perpVector,xSeq,ySeq,xSeq2(i),ySeq2(i));
%         closestx=closestx(1);
%         closesty=closesty(1);   %this may cause errors, but I'm not quite sure how to deal with it yet.
%         cX=[cX closestx];
%         cY=[cY closesty];
        xMidpoint(i-10)=(closestx+xSeq2(i))/2;
        yMidpoint(i-10)=(closesty+ySeq2(i))/2;
        vectorLength(i-10)=norm([closestx-xSeq2(i) closesty-ySeq2(i)]);
%         disp(i)
        
    end
    %remove outliers in vector length
    
    mvl=mean(vectorLength);
    stdvl=std(vectorLength);
    lowBound=mvl-stdvl; highBound=mvl+stdvl;
    outliers=[find(vectorLength<lowBound) find(vectorLength>highBound)];
    
    keep=1:length(xMidpoint);
    keep=setdiff(keep,outliers);
    xMidpoint=xMidpoint(keep);
    yMidpoint=yMidpoint(keep);
    
    %the code below makes the sequence start from the "jump" point where
    %the body creates a gap in the midpoint
    pointDistances=zeros(1,length(xMidpoint));

    for i=2:length(xMidpoint)
        pointDistances(i)=ptDist(xMidpoint(i-1),yMidpoint(i-1),xMidpoint(i),yMidpoint(i));
    end
    pointDistances(1)=ptDist(xMidpoint(end),yMidpoint(end),xMidpoint(1),yMidpoint(1));
    
    jump=find(pointDistances==max(pointDistances));
    xMidpoint=[xMidpoint(jump:end) xMidpoint(1:jump-1)];
    yMidpoint=[yMidpoint(jump:end) yMidpoint(1:jump-1)];
    
    thinFactor=round(length(xMidpoint)/20);
    xMidpoint=xMidpoint(1:thinFactor:end);
    yMidpoint=yMidpoint(1:thinFactor:end);
    
    xMidpointInterp=interp(xMidpoint,8);   %interpolate to get a proper spline curve
    yMidpointInterp=interp(yMidpoint,8);
    xMidpointInterp=xMidpointInterp(1:end-7);
    yMidpointInterp=yMidpointInterp(1:end-7);
    [x,y]=divideSpline(xMidpointInterp,yMidpointInterp,8);
    
    
    %done making the midpoint
   
    [xC,yC,headPt,tailPt]=findCorners2(xSeq,ySeq);
    
    [xHead, yHead]=findProtrudingSegment(xSeq,ySeq,headPt);
    
    thetaA=[0 0];
    thetaB=[0 0];

    %headPt to midline(1)
    a=[x(1)-xHead(end) y(1)-yHead(end)];
    b=[x(1)-x(2) y(1)-y(2)];
    thetaA(1)=(pi-acos(dot(a,b)/norm(a)/norm(b)))/pi*180;

    %headPt to midline(end)
    a=[x(end)-xHead(end) y(end)-yHead(end)];
    b=[x(end)-x(end-1) y(end)-y(end-1)];
    thetaB(1)=(pi-acos(dot(a,b)/norm(a)/norm(b)))/pi*180;

    if ~isempty(tailPt)  %if there is an identifiable tail point, draw similar lines
% 
%          %draw 4 lines.  1.) from headNeck to midline(1); 2.) from headNeck to
%          %midline(end); 3.) from tailNeck to midline(end); 4.) from tailNeck to
%          %midline(1).  Then find the combination that creates the smallest
%          %angles to the midline.
        [xTail, yTail]=findProtrudingSegment(xSeq,ySeq,tailPt);

        %tailPt to midline(end)
        a=[x(end)-xTail(end) y(end)-yTail(end)];
        b=[x(end)-x(end-1) y(end)-y(end-1)];
        thetaA(2)=(pi-acos(dot(a,b)/norm(a)/norm(b)))/pi*180;

        %tailPt to midline(1)
        a=[x(1)-xTail(end) y(1)-yTail(end)];
        b=[x(1)-x(2) y(1)-y(2)];
        thetaB(2)=(pi-acos(dot(a,b)/norm(a)/norm(b)))/pi*180;

        %figure out which direction the spline should take

        if sum(thetaA)>sum(thetaB)
            x=fliplr(x);
            y=fliplr(y);
        end

    elseif isempty(tailPt)
    end


    
    figure(1); plot(xSeq,ySeq); hold on; plot(xSeq2,ySeq2); plot(x,y,'-.r');
    plot(xHead,yHead)
    try
        plot(xTail,yTail)
    catch
        xTail=[];
        yTail=[];
    end
%     xCenterLine=[0 0 0 0 0 0 0 0 0 0 0 0 0];
%     yCenterLine=[0 0 0 0 0 0 0 0 0 0 0 0 0];
    xCenterLine=[xHead xSeq2 xTail];
    yCenterLine=[yHead ySeq2 yTail];
end


if ~isOmega
    [x,y]=edgesToCoordinates(imgFilled);
    if ~swap
        [xSeq,ySeq]=removeArtifacts(x,y);
        [xSeq,ySeq]=smoothxy(xSeq,ySeq);
        fewpoints=floor(length(xSeq)/3);
        if ~isClockwise(xSeq,ySeq);
            xSeq=fliplr(xSeq);
            ySeq=fliplr(ySeq);
        end
        h=length(imgFilled(:,1));



        [xC,yC,headPt,tailPt]=findCorners2(xSeq,ySeq);
            
    elseif swap
        %swap the head and tail points
        headPtOrig=headPt;
        headPt=tailPt;
        tailPt=headPtOrig;
        clear headPtOrig
    end

    [x1,y1,x2,y2]=splitLines(xSeq,ySeq,headPt,tailPt);

    [xCenterLine,yCenterLine,cX,cY,oX,oY]=makeCenterLine(x1,y1,x2,y2);
    [xCenterLine,yCenterLine]=divideSpline(xCenterLine,yCenterLine,12);

    %CURVATURE CHECK
    %if the curvature is too large at any point, the program will crash itself
    curvatureCheck(xCenterLine,yCenterLine);
end