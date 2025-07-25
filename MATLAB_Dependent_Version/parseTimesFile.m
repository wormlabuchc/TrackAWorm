function [times,framerate,reducedframerate] = parseTimesFile(timesFile)

timesData = importdata(timesFile);
timesData=timesData.data;
times = timesData(:,1);
if size(timesData,2)==2
    framerate = timesData(1,2);
    reducedframerate=nan;
elseif size(timesData,2)==3 & timesData(1,2)==15
    framerate = 15;
    reducedframerate=timesData(1,3);
elseif size(timesData,2)==3 & timesData(1,2)~=15
    framerate=timesData(1,3);
    reducedframerate=timesData(1,2);
end
% size(timesData,2)
% framerate = timesData(1,2);
%reducedframerate=timesData(1,3);


