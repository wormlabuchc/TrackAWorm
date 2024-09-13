%This function will find the sum of all eleven bends in a worm recording.
%It repeats this for every time point in the entire recording, and finds
%the average of all of the sums.  This gives some indication of whether
%there may be a difference in bending behavior between groups of worms.

function sumOfAngles = averageSumOfBendAngles(filename,framesToAnalyze)

[~,~,splineData,~] = parseSplineFile(filename);

x = splineData(1:2:end,:); y = splineData(2:2:end,:);

if ~strcmp(framesToAnalyze,'all')
    x = x(framesToAnalyze(1):framesToAnalyze(2),:);
    y = y(framesToAnalyze(1):framesToAnalyze(2),:);
end

wormBendAngles = NaN([size(x,1) 11]);

for i=1:size(x,1)
    frameAngles = findWormAngles(x(i,:),y(i,:));
    wormBendAngles(i,:) = frameAngles;
end

wormTotalAngles = NaN([1 size(wormBendAngles,1)]);

for i=1:length(wormTotalAngles)
    wormTotalAngles(i) = sum(abs(wormBendAngles(i,:)));
end

sumOfAngles = mean(wormTotalAngles(~isnan(wormTotalAngles)));