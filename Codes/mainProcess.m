%main image processing function!
function [xCenterLine,yCenterLine]=mainProcess(filename,swap,clow,chigh,threshold,winOrig,winContrast)

persistent headPt tailPt xSeq ySeq h
%keep these variables around, in case we need to grab them later for
%swapping head and tail

if ~swap
    img=imread(filename);
    img=img(1:end,1:end,1);
%     axes(winOrig);
%     imshow(img)
    
    img=prepImage(filename,clow,chigh,threshold);
    
    axes(winContrast);
    imshow(img)
    hold on
    
    img=edge(img,'sobel');
    [x,y]=edgesToCoordinates(img);
    [xSeq,ySeq]=removeArtifacts(x,y);
    [xSeq,ySeq]=smoothxy(xSeq,ySeq);
    h=length(img(:,1));

    %sweep across values of bMin to find the head; note that because the head
    %is typically harder to find, it's useful to keep several candidate points.
    headAndTailFound=0;
    findHeadCandidates=2;
    oldxc=[];
    oldyc=[];
    % tic
    while ~headAndTailFound
        done=0;   %okay maybe there's a less dumb way to do this
        bMin=.5; %start at a value of .5.  This may change.

        while ~done
            [xC,yC,xP,yP]=findCorners(xSeq,ySeq,h,bMin);
            if length(xC)==1
                done=1;
            else
                bMin=bMin+.125;   %I'll need to find some optimal value here.  
                                %This is computationally cheap so maybe I should just go really low
                if bMin>15;
                    disp('crashes at tail')
                    jalirewghhwaif %crash
                end
            end
        end

        done=0;
        bMin=5;
        while ~done
            [xC2,yC2,xP,yP]=findCorners(xSeq,ySeq,h,bMin);
            if length(xC2)==findHeadCandidates
                done=1;
            else
                bMin=bMin+.0625;   %I'll need to find some optimal value here.  
                                %This is computationally cheap so maybe I should just go really low
                if bMin>15;
                    disp('crashes at head')
                    jalirewghhwaif %crash
                end
            end
        end

        tailPt=intersect(find(xSeq==xC),find(ySeq==yC));
        xC2=setdiff(xC2,xC);
        yC2=setdiff(yC2,yC);
        xC2=setdiff(xC2,oldxc);
        yC2=setdiff(yC2,oldyc);
        headPt=intersect(find(xSeq==xC2),find(ySeq==yC2));
        
        %Start splitting into two lines
        %The following code splits the worm into two lines assuming the length of
        %both sides is approximately equal

        l1=abs(headPt-tailPt);
        l2=length(xSeq)-l1;
        if max([l1 l2])<=min([l1 l2])*2   %this threshold may need to be changed.  Hopefully not.
            headAndTailFound=1;
        else
            findHeadCandidates=findHeadCandidates+1;
            oldxc=[oldxc xC2];  %build up an array of previously used "false" points
            oldyc=[oldyc yC2];
        end

    end
elseif swap
    %swap the head and tail points
    headPtOrig=headPt;
    headPt=tailPt;
    tailPt=headPtOrig;
    clear headPtOrig
    
    img=imread(filename);
    img=img(1:end,1:end,1);
%     axes(winOrig)
%     imshow(img)
    axes(winContrast)
    img=prepImage(filename,clow,chigh,threshold);
    imshow(img)
    hold on
end

plot(xSeq(headPt),h-ySeq(headPt)+1,'xc','MarkerSize',12,'LineWidth',2)
[x1,y1,x2,y2]=splitLines(xSeq,ySeq,headPt,tailPt);
plot(x2,h-y2+1,'g')
plot(x1,h-y1+1,'r')

[xCenterLine,yCenterLine,cX,cY,oX,oY]=makeCenterLine(x1,y1,x2,y2);
[xCenterLine,yCenterLine]=divideSpline(xCenterLine,yCenterLine,12);
plot(xCenterLine,h-yCenterLine+1,'.c','MarkerSize',6)
% plot(xCenterLine,yCenterLine,'.c','MarkerSize',6)
hold off
curvatureCheck(xCenterLine,yCenterLine);
