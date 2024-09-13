function [times,framerate,reducedframerate] = parseReducedTimes(timesFile)
timesData = importdata(timesFile);
timesData=timesData.data;
times = timesData(:,1);
framerate = timesData(1,2);
reducedframerate=timesData(1,3);