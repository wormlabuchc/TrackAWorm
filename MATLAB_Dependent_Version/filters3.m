%Read the image
worm=imread('img_test3.jpeg');
imhist(worm);
%Adjust contrast
rwWorm=imadjust(worm,[0.4 0.6],[]);


%Apply edge filter
filtersize=[5 5];
wormFilter=wiener2(rwWorm,filtersize);
wormContrast=imadjust(wormFilter);

%Colors complemented
wormComplement=imcomplement(wormContrast);

% %Get the binary image
wormBinary=imbinarize(wormComplement,"adaptive");

%Fill the small gaps 
wormBinary=bwareafilt(wormBinary,1);


wormComplement=imcomplement(wormBinary);

wormBinary2=bwareaopen(wormComplement,80);



%Get the worm skeleton from the binary image
wormOut=bwskel(wormBinary,'MinBranchLength',20);


%Overlay the skeleton on the original image
imshow(labeloverlay(worm,wormOut,'Transparency',0))

