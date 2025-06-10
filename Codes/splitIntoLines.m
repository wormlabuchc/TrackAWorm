function [xCurve1,yCurve1,xCurve2,yCurve2]=splitIntoLines(img)

xEndpoints=[];
yEndpoints=[];

% imgEq=histeq(img);
edges=edge(img,'sobel');
[x,y]=edgesToCoordinates(edges);

% xEdgeCandidates=[];
% yEdgeCandidates=[];
% 
% %is x changing?  is y changing?
% for i=1:length(x)-1
%     if abs(x(i+1)-x(i))<2 && abs(y(i+1)-y(i))<2
%         disp('edge?')
%         xEdgeCandidates=[xEdgeCandidates x(i)];
%         yEdgeCandidates=[yEdgeCandidates y(i)];
%     end
% end

[m,n]=size(edges);

cout=corner(edges,2.25);
corner1=[cout(1,2) m-cout(1,1)+1];
corner2=[cout(2,2) m-cout(2,1)+1];

xPrev=corner1(1); yPrev=corner1(2);
xCurve1=[];
yCurve1=[];
xCurve2=[];
yCurve2=[];

[xChk,yChk,xtemp,ytemp]=closestPoints(corner2(1),corner2(2),x,y);

for i=1:length(x)
    while xChk~=xPrev && yChk~=yPrev
        
    %check if the current point is actually very close to the
    %other corner.  If it is, terminate the loop    
    
    [xClosest,yClosest,x,y]=closestPoints(xPrev,yPrev,x,y);
    
    xCurve1=[xCurve1 xClosest];
    yCurve1=[yCurve1 yClosest];

    xPrev=xClosest;
    yPrev=yClosest;
    
    end
end


xPrev=corner1(1); yPrev=corner1(2);
[xChk,yChk,xtemp,ytemp]=closestPoints(corner2(1),corner2(2),x,y);

for i=1:length(x)

    [xClosest,yClosest,x,y]=closestPoints(xPrev,yPrev,x,y);

    xCurve2=[xCurve2 xClosest];
    yCurve2=[yCurve2 yClosest];

    xPrev=xClosest;
    yPrev=yClosest;

end

figure
plot(xCurve1,yCurve1,'.')
hold on
plot(xCurve2,yCurve2,'.','Color','r')




%form the midpoints.  refCurve should always be the shortest, for error
%checking reasons
if length(xCurve1)<length(xCurve2)
    xRefCurve=xCurve1;
    yRefCurve=yCurve1;
    xOtherCurve=xCurve2;
    yOtherCurve=yCurve2;
else
    xRefCurve=xCurve2;
    yRefCurve=yCurve2;
    xOtherCurve=xCurve1;
    yOtherCurve=yCurve1;
end

ptsToRemove=length(xOtherCurve)-length(xRefCurve);
ptsToRemoveSpacing=floor(length(xOtherCurve)/ptsToRemove);
lo=length(xOtherCurve);

%Better check this bit of code out... it seems fishy

for i=1:lo
    if length(xOtherCurve)~=length(xRefCurve) && mod(i,ptsToRemoveSpacing)==0
        xOtherCurve=[xOtherCurve(1:9) xOtherCurve(11:end)];
        yOtherCurve=[yOtherCurve(1:9) yOtherCurve(11:end)];
    end
end

%find the midpoint of each pair
xCenterLine=[];
yCenterLine=[];

for i=1:length(xRefCurve)
    [x,y]=midpoint(xRefCurve(i),yRefCurve(i),xOtherCurve(i),yOtherCurve(i));
    xCenterLine=[xCenterLine x];
    yCenterLine=[yCenterLine y];
end

plot(xCenterLine,yCenterLine,'--','Color','k')


    
