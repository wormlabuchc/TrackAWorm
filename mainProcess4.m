%main image processing function!
function [xCenterLine,yCenterLine]=mainProcess4(filename,swap,clow,chigh,threshold)

persistent headPt tailPt xSeq ySeq h
%keep these variables around, in case we need to grab them later for
%swapping head and tail

img=imread(filename);
img=img(1:end,1:end,1);

[imgFilled,img,imgSub,isOmega]=prepImage(filename,clow,chigh,threshold);


img=edge(img,'sobel');
imgFilled=edge(imgFilled,'sobel');
imgSub=edge(imgSub,'sobel');




disp('Possible omega bend detected, changing algorithm');
[x,y]=edgesToCoordinates(imgFilled);
[xSeq,ySeq]=removeArtifacts(x,y);
[xSeq,ySeq]=smoothxy(xSeq,ySeq);
%     fewpoints=floor(length(xSeq)/3);
if ~isClockwise(xSeq(1:end),ySeq(1:end));
    xSeq=fliplr(xSeq);
    ySeq=fliplr(ySeq);
end


[xC,yC,headPt,tailPt]=findCorners2(xSeq,ySeq);
if isempty(headPt) && isempty(tailPt)
    disp('Both head and tail could not be found')
end

%{
The following code is for when there is a protruding head, +/- a protruding
tail
%}




done=0;
previousPoint=[xSeq(headPt) ySeq(headPt)];
previousTheta=[];

