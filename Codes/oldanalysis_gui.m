




function saveAndAppend_Callback(hObject, eventdata, handles)

comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end

path = get(handles.exportPath,'String');

getAnalysisProperties

bendNumber = str2double(get(handles.bendNumber,'String'));    %this one is excluded from getAnalysisProperties

%1.) ANIMAL NAME AND COMMENTS

slashPosition = find(splineFile==slash);
slashPosition = slashPosition(end);
animalName = splineFile(1+slashPosition:end-4);
animalName = {animalName};

comments=get(handles.exportComments,'String');

if isempty(comments)
    comments='';
end

comments={comments};

%2.) RECORDING LENGTH

spline = load(splineFile);

if strcmp(framesToAnalyze,'all')
    numberOfRecordings=length(spline(:,1))/2;
else
    numberOfRecordings=framesToAnalyze(2)-framesToAnalyze(1)+1;
end

lengthOfRecording = numberOfRecordings/framerate;
lengthOfRecording = {num2str(lengthOfRecording)};

%3.) SUM OF ANGLES

sumOfAngles = averageSumOfBendAngles(splineFile,framesToAnalyze);
sumOfAngles = {num2str(sumOfAngles)};

%4.) FREQUNECY OF BEND ANGLES

[freq,~,~] = fftscript(splineFile,bendNumber,framerate,framesToAnalyze);
freq={num2str(freq)};

%5.) RMS OF BEND ANGLES

rms = findRms(splineFile,bendNumber,framesToAnalyze);
rms = {num2str(rms)};

%6.) MAXIMUM BEND ANGLE

if get(handles.doMaxBend,'Value')
    [freq,time,head] = fftscript(splineFile,bendNumber,frameRate,framesToAnalyze);
    exc = bendCursor_gui(time,head);
    exc = {num2str(exc)};
else
    exc={'N/A'};
end

%DATA FROM WORM LOCOMOTION FUNCTIONS

if isempty(get(handles.movementPanel,'UserData'))
    locomotionData = wormLocomotion(splineFile,stageFile,timesFile,framerate,calib,point,framesToAnalyze);
    set(handles.movementPanel,'UserData',locomotionData);
else
    locomotionData = get(handles.movementPanel,'UserData');
end

%7.) AVERAGE AMPLITUDE

amp = locomotionData(1).Amplitude;
alratio = locomotionData(2).Amplitude;
meanAmp=mean(amp);
meanAmp={num2str(meanAmp)};
alratio={num2str(alratio)};

%8.) AVERAGE SPEED
speed = locomotionData.Speed;
meanSpeed = mean(speed(~isnan(speed)));
meanSpeed = {num2str(meanSpeed)};

%9.) DISTANCE
distance = locomotionData(1).Distance;
totalDistance = sum(distance);
netDist = locomotionData(2).Distance;
totalDistance = {num2str(totalDistance)};
netDistance = {num2str(netDist)};


%10.) DIRECTION STEPS
directionSteps = locomotionData(1).Direction;
stepsForward = directionSteps(1);
stepsForward = {num2str(stepsForward)};
stepsBackward = directionSteps(2);
stepsBackward = {num2str(stepsBackward)};

%11.) DIRECTION DISTANCES
directionDist = locomotionData(2).Direction;
distForward= directionDist(1);
distBackward = directionDist(2);

%12.) THRASHING COUNT
[thrashCount,thrashFreq] = thrashingFreq(splineFile,framerate);
thrashCount = {num2str(thrashCount)};
thrashFreq = {num2str(thrashFreq)};

labels=[{'Animal'} {'Point'} {'Bend'} {'Comments'} {'Rec Length'} {'Avg Sum Bends'} {'Freq'} {'RMS'} {'Max Bend'} {'Avg Amp'} {'A/L Ratio'} {'Avg Spd'} {'Tot Dist'} {'Net Dist'} {'Steps F'} {'Steps B'} {'Dist F'} {'Dist B'} {'Thrash Count'} {'Thrash Freq'}];
newDataLine=[animalName {num2str(point)} {num2str(bendNumber)} comments lengthOfRecording sumOfAngles freq rms exc meanAmp alratio meanSpeed totalDistance netDistance stepsForward stepsBackward distForward distBackward thrashCount thrashFreq];

if ~exist(path,'file') %if the file does not already exist, create it without using the "append" tag.
    newData = [labels;newDataLine];
else
    [~,~,oldData] = xlsread(path);
    newData = [lables;oldData;newDataLine];
end

try
    xlswrite(path,newData);
catch ME
    ME
end

disp('Data Saved')





function framesToAnalyze_Callback(hObject, eventdata, handles)

function framesToAnalyze_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in thrashing.
function thrashing_Callback(hObject, eventdata, handles)
% hObject    handle to thrashing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
getAnalysisProperties
[n,freq]=thrashingFreq(splineFile,frameRate);
freq=round(freq*10)/10;
set(handles.bendMessages,'String',['Thrashing count: ' num2str(n) ' Freq: ' num2str(freq) '/min']);



function timesPath_Callback(hObject, eventdata, handles)
% hObject    handle to timesPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timesPath as text
%        str2double(get(hObject,'String')) returns contents of timesPath as a double


% --- Executes during object creation, after setting all properties.
function timesPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timesPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browseTimes.
function browseTimes_Callback(hObject, eventdata, handles)
% hObject    handle to browseTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
