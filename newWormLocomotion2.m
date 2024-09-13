function locomotionData = newWormLocomotion2(splineFile,stageFile,timesFile,framerate,reducedframerate,calib,point,framesToAnalyze,res,corerate)
 
stageData = importdata(stageFile);
stageData = stageData.data;
stageData=stageData(:,1:2); 
[frameFileNumbers,~,splineData,~] = parseSplineFile(splineFile);
[times,~] = parseTimesFile(timesFile);
 
% PARSE DATA TO framesToAnalyze IN QUESTION
frameFileNumbers = frameFileNumbers(1:2:end);
%framesToAnalyze(1)
%framesToAnalyze(2)
frameFileNumbers = frameFileNumbers(framesToAnalyze(1):framesToAnalyze(2));
times = times(framesToAnalyze(1):framesToAnalyze(2));
timesData= importdata(timesFile);
% % timesData.colheaders{3}=="reducedframerate"
a=size(timesData.colheaders);
if a(2)==3 &framerate==15
    timesData=timesData.data;
    reducedframerate=timesData(:,3);
    reducedframerate=reducedframerate(1,1);
else 
    reducedframerate=0;
end

% framerate=timesData(:,3);
% framerate=framerate(1,1)

% class(timesData)


 



% CONVERT FROM PX TO MICROMETER UNITS
x = splineData(1:2:length(splineData(:,1)),:)*calib;
y = splineData(2:2:length(splineData(:,1)),:)*calib;
 
%x = x(framesToAnalyze(1):framesToAnalyze(2),:);
%y = y(framesToAnalyze(1):framesToAnalyze(2),:);
% if isempty(corerate) || corerate==1
%     rawrate=15;
% elseif corerate==2
%     rawrate=5;
% elseif corerate==3
%     rawrate=3;
% elseif corerate==4
%     rawrate=1;   
% end    

% x=OriginalRate(framerateOptions);
%If 15 fps, need to reduce frame rate to 3 fps for movement analyses
rawrate=0;
if framerate==15&&reducedframerate==0
    x=x(1:5:end,:);
    y=y(1:5:end,:);
    rawrate=3;
    times=times(1:5:end);
    %stageData=stageData(1:5:end,:);
    frameFileNumbers=frameFileNumbers(1:5:end);
elseif framerate==15&&reducedframerate==5
    rawrate=5;
elseif framerate==15&&reducedframerate==3
    rawrate=3;
elseif framerate==15&&reducedframerate==1
    rawrate=1; 
    
end

% 
% % COMPENSATE FOR STAGE MOVEMENT
% xComp = NaN(size(x));
% yComp = NaN(size(y));
%  
% rowNums = floor((frameFileNumbers-1)/framerate);
% 
% for i=1:length(frameFileNumbers)
%      
%     xComp(i,:) = x(i,:) + sum(stageData(1:rowNums(i)+1,1));
%     yComp(i,:) = -(((res(1)*calib)-y(i,:)) - sum(stageData(1:rowNums(i)+1,2)));
%      
% end
 
xComp = NaN(size(x));
yComp = NaN(size(y));
% stageData=stageData(:,1:2);
for frameNumber=1:length(xComp(:,1))
    %This is a problematic section because the correction formula depends
    %on when the stage moves.  Usually the stage starts moving at
    %I*Framerate+1 where I is any integer; for example it starts moving at
    %16, 31, etc.  It usually finishes moving by around I*Framerate+3 (19,
    %33, etc).  This can change unpredictably, however.
    [xcl,ycl]=compensateForStage(x(frameNumber,:),y(frameNumber,:),frameNumber,stageData,framerate,rawrate); 
%     xcl= x(frameNumber,:);
%     ycl= y(frameNumber,:);
    xComp(frameNumber,:)=xcl;
    yComp(frameNumber,:)=ycl;
   
end
% xComp
% FIND CENTROID OF THE SPLINE
xC = mean(xComp,2);
yC = mean(yComp,2);
 
% ISOLATE POINT IN QUESTION
if point~=0    
    xPoint = xComp(:,point);
    yPoint = yComp(:,point); 
else
    xPoint = xC; yPoint = yC;   
end
% AMPLITUDE CALCULATIONS
amp = zeros([1,length(xC) - 1]);
wormLength = zeros(size(amp));
 
for i=1:length(xC)
     
    proj = zeros([1 13]);
    len = zeros([1 12]);
     
%     headTailVector IS THE VECTOR POINTING FROM PREVIOUS POSITION TO
%     CURRENT ONE
    headTailVector = [xComp(i,end)-xComp(i,1),yComp(i,end)-yComp(i,1)];
     
%     perpVector IS RH PERPENDICULAR VECTOR TO movementVector & IS THEN
%     NORMALIZED TO unitPerpVector
    perpVector = [-headTailVector(2),headTailVector(1)];
    unitPerpVector = perpVector/norm(perpVector);
     
    for j=1:13
        
%         a IS AN INTERNAL VECTOR FROM WORM SPINE POINT j TO THE CENTROID
%         OF THE WORM
        %a = [xComp(i,j)-xC(i) yComp(i,j)-yC(i)];
        a = [xComp(i,j)-xC(i) yComp(i,j)-yC(i)];
         
%         proj(j) IS THE  PERPENDICULR DISTANCE BETWEEN THE WORM'S SPLINE
%         POINT j AND THE CENTROID
        proj(j) = dot(a,unitPerpVector);
         
        if j > 1
            len(j-1) =  ptDist(xComp(i,j),yComp(i,j),xComp(i,j-1),yComp(i,j-1));
        end
        
    end
    
    amp(i) = max(abs(proj));
    %wormLength(i) = norm(headTailVector);
    wormLength(i)= sum(len);
    amp(i)/wormLength(i); 
end

wormLength = wormLength(~isnan(wormLength));
 
amplitudeData = [{amp},{mean(amp)/mean(wormLength)}];
 
% SPEED CALCULATIONS
speeds = [frameFileNumbers NaN([length(xC) 1])];
 
timeDifs = [NaN;diff(times)];

for i=2:length(frameFileNumbers)
     
     
%     SPEED IS THE DISTANCE DIVIDED BY THE RESPECTIVE TIME DIFFERENCE 
    distance = ptDist(xPoint(i),yPoint(i),xPoint(i-1),yPoint(i-1));
    speeds(i,2)= distance/timeDifs(i);
 
end
 
speedData = {speeds(2:end,2)};
 
% DIRECTION CALCULATIONS
forwardCount = 0;
backwardCount = 0;
forwardDist = 0;
backwardDist = 0;
 
forwardSpeed = NaN([length(xC) 1]);
backwardSpeed = NaN([length(xC) 1]);
 
for i=2:length(xC)
     
%     movementVector IS THE VECTOR FROM THE PREVIOUS FRAME'S CENTROID TO
%     THE CURRENT ONE
    movementVector = [xC(i)-xC(i-1) yC(i)-yC(i-1)];
     
     
%     headVector IS THE VECTOR FROM THE CURRENT FRAME'S HEAD POINT TO ITS
%     CENTROID -- headVector IS THEN NORMALIZED
    headVector = [xComp(i,1)-xC(i) yComp(i,1)-yC(i)];
    unitHeadVector = headVector/norm(headVector);
     
%     proj IS THE COMPONENT OF THE WORM'S MOVEMENT PARALLEL TO THE
%     DIRECTION OF THE HEAD
    proj = dot(movementVector,unitHeadVector);
     
     
%     IF THE MAGNITUDE OF proj IS GREATER THAN 0, THEN THE HEAD DIRECTION
%     ADN THE MOVEMENT DIRECTION ARE PARALLEL, THE WORM IS MOVING FORWARDS
%     -- IF LESS THAN 0, THE VECTORS ARE ANTIPARALLEL, AND THE WORM IS
%     MOVING BACKWARDS
    if proj>=0
         
        forwardCount = forwardCount+1;
        forwardDist = forwardDist + ptDist(xC(i),yC(i),xC(i-1),yC(i-1));
        forwardSpeed(i) = ptDist(xC(i),yC(i),xC(i-1),yC(i-1))/timeDifs(i);
         
    elseif proj<0
         
        backwardCount = backwardCount+1;
        backwardDist = backwardDist + ptDist(xC(i),yC(i),xC(i-1),yC(i-1));
        backwardSpeed(i) = ptDist(xC(i),yC(i),xC(i-1),yC(i-1))/timeDifs(i);
         
    end
end
 
forwardSpeed = mean(forwardSpeed(~isnan(forwardSpeed)));
backwardSpeed = mean(backwardSpeed(~isnan(backwardSpeed)));
 
directionData = cell(1,2);
directionData{1} = [forwardDist,backwardDist];
directionData{2} = [forwardSpeed,backwardSpeed];
countData=cell(1,2);
countData{1} = forwardCount; countData{2}= backwardCount;

% DISTANCE CALCULATIONS
distanceSegments = NaN([1 length(xC)-1]);
 
% SUM THE DISTANCE BETWEEN EACH framesToAnalyze' CENTROID
for i=2:length(xC)
    distanceSegments(i-1) = ptDist(xC(i),yC(i),xC(i-1),yC(i-1));
end
 
% netDist IS THE DISTANCE BETWEEN THE WORM AT THE START AND THE WORM AT
% THE END
netDist = ptDist(xC(1),yC(2),xC(end),yC(end));
 
distanceData = cell(1,2);
 
distanceData{1} = distanceSegments; distanceData{2} = netDist; 

% plotData IS THE ABSOLUTE X AND Y POINTS OF THE WORM
plotData = cell(1,2);
plotData{1} = xPoint; plotData{2} = yPoint; 
 
% SAVE ALL DATA TO STRUCTURE
locomotionData = struct('Amplitude',amplitudeData,'Speed',speedData,'Direction',directionData,'Count',countData,'Plot',plotData,'Distance',distanceData);