function callManualCurve(handles,hObject)

fixHandles = [handles.fixA,handles.fixB,handles.fixC,handles.fixD,handles.fixE,handles.fixF,handles.fixG,handles.fixH,handles.fixI,handles.fixJ];

overrideData = get(handles.fixA,'UserData');
splineData = get(handles.inputSplinePath,'UserData');
ventralData = get(handles.ventralMessage,'UserData');

frameMatrix = get(handles.frame,'UserData');
topRow = get(handles.topRow,'Value');
framesToDisplay = frameMatrix(topRow:topRow+1,:);

currentFrameNumber = find(fixHandles==hObject);
currentFrameNumber = framesToDisplay(floor((currentFrameNumber-1)/5)+1,mod(currentFrameNumber-1,5)+1);

x = splineData(1:2:end,:); y = splineData(2:2:end,:);

% xSpline & ySpline ARE 1x24 ROW VETCTORS
xSpline = x(currentFrameNumber,:); ySpline = y(currentFrameNumber,:);
xSpline = interp(xSpline,9); ySpline = interp(ySpline,9);
xSpline = xSpline(1:5:end); ySpline = ySpline(1:5:end);

xySpline = [xSpline' ySpline'];

ventralDir = ventralData(currentFrameNumber);

pointsSelected = manualCurve_gui(xSpline,ySpline);

pointsSelectedIndices = NaN([1 size(pointsSelected,1)]);

for i=1:size(pointsSelected,1)
   pointsSelectedIndices(i) = findClosestPoint(pointsSelected(i,1),pointsSelected(i,2),xSpline,ySpline);
end

pointsSelectedIndices = sort(pointsSelectedIndices)';

% CREATE Nx2 LIST OF SEGMENTS, WITH START POINTS AND END POINTS FROM pointsSelectedIndices
pointsSelectedIndices = [pointsSelectedIndices(1:end-1),pointsSelectedIndices(2:end)];


% CONVERT SELECTION DATA TO INDICES NORMALIZED TO CURVE xSpline,ySpline (RANGE [1,24])
% for i=1:size(pointsSelected,1)
%    pointsSelectedIndices(i) = findClosestPoint(pointsSelected(i,1),pointsSelected(i,2),xSpline,ySpline);
% end
% 
% pointsSelectedIndices = fliplr(pointsSelectedIndices);
% 
% pointsSelectedIndicesChange = diff(pointsSelectedIndices)>0;
% 
% % ANY POINTS NOT IN INCREASING ORDER ARE DISCARDED
% for i=1:length(pointsSelectedIndicesChange)
%     if ~pointsSelectedIndicesChange(i)
%         pointsSelectedIndices(i+1) = NaN;
%     end   
% end

% CREATE Nx2 LIST OF SEGMENTS, WITH START POINTS AND END POINTS FROM pointsSelectedIndices
% pointsSelectedIndices = pointsSelectedIndices(~isnan(pointsSelectedIndices));
% pointsSelectedIndices = [pointsSelectedIndices(1:end-1)',pointsSelectedIndices(2:end)'];

% LENGTH OF WORM
L = pathLength(xSpline,ySpline);

rPrime = NaN([1 size(pointsSelectedIndices,1)]);
circlevdDirs = cell(length(pointsSelectedIndices),1);
wormCircles = cell(length(pointsSelectedIndices),1);
wormCircleCenters = cell(length(pointsSelectedIndices),1);

newPointsSelectedIndices = cell([1 length(pointsSelectedIndices)]);

for i=1:length(pointsSelectedIndices(:,1))
    
    segStart = pointsSelectedIndices(i,1);
    segEnd = pointsSelectedIndices(i,2);
    
    segmentPoints = segStart:segEnd;
    
    xSeg = xSpline(segmentPoints);
    ySeg = ySpline(segmentPoints);
    
    xySeg = [xSeg' ySeg'];
    
    circle = CircleFitByKasa(xySeg);
    a = circle(1); b = circle(2); r = circle(3);
    
    rL = r/L;
    wL = pathLength(xSeg,ySeg);
    
    if rL>0.01 && rL<.8 && wL>3
        
        if isClockwise(xSeg,ySeg) && ventralDir==1
%           DORSAL
            circlevdDirs{i} = -1;
        elseif isClockwise(xSeg,ySeg) && ventralDir==2
%           VENTRAL
            circlevdDirs{i} = 1;
        elseif ~isClockwise(xSeg,ySeg) && ventralDir==1
%           VENTRAL
            circlevdDirs{i} = 1;
        elseif ~isClockwise(xSeg,ySeg) && ventralDir==2
%           DORSAL
            circlevdDirs{i} = -1;
        elseif ventralDir==0
            circlevdDirs{i} = 0;
        end
        
        rPrime(i) = rL;
        
        thetas = 0:.05:2*pi;
        cx = a+r*cos(thetas);
        cy = b+r*sin(thetas);
        
        wormCircles{i} = [cx' cy'];
        wormCircleCenters{i} = [a b];
        
        newPointsSelectedIndices{i} = [segStart,segEnd];
        
    end
end

% DISCARD ANY MISSING CELLS DUE TO UNUSED WORM SEGMENTS
circlevdDirs = circlevdDirs(~cellfun('isempty',circlevdDirs));
wormCircles = wormCircles(~cellfun('isempty',wormCircles));
wormCircleCenters = wormCircleCenters(~cellfun('isempty',wormCircleCenters));

pointsSelectedIndices = newPointsSelectedIndices(~cellfun('isempty',newPointsSelectedIndices))';
pointsSelectedIndices = cell2mat(pointsSelectedIndices);

circlevdDirs = cell2mat(circlevdDirs)';

rLInverses = rPrime.^-1;

curvature = rLInverses;

overrideRow = [{currentFrameNumber} {curvature} {circlevdDirs} {xySpline} {pointsSelectedIndices} {wormCircles} {wormCircleCenters}];

if ~isempty(overrideData)
    overridenFrames = [overrideData{:,1}];
else
    overridenFrames = [];
end

% IF NEW OVERRIDE IS PERFORMED, ADD TO OVERRIDE LIST AND SORT
if ~ismember(currentFrameNumber,overridenFrames)
    
    overrideData = [overrideData;overrideRow];
    overrideData = sortrows(overrideData,1);
    
% OTHERWISE REPLACE THE EXISTING OVERRIDE OF THE FRAME
else
    
    overrideRowNumber = find(overridenFrames==currentFrameNumber);
    overrideData = [[overrideData{1:overrideRowNumber-1,:}];overrideRow;[overrideData{overrideRowNumber+1:end,:}]];
    
end

set(handles.fixA,'UserData',overrideData);