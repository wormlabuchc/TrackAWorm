function [imgFilled,img,imgSub,possibleOmega]=prepImage(imageString,clow,chigh,threshold,fill)

if nargin==4
    fill=1; %user can override the function and choose not to fill.  this is mostly useful for the manual spline
end

img = imread(imageString);
img = img(1:end,1:end,1);
img = imadjust(img,[clow chigh]);
se = strel('diamond',2);
img=imerode(img,se);
img=img<threshold;
img=bwareaopen(img, 500);   %remove all objects less than 500 pixels in area
if fill
    imgFilled=imfill(img,'holes');
end

%The following code checks if there is a relatively large hole in the worm
%silhouette, representing a possible omega bend.  Cutoff is >2.5% of the
%overall silhouette area.
imgSub=imgFilled-img;
cc=bwconncomp(imgSub,4);
objectAreas=zeros(1,cc.NumObjects);
holesToFill=[];
areaOfWorm=sum(sum(img));
for i=1:cc.NumObjects
    size=length(cc.PixelIdxList{i});
    objectAreas(i)=size;
    if size/areaOfWorm<0.01
        holesToFill=[holesToFill;cc.PixelIdxList{i}];
    end
end
img(holesToFill)=1-img(holesToFill); %fill in the small holes manually
imgSub(holesToFill)=1-imgSub(holesToFill);


if max(objectAreas)/areaOfWorm>0.01
    possibleOmega=1;
else
    possibleOmega=0;
end
%end code



%The following code tries to fit the smallest possible circle around the
%entire worm silhouette.  It then looks at the area of the worm silhouette
%versus the area of the circle.  A very high worm-to-circle ratio implies
%that the worm is in a more compact configuration, possibly an omega bend.

%not finished/not required??  -9/13/2013

%end code


imgFilled=~imgFilled;
% img=imdilate(img,se);
% img=img<100;    %threshold to binary image.