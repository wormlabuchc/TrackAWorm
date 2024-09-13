function [stageMovement,calib] = parseStageFile(stageFile)

stageData = importdata(stageFile);
stageData =stageData.data;

stageMovement = stageData(:,1:2);
calib = stageData(1,3);
