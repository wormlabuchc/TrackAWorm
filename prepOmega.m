function [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix)

    %[xSeq,ySeq]=edgesToCoordinates(updated_matrix);
    % % [xSeq,ySeq]=removeArtifacts(xSeq,ySeq);
    
    % Find the endpoints of the skeleton
    endpoints = bwmorph(updated_matrix, 'endpoints');
    % 
    % Find the coordinates of the endpoints
    [row, col] = find(endpoints);
    % 
    
     % Extract the head and tail coordinates
     head = [row(1), col(1)];
     tail = [row(2), col(2)];
     
     %[xSeq,ySeq]=makeCenterLineOmega(updated_matrix,head,tail);

    
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

    
    [xSeq,ySeq]=makeCenterLineOmega(updated_matrix,head,tail);
    

    
    xCenterLine=xSeq;
    yCenterLine=ySeq;

    % xCenterLine = [yCenterLine_New(1) xCenterLine_New(2:1:end-1) yCenterLine_New(end)]
    % yCenterLine = [xCenterLine_New(1) yCenterLine_New(2:1:end-1) xCenterLine_New(end)]

    
    
    % Calculate the indices for uniformly spaced points
    indices = round(linspace(1, length(xCenterLine), 13));
    
    %  % Reorder the array
    % xCenterLine = [firstElement_X, remaining_values_X(indices), lastElement_X];
    % yCenterLine = [firstElement_Y, remaining_values_Y(indices), lastElement_Y];
    % 
    % Select the corresponding x and y coordinates  
    xCenterLine = xCenterLine(indices);
    yCenterLine = yCenterLine(indices);
   

    %xCenterLine = [yCenterLine_New(1) xCenterLine_New(2:1:end-1) yCenterLine_New(end)]
    %=[xCenterLine_New(1) yCenterLine_New(2:1:end-1) xCenterLine_New(end)]
    
    




    
    xcross=[];
    ycross=[];
    if isempty(xcross) && isempty(ycross)
        xcross=zeros(1,13);
        ycross=zeros(1,13);
    end
    
    if sum(xCenterLine)~=0 && sum(yCenterLine)~=0 %if an acceptable spline is found, save it as prevX/prevY
        prevX=xCenterLine;
        prevY=yCenterLine;
    end
    
    lastHeadX = xCenterLine(1); lastHeadY = yCenterLine(1);  %store the last head position for the next iteration of the loop
    fprintf('Successfully produced spline\n\n\n');
