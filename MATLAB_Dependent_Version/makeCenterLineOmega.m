function [xcl, ycl] = makeCenterLineOmega(skeleton, head, tail)
    % Initialize empty arrays to store the centerline coordinates
    xcl = [];
    ycl = [];
    

    % Add the head coordinates to the centerline
    xcl = [xcl head(1)];
    ycl = [ycl head(2)];
    
    % Add the skeleton points between head and tail to the centerline
    [x, y] = edgesToCoordinates(skeleton);
    [x, y] = removeInd(x, y, find(x == head(1) & y == head(2)));  % Remove head point from skeleton
    [x, y] = removeInd(x, y, find(x == tail(1) & y == tail(2)));  % Remove tail point from skeleton
    
    while ~isempty(x)
        % Find the closest point to the last point added to the centerline
        [ind, ~] = findClosestPoint(xcl(end), ycl(end), x, y);
        
        % Add the closest point to the centerline
        xcl = [xcl x(ind)];
        ycl = [ycl y(ind)];
        
        % Remove the added point from the skeleton
        [x, y] = removeInd(x, y, ind);
    end
    
    % Add the tail coordinates to the centerline
    xcl = [xcl tail(1)];
    ycl = [ycl tail(2)];

    xcl=xcl(2:end-1);
    ycl=ycl(2:end-1);
end

function [xNew, yNew] = removeInd(x, y, indices)
    % Remove elements at specified indices from arrays x and y
    xNew = x;
    yNew = y;
    xNew(indices) = [];
    yNew(indices) = [];
end