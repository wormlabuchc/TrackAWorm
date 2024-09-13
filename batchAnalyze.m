function batchAnalyze(StageData,fileData,savePath,overwriteOption)

animalNameData = cell([length(fileData) 1]);
lengthOfRecordingData = cell([length(fileData) 1]);
bendNumberData = cell([length(fileData) 1]);
splinePointData = cell([length(fileData) 1]);
avgSumOfBendsData = cell([length(fileData) 1]);
amplitudeData = cell([length(fileData) 3]);
maxBendData = cell([length(fileData) 1]);
frequencyData = cell([length(fileData) 1]);
avgSpeedData = cell([length(fileData) 3]);
directionMetricsData = cell([length(fileData) 4]);
rmsData = cell([length(fileData) 1]);
distanceData = cell([length(fileData) 2]);
thrashingData = cell([length(fileData) 2]);
countData = cell([length(fileData) 2]);
length(fileData)

for i=1:length(fileData)
    
    splineFile = fileData(i).splineFile;
    stageFile = fileData(i).stageFile;
    timesFile = fileData(i).timesFile;
    framesToAnalyze = fileData(i).framesToAnalyze;
%     class(framesToAnalyze)
%     framesToAnalyze(1)
    bendNumber = fileData(i).bendNumber;
    splinePoint = fileData(i).splinePoint;
    res = parseSplineFileForRes(splineFile);
    
    [frameFileNumbers,~,~,~] = parseSplineFile(splineFile);
    [~,calib] = parseStageFile(stageFile);
    [~,framerate] = parseTimesFile(timesFile);
    [~,~,reducedframerate]=parseTimesFile(timesFile);
    
    optionsMatrix = fileData(i).optionsMatrix;
    
    animalName = {fileData(i).wormName};
    animalNameData(i) = animalName;
    
    numberOfFrames = size(frameFileNumbers,1)/2;
    
    lengthOfRecording = size(StageData,1)-1
    lengthOfRecording = {num2str(lengthOfRecording)};
    lengthOfRecordingData(i) = lengthOfRecording; 
        
%     LOCOMOTION DATA
    [~,~,reducedframerate]=parseTimesFile(timesFile);
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,reducedframerate,calib,splinePoint,framesToAnalyze);
    
%     AVERAGE SUM OF BENDS

    if optionsMatrix(1)
    
        sumOfAngles = averageSumOfBendAngles(splineFile,framesToAnalyze);
        sumOfAngles = {num2str(sumOfAngles)};
        avgSumOfBendsData(i) = sumOfAngles;
        
    else
        
        avgSumOfBendsData{i} = 'N/A';
        
    end
    
%     AVERAGE AMPLITUDE

    if optionsMatrix(2)
        
        amp = locomotionData(1).Amplitude;
        alratio = locomotionData(2).Amplitude;
        meanAmp = mean(amp);
        wormLength= meanAmp/alratio;
        wormLength= {num2str(wormLength)};
        meanAmp = {num2str(meanAmp)};
        alratio = {num2str(alratio)};
        amplitudeData(i,1) = meanAmp;
        amplitudeData(i,2) = alratio;
        amplitudeData(i,3)= wormLength;
        
    else
        
        amplitudeData(i,1:3) = [{'N/A'} {'N/A'} {'N/A'}];
        
    end
    
%     MAXIMUM BEND

    if optionsMatrix(3)
        
        [~,time,selectedBendAngles] = fftFunction(splineFile,bendNumber,framerate,framesToAnalyze);
        exc = bendCursor_gui(time,selectedBendAngles);
        exc = {num2str(exc)};
        maxBendData(i) = exc;
        
    else
        
        maxBendData{i} = 'N/A';
        
    end
    
%     FREQUENCY

    if optionsMatrix(4)
        
        [freq,~,~] = fftFunction(splineFile,bendNumber,framerate,framesToAnalyze);
        freq = {num2str(freq)};
        frequencyData(i) = freq;
        
    else
        
        frequencyData{i} = 'N/A';
        
    end

    
%     AVERAGE SPEED

    if optionsMatrix(5)
        
        speed = locomotionData.Speed;
        meanSpeed = mean(speed(~isnan(speed)));
        meanSpeed = {num2str(meanSpeed)};
        avgSpeedData(i,1) = meanSpeed;
        directionSpeeds = locomotionData(2).Direction;
        speedForward = directionSpeeds(1);
        if isnan(speedForward)
            speedForward={'N/A'};
        else
            speedForward = {num2str(speedForward)};
        end
        speedBackward = directionSpeeds(2);
        if isnan(speedBackward)
            speedBackward={'N/A'};
        else
            speedBackward = {num2str(speedBackward)};
        end
        avgSpeedData(i,2)=speedForward;
        avgSpeedData(i,3)=speedBackward;
    else
        
        avgSpeedData(i,1:3) = [{'N/A'} {'N/A'} {'N/A'}];
        
    end
    
%     DIRECTION METRICS

    if optionsMatrix(6)
        directionDist = locomotionData(1).Direction;
        
        distForward= {directionDist(1)};
        distBackward = {directionDist(2)};
        
        
        stepsForward = locomotionData(1).Count;
        stepsForward = {num2str(stepsForward)};
        
        stepsBackward = locomotionData(2).Count;
        stepsBackward = {num2str(stepsBackward)};
        
        
        
        directionMetricsData(i,:) = [distForward distBackward stepsForward stepsBackward];
        
    else
        
        directionMetricsData(i,:) = [{'N/A'} {'N/A'} {'N/A'} {'N/A'}];
        
    end
    
%     RMS

    if optionsMatrix(7)
        
        rms = findRms(splineFile,bendNumber,framesToAnalyze);
        rms = {num2str(rms)};
        rmsData(i) = rms;
        
    else
        
        rmsData{i} = 'N/A';
        
    end
    
%     DISTANCE

    if optionsMatrix(8)
        
        distance = locomotionData(1).Distance;
        totalDistance = sum(distance);
        netDist = locomotionData(2).Distance;
        totalDistance = {num2str(totalDistance)};
        netDist = {num2str(netDist)};
        distanceData(i,1) = totalDistance;
        distanceData(i,2) = netDist;
        
    else
        
        distanceData(i,:) = [{'N/A'} {'N/A'}];
        
    end
    
%     THRASHING

    if optionsMatrix(9)

        [thrashCount,thrashFreq] = thrashingFreq(splineFile,framerate);
        thrashCount = {num2str(thrashCount)};
        thrashFreq = {num2str(thrashFreq)};
        thrashingData(i,1) = thrashCount;
        thrashingData(i,2) = thrashFreq;
        
    else
        
        thrashingData(i,:) = [{'N/A'} {'N/A'}];
        
    end
    
%     BEND NUMBER AND SPLINE POINT

    if splinePoint == 0
        splinePoint = 'C';
    else
        splinePoint = num2str(splinePoint);
    end

    bendNumberData(i) = {num2str(bendNumber)};
    splinePointData(i) = {splinePoint};
    
end

%labels = [{'Animal'} {'Rec Length'} {'Bend'} {'Spline Point'} {'Avg Sum Bends'} {'Avg Amp'} {'A/L Ratio'} {'Max Bend'} {'Freq'} {'Avg Spd'} {'Steps F'} {'Steps B'} {'Dist F'} {'Dist B'} {'RMS'} {'Tot Dist'} {'Net Dist'} {'Thrash Count'} {'Thrash Freq'}];
%comments = [{'Batch-produced'}];
% size(animalNameData)           %2 by 1
%  size(lengthOfRecordingData)    %2 by 1
%  size(bendNumberData)           %2 by 1
%  size(splinePointData)          %2 by 1
%  size(avgSumOfBendsData)        %2 by 1
% size(amplitudeData)          %2 by 2
% size(maxBendData)              %2 by 1
% size(frequencyData)            %2 by 1 
% size(avgSpeedData)             %2 by 1
% size(directionMetricsData)     %2 by 4
% size(rmsData)                  %2 by 1
% size(distanceData)           %2 by 2
% size(speedForward)
% size(speedBackward)
% size(thrashingData)            %2 by 2
%size(sumOfAngles)
%labels = [{'Animal'} {'Rec Length'} {'Bend'} {'Spline Point'} {'Avg Sum Bends'} {'Avg Amp'} {'A/L Ratio'} {'Max Bend'} {'Freq'} {'Avg Spd'} {'Steps F'} {'Steps B'} {'Dist F'} {'Dist B'} {'RMS'} {'Tot Dist'} {'Net Dist'} {'Thrash Count'} {'Thrash Freq'}];
%newDataLine = [animalNameData lengthOfRecordingData bendNumberData splinePointData avgSumOfBendsData amplitudeData maxBendData frequencyData avgSpeedData directionMetricsData rmsData distanceData thrashingData];
labels=[{'Animal'} {'SplinePoint'} {'Bend'} {'Rec Length'} {'Avg Sum Bends'} {'Freq'} {'RMS'} {'Max Bend'} {'Avg Amp'} {'A/L Ratio'} {'wormLength'} {'Avg Spd'} {'Speed F'} {'Speed B'} {'Tot Dist'} {'Net Dist'} {'Dist F'} {'Dist B'} {'Frames F'} {'Frames B'} {'Thrash Count'} {'Thrash Freq'} ];
newDataLine=[animalNameData splinePointData bendNumberData lengthOfRecordingData avgSumOfBendsData frequencyData rmsData maxBendData amplitudeData avgSpeedData distanceData directionMetricsData thrashingData];
%if the file does not already exist, create it without using the "append" tag.
if overwriteOption==1 
    newData = [labels;newDataLine];    
else
    [~,~,oldData] = xlsread(savePath);
    newData = [oldData;newDataLine];    
end

try
    
    %xlswrite(exportPath,newData);
    writecell(newData,savePath);
    disp('Data saved');
    
catch ME
    
    disp('Error saving excel file');
    ME
    
end