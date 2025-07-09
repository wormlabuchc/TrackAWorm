worm=imread('img_test4.jpeg');
worm = worm(1:end,1:end,1);





% %Colors complemented
% wormComplement=imcomplement(worm);
% 
% %Get the binary image
% wormBinary=imbinarize(wormComplement,'adaptive');
% 
% se = strel('diamond',2);
% img=imerode(wormBinary,se);
% 
% sb=strel('disk',3);
% wormBinary=imclose(img,sb);
% wormBinary=bwareafilt(wormBinary,1);
% imshow(wormBinary)


% %Fill the small gaps with disk shaped object
%se=strel('disk',3);
%wormBinary=imclose(wormBinary,se);
%wormBinary=bwareafilt(wormBinary,1);

points = detectHarrisFeatures(worm);
imshow(worm);
hold on; 
plot(points.selectStrongest(2));
corners=selectStrongest(points,2);
head1 = [corners.Location(1),corners.Location(3)]
tail = [corners.Location(2),corners.Location(4)]

