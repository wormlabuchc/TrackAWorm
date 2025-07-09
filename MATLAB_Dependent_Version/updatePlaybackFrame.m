function updatePlaybackFrame(currentFrameNumber, handles)

    fileList = get(handles.frame,'UserData');
    showThresh = get(handles.showThresh,'Value');
    threshold = floor(str2double(get(handles.threshold,'String')));
    splineData = get(handles.splinePath,'UserData');
    showSplines = get(handles.showSplines,'Value');

    currentImage = imread(fileList{currentFrameNumber});
    res = size(currentImage);

    % Apply threshold if enabled
    if showThresh && threshold >= 0 && threshold < 256
        currentImage(currentImage <= threshold) = 0;
        currentImage(currentImage > threshold) = 255;
    end

    % Clear the axis before plotting new frame (optimization)
    cla(handles.win);  % Clears the current axis

    % Plot the image
    imshow(currentImage, 'Parent', handles.win);
    
    % Only plot the splines if enabled
    if showSplines
        xSpline = splineData(2 * currentFrameNumber - 1, :);
        ySpline = splineData(2 * currentFrameNumber, :);
        xC = mean(xSpline, 2);
        yC = mean(ySpline, 2);
        
        if ~isempty(xSpline) && mean(xSpline)
            % Plot spline data
            hold(handles.win, 'on');
            plot(handles.win, xSpline, res(1) - ySpline + 1, 'c', 'LineWidth', 1);
            plot(handles.win, xSpline(end-2:end), res(1) - ySpline(end-2:end) + 1, 'm', 'LineWidth', 1);
            plot(handles.win, xSpline(1:2), res(1) - ySpline(1:2) + 1, 'r', 'LineWidth', 1);
            scatter(handles.win, xSpline, res(1) - ySpline + 1, 12, 'filled', 'MarkerFaceColor', 'w');
            plot(handles.win, xSpline(1), res(1) - ySpline(1) + 1, 'r.', 'MarkerSize', 20);
            scatter(handles.win, xC, res(1) - yC + 1, 30, 'filled', 'MarkerFaceColor', [1, 0.5, 0]);
        end
    end

    % Update frame number display
    set(handles.currentFrameNumber, 'Value', currentFrameNumber, 'String', num2str(currentFrameNumber));
    set(handles.slider1, 'Value', currentFrameNumber);
end
