function [xCenterLine,yCenterLine]=findSpline3(xSeq,ySeq,xSeq2,ySeq2,prevX,prevY,imgOrig)


headx=prevX(1);
heady=prevY(1);

imgthin=bwmorph(imgOrig,'thin',Inf);
bp=bwmorph(imgOrig,'branchpoints');
imgpruned=bwmorph(imgthin,'spur',Inf);

[x,y]=edgesToCoordinates(imgpruned);
[xSeq,ySeq]=removeArtifacts(x,y);

cw=isClockwise(prevX,prevY);

d=zeros(1,length(xSeq));
for i=1:length(xSeq)
    d(i)=ptDist(xSeq(i),ySeq(i),headx,heady);
end

newHead=find(d==min(d));


xSeq=[xSeq(newHead:end) xSeq(1:newHead-1)];
ySeq=[ySeq(newHead:end) ySeq(1:newHead-1)];

cwNew=isClockwise(xSeq,ySeq);

if cw~=cwNew
    xSeq=fliplr(xSeq);
    ySeq=fliplr(ySeq);
end

xCenterLine=xSeq;
yCenterLine=ySeq;