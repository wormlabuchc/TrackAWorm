worm=imread("img_test3.jpeg");
wormGray=im2gray(worm);
nHood=true(3);
wormRNG=rangefilt(wormGray,nHood);
%wormRNG=rescale(wormRNG);
%wormBW=imbinarize(wormRNG);
% wormSmooth=medfilt2(wormRNG,[3,3]);
% wormBW=imbinarize(wormSmooth);

%wormRNG=imadjust(wormRNG);
%wormBW=imbinarize(wormRNG,0.9);
wormRNG=bwareaopen(wormRNG,40);
wormMask=activecontour(worm,wormRNG,"Chan-vese","ContractionBias",-.5);
imshow(wormMask)


%wormBinary=bwareafilt(wormBW,1);
%imshow(wormBinary)

% %Get the worm skeleton from the binary image
% wormOut=bwskel(wormBW,'MinBranchLength',20);
% 
% 
% %Overlay the skeleton on the original image
% imshow(labeloverlay(worm,wormOut,'Transparency',0))
% 
% % Find the endpoints of the skeleton
% endpoints = bwmorph(wormOut, 'endpoints');
% 
% % Find the coordinates of the endpoints
% [row, col] = find(endpoints);
% 
% if numel(row) >= 2 % Check if there are at least two endpoints
%     % Extract the head and tail coordinates
%     head = [row(1), col(1)];
%     tail = [row(2), col(2)];
% 
%     % If you want to visualize the head and tail points
%     imshow(worm);
%     % Plot skeleton
%     plotSkeleton = imshow(cat(3, zeros(size(wormOut)), wormOut, zeros(size(wormOut))));
%     set(plotSkeleton, 'AlphaData', 1); % Make skeleton partially transparent
%     hold on;
%     plot(head(2), head(1), 'r*'); % Plot head
%     plot(tail(2), tail(1), 'b*'); % Plot tail
%     hold off;
% else
%     disp('Could not find enough endpoints to determine head and tail.');
% end