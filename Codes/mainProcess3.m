%main image processing function!
function [xCenterLine,yCenterLine,xcross,ycross]=mainProcess3(filename,swap,clow,chigh,threshold,prevX,prevY)

% if swap
%     xCenterLine=prevX;
%     yCenterLine=prevY;
%     return
% end

if nargin==5
    prevX=[];
    prevY=[];
end

xcross=[];
ycross=[];

persistent headPt tailPt xSeq ySeq h
%keep these variables around, in case we need to grab them later for
%swapping head and tail

% imgOrig=imread(filename);
% imgOrig=imgOrig(1:end,1:end,1);

[imgFilled,imgOrig,imgSub,isOmega] = prepImage(filename,clow,chigh,threshold);

img=edge(imgOrig,'sobel');
imgFilled=edge(imgFilled,'sobel');
imgSub=edge(imgSub,'sobel');


if isOmega
    
    disp('Possible omega bend detected, changing algorithm');
    [x,y]=edgesToCoordinates(imgFilled);
    [xSeq,ySeq]=removeArtifacts(x,y);
    [xSeq,ySeq]=smoothxy(xSeq,ySeq);
    if ~isClockwise(xSeq(1:end),ySeq(1:end));
        xSeq=fliplr(xSeq);
        ySeq=fliplr(ySeq);
    end
    
    [x2,y2]=edgesToCoordinates(imgSub);
    [xSeq2,ySeq2]=removeArtifacts(x2,y2);
    [xSeq2,ySeq2]=smoothxy(xSeq2,ySeq2);
    
    if ~isClockwise(xSeq2,ySeq2)
        xSeq2=fliplr(xSeq2);
        ySeq2=fliplr(ySeq2);
    end
    
    [xC,yC,headPt,tailPt]=findCorners2(xSeq,ySeq);
    disp(headPt)
    disp(tailPt)
    if isempty(headPt) && isempty(tailPt)
        omegaAnalysis=3; %no head or tail could be found
    elseif isempty(tailPt) && ~isempty(headPt)
        omegaAnalysis=2; %only the head is visible
    elseif ~isempty(headPt) && ~isempty(tailPt)
        omegaAnalysis=1; %both head and tail are available
    end
    
    switch omegaAnalysis
        case 1
            try
                disp('Type 1 omega bend')
                [xCenterLine,yCenterLine,xcross,ycross]=findSpline1_new(imgOrig,xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,prevX,prevY);
            catch
                disp('Error - trying type 2 bend algorithm')
                try
                    headDist=ptDist(xSeq(headPt),ySeq(headPt),prevX(1),prevY(1));
                    tailDist=ptDist(xSeq(tailPt),ySeq(tailPt),prevX(1),prevY(1));
                    if headDist>tailDist
                        disp('Head misallocated for omega detection - swapping.')
                        [xCenterLine,yCenterLine,xcross,ycross]=findSpline2_new(imgOrig,xSeq,ySeq,xSeq2,ySeq2,tailPt,headPt,10,prevX,prevY);
%                         [xCenterLine,yCenterLine,xcross,ycross]=findSpline2_new(imgOrig,xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,10,prevX,prevY);
                    else
%                         [xCenterLine,yCenterLine]=findSpline2(xSeq,ySeq,xSeq2,ySeq2,headPt,10,prevX,prevY);
                        [xCenterLine,yCenterLine,xcross,ycross]=findSpline2_new(imgOrig,xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,10,prevX,prevY);

                    end
                    
                catch
                    disp('Error - trying type 3 bend algorithm')
                    [xCenterLine,yCenterLine]=findSpline3(xSeq,ySeq,xSeq2,ySeq2,prevX,prevY,imgOrig);
                end
            end
        case 2
            
            [xCenterLine,yCenterLine,xcross,ycross]=findSpline2_new(imgOrig,xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,10,prevX,prevY);
            disp('Type 2 omega bend')
        case 3
            disp('Type 3 omega bend - no algorithm')
            points = detectHarrisFeatures(imgSub);
            corners=selectStrongest(points,2);
            headPt = [corners.Location(1),corners.Location(3)];
            tailPt = [corners.Location(2),corners.Location(4)];
            [xCenterLine,yCenterLine,xcross,ycross]=findSpline2_new(imgOrig,xSeq,ySeq,xSeq2,ySeq2,headPt,tailPt,10,prevX,prevY);
            %[xCenterLine,yCenterLine]=findSpline3(xSeq,ySeq,xSeq2,ySeq2,prevX,prevY,imgOrig);

    end
        
    
    [xCenterLine,yCenterLine]=divideSpline(xCenterLine,yCenterLine,12);
    
    if ~isempty(xcross) && ~isempty(ycross) %if an omega bend was produced with a crossed over alternative spline, divide it
        [xcross,ycross]=divideSpline(xcross,ycross,12);
    end
    
    curvatureCheck(xCenterLine,yCenterLine);
    
%     if swap
%         xCenterLine=fliplr(xCenterLine);
%         yCenterLine=fliplr(yCenterLine);
%         xcross=fliplr(xcross);
%         ycross=fliplr(ycross);
%     end
end


if ~isOmega
    [x,y]=edgesToCoordinates(imgFilled);
    if ~swap
        
    

        [xSeq,ySeq]=removeArtifacts(x,y);
        [xSeq,ySeq]=smoothxy(xSeq,ySeq);
        if ~isClockwise(xSeq,ySeq);
            xSeq=fliplr(xSeq);
            ySeq=fliplr(ySeq);
        end

        [xC,yC,headPt,tailPt]=findCorners2(xSeq,ySeq);
            
    elseif swap
        headPtOrig=headPt;
        headPt=tailPt;
        tailPt=headPtOrig;
        clear headPtOrigs
    end

%     [x1,y1,x2,y2]=splitLines(xSeq,ySeq,headPt,tailPt);

%     [xCenterLine,yCenterLine,cX,cY,oX,oY]=makeCenterLine(x1,y1,x2,y2);
    head=[xSeq(headPt) ySeq(headPt)];
    tail=[xSeq(tailPt) ySeq(tailPt)];
    [xCenterLine,yCenterLine]=makeCenterLine2(imgOrig,head,tail);

%     [xCenterLine,yCenterLine]=removeJumps(xCenterLine,yCenterLine);
    [xCenterLine,yCenterLine]=divideSpline(xCenterLine,yCenterLine,12);

    curvatureCheck(xCenterLine,yCenterLine);
end

if isempty(xcross) && isempty(ycross)
    xcross=[0 0 0 0 0 0 0 0 0 0 0 0 0];
    ycross=[0 0 0 0 0 0 0 0 0 0 0 0 0];
end

function [xcl,ycl]=makeCenterLine2(imgOrig,head,tail)
imgthin=bwmorph(imgOrig,'thin',Inf);
branches=bwmorph(imgthin,'branchpoints');
endpoints = bwmorph(imgthin,'endpoints');
branchesLoc = find(branches);
res = size(imgthin);

[yEnd,xEnd] = find(endpoints);
branchesLoc = find(branches);

headXEnd = closestPoints(head(1),res(1)-head(2),xEnd,yEnd);
tailXEnd = closestPoints(tail(1),res(1)-tail(2),xEnd,yEnd);

[xEnd,yEnd] = removeInd(xEnd,yEnd,find(xEnd==headXEnd));
[xEnd,yEnd] = removeInd(xEnd,yEnd,find(xEnd==tailXEnd));

spursImg = zeros(size(imgthin));

for i=1:length(xEnd)
    distMap = bwdistgeodesic(imgthin,xEnd(i),yEnd(i));
    nearestBranchDist = min(distMap(branchesLoc));
    spursImg(distMap<nearestBranchDist) = 1;
end

imgthin = imgthin - spursImg;

% while sum(sum(branches))~=0
%     imgthin=bwmorph(imgthin,'spur',10);
%     branches=bwmorph(imgthin,'branchpoints');
% end
% imgthin=bwmorph(imgthin,'spur',10); %sometimes odd lines are drawn by the thin command due to spurs.
xcl=[];
ycl=[];
[x,y]=edgesToCoordinates(imgthin);
[ind,dist]=findClosestPoint(head(1),head(2),x,y);
xcl=[xcl x(ind)];
ycl=[ycl y(ind)];
[x,y]=removeInd(x,y,ind);
while ~isempty(x)
    [ind,dist]=findClosestPoint(xcl(end),ycl(end),x,y);
%     if dist<5
        xcl=[xcl x(ind)];
        ycl=[ycl y(ind)];
%     end
    [x,y]=removeInd(x,y,ind);
end

dx=abs(xcl(1)-head(1));
dy=abs(xcl(1)-head(2));
if dx>5 || dy>5
    hx=linInterp(head(1),xcl(1),10);
    hy=linInterp(head(2),ycl(1),10);
else
    hx=head(1);
    hy=head(2);
end

dx=abs(xcl(end)-tail(1));
dy=abs(xcl(end)-tail(2));
if dx>5 || dy>5
    tx=linInterp(xcl(end),tail(1),10);
    ty=linInterp(ycl(end),tail(2),10);
else
    tx=tail(1);
    ty=tail(2);
end

xcl=[hx xcl tx];
ycl=[hy ycl ty];

function [x,y]=removeInd(x,y,ind)
if ind==1
    x=x(2:end); y=y(2:end);
elseif ind==length(x)
    x=x(1:end-1); y=y(1:end-1);
else
    x=[x(1:ind-1) x(ind+1:end)];
    y=[y(1:ind-1) y(ind+1:end)];
end
