function totalFrames = countFramesInFile(splineFile)

splineData = importdata(splineFile);
splineData=splineData.data;
totalFrames = size(splineData,1)/2;