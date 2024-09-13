
%Read the image
worm=imread('img_test.jpeg');
worm = worm(1:end,1:end,1);
imshow(worm)


size(worm)

%Colors complemented
wormComplement=imcomplement(worm);

%Get the binary image
wormBinary=imbinarize(wormComplement,'adaptive');


% %Fill the small gaps with disk shaped object
se=strel('disk',3);
wormBinary=imclose(wormBinary,se);
wormBinary=bwareafilt(wormBinary,1);
imshow(wormBinary,[])


%Get the worm skeleton from the binary image
wormOut=bwskel(wormBinary,'MinBranchLength',20);


%Overlay the skeleton on the original image
imshow(labeloverlay(worm,wormOut,'Transparency',0))

% Process the binary matrix
updated_matrix = process_binary_matrix(wormOut);
% 
% 
%Overlay the skeleton on the original image
imshow(labeloverlay(worm,updated_matrix,'Transparency',0))
% 
[x,y]=edgesToCoordinates(updated_matrix);
[xSeq,ySeq]=removeArtifacts(x,y);

% Find the endpoints of the skeleton
endpoints = bwmorph(updated_matrix, 'endpoints');
% 
% Find the coordinates of the endpoints
[row, col] = find(endpoints);
% 
if numel(row) >= 2 % Check if there are at least two endpoints
    % Extract the head and tail coordinates
    head = [row(1), col(1)];
    tail = [row(2), col(2)];

    % If you want to visualize the head and tail points
    imshow(worm); % Display the grayscale worm image
    hold on;

    % Plot skeleton on top of the worm
    plotSkeleton = imshow(cat(3, zeros(size(updated_matrix)), updated_matrix, zeros(size(updated_matrix))));
    set(plotSkeleton, 'AlphaData', 0.5); % Make skeleton partially transparent

    % Plot head and tail points
    plot(head(2), head(1), 'r*'); % Plot head
    plot(tail(2), tail(1), 'b*'); % Plot tail

    hold off;
else
    disp('Could not find enough endpoints to determine head and tail.');
   
end
headx = head(2); % x-coordinate of the head
heady = head(1); % y-coordinate of the head
d=zeros(1,length(xSeq));
for i=1:length(xSeq)
    d(i)=ptDist(xSeq(i),ySeq(i),headx,heady);
end
newHead=find(d==min(d));

xSeq=[xSeq(newHead:end) xSeq(1:newHead-1)];
ySeq=[ySeq(newHead:end) ySeq(1:newHead-1)];

xCenterLine=xSeq;
yCenterLine=ySeq;
[xCenterLine,yCenterLine]=divideSpline(xCenterLine,yCenterLine,12);

xcross=[];
ycross=[];
if isempty(xcross) && isempty(ycross)
    xcross=[0 0 0 0 0 0 0 0 0 0 0 0 0];
    ycross=[0 0 0 0 0 0 0 0 0 0 0 0 0];
end

if sum(xCenterLine)~=0 && sum(yCenterLine)~=0 %if an acceptable spline is found, save it as prevX/prevY
    prevX=xCenterLine;
    prevY=yCenterLine;
end

lastHeadX = xCenterLine(1); lastHeadY = yCenterLine(1);  %store the last head position for the next iteration of the loop
fprintf('Successfully produced spline\n\n\n');

% 
function updated_matrix = process_binary_matrix(binary_matrix)
    [m, n] = size(binary_matrix);
    updated_matrix = binary_matrix; % Initialize the updated matrix

    % Iterate through the binary matrix
    for i = m-1:-1:2
        for j = 2:n-1
            % Check if the current element is 1
            if binary_matrix(i, j) == 1
                % Extract the 3x3 sub-matrix centered around the current element
                sub_matrix = binary_matrix(i-1:i+1, j-1:j+1);
                % Count the number of elements with value 1 in the sub-matrix
                num_ones = sum(sub_matrix(:)) - 1; % Exclude the center element

                % If the count is greater than 3 and the center element has 0 right above and right below it
                if num_ones > 2 && binary_matrix(i-1, j) == 0 && binary_matrix(i+1, j) == 0
                    % Update the center element to 0
                    updated_matrix(i, j) = 0;
                end
            end
        end
    end
end
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
function [xCoordinates,yCoordinates]=edgesToCoordinates(img)

xCoordinates=[];
yCoordinates=[];

xLength=length(img(1,1:end));
yLength=length(img(1:end,1));

% for i=1:xLength
%     img(1:end,i)=flipud(img(1:end,i));
% end

for x=1:xLength
    for y=1:yLength
        if img(y,x)
            xCoordinates=[xCoordinates x];
            yCoordinates=[yCoordinates y];
        end
    end
end

%image and array coordinate convention is different than plotting
%convention...  this is needed to be able to plot correctly.
yCoordinates=yLength-yCoordinates+1;
end
