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

% Process the binary matrix
% updated_matrix = process_binary_matrix(wormOut);
% 
% 
% %Overlay the skeleton on the original image
% imshow(labeloverlay(worm,updated_matrix,'Transparency',0))
% 
% 
% % Find the endpoints of the skeleton
% endpoints = bwmorph(updated_matrix, 'endpoints');
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
%     plotSkeleton = imshow(cat(3, zeros(size(updated_matrix)), updated_matrix, zeros(size(updated_matrix))));
%     set(plotSkeleton, 'AlphaData', 1); % Make skeleton partially transparent
%     hold on;
%     plot(head(2), head(1), 'r*'); % Plot head
%     plot(tail(2), tail(1), 'b*'); % Plot tail
%     hold off;
% else
%     disp('Could not find enough endpoints to determine head and tail.');
% end
% 
% function updated_matrix = process_binary_matrix(binary_matrix)
%     [m, n] = size(binary_matrix);
%     updated_matrix = binary_matrix; % Initialize the updated matrix
% 
%     % Iterate through the binary matrix
%     for i = m-1:-1:2
%         for j = 2:n-1
%             % Check if the current element is 1
%             if binary_matrix(i, j) == 1
%                 % Extract the 3x3 sub-matrix centered around the current element
%                 sub_matrix = binary_matrix(i-1:i+1, j-1:j+1);
%                 % Count the number of elements with value 1 in the sub-matrix
%                 num_ones = sum(sub_matrix(:)) - 1; % Exclude the center element
% 
%                 % If the count is greater than 3 and the center element has 0 right above and right below it
%                 if num_ones > 2 && binary_matrix(i-1, j) == 0 && binary_matrix(i+1, j) == 0
%                     % Update the center element to 0
%                     updated_matrix(i, j) = 0;
%                 end
%             end
%         end
%     end
% end
% % function updated_matrix = process_binary_matrix(binary_matrix)
% %     [m, n] = size(binary_matrix);
% %     updated_matrix = binary_matrix; % Initialize the updated matrix
% %     processed = false; % Flag to track if any 3x3 matrix has been processed
% % 
% %     % Iterate through the binary matrix
% %     for i = 2:m-1
% %         for j = 2:n-1
% %             % Check if the current element is 1 and hasn't been processed yet
% %             if binary_matrix(i, j) == 1 && ~processed
% %                 % Extract the 3x3 sub-matrix centered around the current element
% %                 sub_matrix = binary_matrix(i-1:i+1, j-1:j+1);
% %                 % Count the number of elements with value 1 in the sub-matrix
% %                 num_ones = sum(sub_matrix(:)) - 1; % Exclude the center element
% %                 % If the count is greater than 3, update the center element to 0
% %                 if num_ones > 2
% %                     updated_matrix(i, j) = 0;
% %                     processed = true; % Set the flag to true
% %                     break; % Exit the loop
% %                 end
% %             end
% %         end
% %         if processed
% %             break; % Exit the outer loop
% %         end
% %     end
% % end
