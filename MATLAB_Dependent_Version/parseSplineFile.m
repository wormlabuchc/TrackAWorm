function [frameFileNumbers,ventralData,splineData,crossData] = parseSplineFile(splineFile)
%function[frameFileNumbers, splineData] = parseSplineFile(splineFile)
splineData = importdata(splineFile);
splineData = splineData.data;

frameFileNumbers = splineData(:,1);
%x = length(frameFileNumbers);
%disp(x);
%frameFileNumbers = [1:1:x];
ventralData = splineData(1:2:end,2)';
crossData = splineData(:,16:28);
splineData = splineData(:,3:15);