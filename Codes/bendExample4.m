%% Example Data (Replace with Your Own)
% Specify your file name (and path if needed)
filename = 'bendExample.xlsx';

% Read all numeric data from the file into a matrix
data = readmatrix(filename);

% Extract columns (time is column 1; bending angle is column 4)
time = data(:, 1);
bending_angle = data(:, 3);

% --- USER-DEFINED PARAMETERS ---
epsilon   = 0;    % Tolerance for crossing (set to zero)
min_gap   = 20;    % Minimum sample gap (set to zero)
threshMax = 20;   % Only accept maxima >= this value
threshMin = -20;  % Only accept minima <= this value
% --------------------------------

%% 1) Detect raw zero-crossings with tolerance:
%    A zero crossing occurs when the signal goes from < -epsilon to > +epsilon or vice versa
rawZC = find( (bending_angle(1:end-1) < -epsilon & bending_angle(2:end) >  epsilon) | ...
              (bending_angle(1:end-1) >  epsilon & bending_angle(2:end) < -epsilon) );

%% 2) Merge zero crossings that are too close (noise artifact)
zcIndices = [];
if ~isempty(rawZC)
    zcIndices = rawZC(1);
    for i = 2:length(rawZC)
        if (rawZC(i) - zcIndices(end)) >= min_gap
            zcIndices(end+1) = rawZC(i); %#ok<AGROW>
        end
    end
end

fprintf('Found %d zero crossings.\n', length(zcIndices));

% Arrays to hold final maxima/minima from automatic detection
maxTimes = [];
maxVals  = [];
minTimes = [];
minVals  = [];

%% 3a) Handle the leftover segment at the *start* (index 1 to first zero crossing)
if ~isempty(zcIndices) && zcIndices(1) > 1
    segStart = 1;
    segEnd   = zcIndices(1);
    segIdx   = segStart : segEnd;
    
    if numel(segIdx) > 2
        if bending_angle(segStart) < 0
            % The trace starts negative, so look for a maximum candidate
            [val, idxLocal] = max(bending_angle(segIdx));
            actualIdx = segIdx(idxLocal);
            if val >= threshMax
                maxTimes(end+1) = time(actualIdx); %#ok<AGROW>
                maxVals(end+1)  = bending_angle(actualIdx); %#ok<AGROW>
            end
        else
            % The trace starts positive, so look for a minimum candidate
            [val, idxLocal] = min(bending_angle(segIdx));
            actualIdx = segIdx(idxLocal);
            if val <= threshMin
                minTimes(end+1) = time(actualIdx); %#ok<AGROW>
                minVals(end+1)  = bending_angle(actualIdx); %#ok<AGROW>
            end
        end
    end
end

%% 3b) Handle each full half cycle (segment between consecutive zero crossings)
for k = 1 : (length(zcIndices) - 1)
    segStart = zcIndices(k);
    segEnd   = zcIndices(k+1);
    segIdx   = segStart : segEnd;
    
    if numel(segIdx) < 2, continue; end
    
    if bending_angle(segStart) < 0
        % Negative -> positive half cycle: candidate is a maximum.
        [val, idxLocal] = max(bending_angle(segIdx));
        actualIdx = segIdx(idxLocal);
        if val >= threshMax
            maxTimes(end+1) = time(actualIdx); %#ok<AGROW>
            maxVals(end+1)  = bending_angle(actualIdx); %#ok<AGROW>
        end
    else
        % Positive -> negative half cycle: candidate is a minimum.
        [val, idxLocal] = min(bending_angle(segIdx));
        actualIdx = segIdx(idxLocal);
        if val <= threshMin
            minTimes(end+1) = time(actualIdx); %#ok<AGROW>
            minVals(end+1)  = bending_angle(actualIdx); %#ok<AGROW>
        end
    end
end

%% 3c) Handle the leftover segment at the *end* (last zero crossing to the final data point)
if ~isempty(zcIndices) && zcIndices(end) < length(bending_angle)
    segStart = zcIndices(end);
    segEnd   = length(bending_angle);
    segIdx   = segStart : segEnd;
    
    if numel(segIdx) > 2
        if bending_angle(segStart) < 0
            % The trace is rising above zero: candidate is a maximum.
            [val, idxLocal] = max(bending_angle(segIdx));
            actualIdx = segIdx(idxLocal);
            if val >= threshMax
                maxTimes(end+1) = time(actualIdx); %#ok<AGROW>
                maxVals(end+1)  = bending_angle(actualIdx); %#ok<AGROW>
            end
        else
            % The trace is going below zero: candidate is a minimum.
            [val, idxLocal] = min(bending_angle(segIdx));
            actualIdx = segIdx(idxLocal);
            if val <= threshMin
                minTimes(end+1) = time(actualIdx); %#ok<AGROW>
                minVals(end+1)  = bending_angle(actualIdx); %#ok<AGROW>
            end
        end
    end
end

%% 4) Plot the automatic detection results
figure;
plot(time, bending_angle, 'b-', 'LineWidth',1.5); hold on;
if ~isempty(maxTimes)
    plot(maxTimes, maxVals, 'ro', 'MarkerFaceColor','r', 'MarkerSize',8);
end
if ~isempty(minTimes)
    plot(minTimes, minVals, 'go', 'MarkerFaceColor','g', 'MarkerSize',8);
end
xlabel('Time (sec)');
ylabel('Bending Angle (deg)');
title('Automatic Detection of Maxima and Minima');
legend('Bend Trace','Auto Maxima','Auto Minima','Location','Best');
grid on;

%% 5) Allow User to Manually Add Missed Points Using Alt+Click
% Enable data cursor mode.
datacursormode on;
disp('Alt+click to add missed points. When finished, press Enter in the command window.');
pause;  % Wait for user input

% Retrieve user-selected points
dcm_obj = datacursormode(gcf);
cursorInfo = getCursorInfo(dcm_obj);

% Process each manually selected point
% (Assume: if the point's bending angle (y-value) > 0 and >= threshMax, add as max;
%  if y < 0 and <= threshMin, add as min)
for i = 1:length(cursorInfo)
    pos = cursorInfo(i).Position;  % [time, bending_angle]
    if pos(2) > 0 && pos(2) >= threshMax
        maxTimes(end+1) = pos(1);
        maxVals(end+1)  = pos(2);
    elseif pos(2) < 0 && pos(2) <= threshMin
        minTimes(end+1) = pos(1);
        minVals(end+1)  = pos(2);
    end
end

% Optional: Clear the datacursor selections so they don't clutter the plot.
datacursormode off;

%% 6) Replot the Final Results Including Manually Added Points
figure;
plot(time, bending_angle, 'b-', 'LineWidth',1.5); hold on;
if ~isempty(maxTimes)
    plot(maxTimes, maxVals, 'ro', 'MarkerFaceColor','r', 'MarkerSize',8);
end
if ~isempty(minTimes)
    plot(minTimes, minVals, 'go', 'MarkerFaceColor','g', 'MarkerSize',8);
end
% Highlight manually added points in different colors (magenta for max, cyan for min)
% To do this, we compare the final arrays with the ones from automatic detection.
% (Here we simply overlay them if needed.)
% You can also choose to mark them with a different marker.
xlabel('Time (sec)');
ylabel('Bending Angle (deg)');
title('Final Results: Auto + Manual Detection');
legend('Bend Trace','Maxima','Minima','Location','Best');
grid on; hold off;
