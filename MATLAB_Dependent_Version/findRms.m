function rms = findRms(splineFile,selectedNode,framesToAnalyze)

[~,~,splineData,~] = parseSplineFile(splineFile);

x = splineData(1:2:end,:); y = splineData(2:2:end,:);

if ~strcmp(framesToAnalyze,'all')
    x = x(framesToAnalyze(1):framesToAnalyze(2),:);
    y = y(framesToAnalyze(1):framesToAnalyze(2),:);
end

wormSegmentAngles = NaN([size(x,1) 11]);

for i=1:size(x,1)
    frameAngles = findWormAngles(x(i,:),y(i,:));
    wormSegmentAngles(i,:) = frameAngles;
end

selectedNodeAngle = wormSegmentAngles(:,selectedNode)
size(selectedNodeAngle)
class(selectedNodeAngle)

theta = selectedNodeAngle;
thetaSumsquared = sum(theta.^2);
rms = sqrt(thetaSumsquared/length(theta));