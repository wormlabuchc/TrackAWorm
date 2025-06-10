function varargout = batchAnalyze_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @batchAnalyze_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @batchAnalyze_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function batchAnalyze_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
% set(handles.avgSumOfBends, 'Visible', 'off');
% set(handles.avgAmplitude, 'Visible', 'off');
% set(handles.frequency, 'Visible', 'off');
% set(handles.avgSpeed, 'Visible', 'off');
% set(handles.directionMetrics, 'Visible', 'off');
% set(handles.rms, 'Visible', 'off');
% set(handles.totalDistance, 'Visible', 'off');
% set(handles.thrashing, 'Visible', 'off');
% set(handles.set, 'Visible', 'off');
% set(handles.uipanel6, 'Visible', 'off');
guidata(hObject, handles);

function varargout = batchAnalyze_gui_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

function splineFileList_Callback(hObject, eventdata, handles)

if ~isempty(get(handles.splineFileList,'String'))
    
    rowNum = get(hObject,'Value');
    splineFileData = get(hObject,'UserData');
    
    optionsHandles = [handles.avgSumOfBends,handles.avgAmplitude,handles.maxBend,handles.frequency,handles.avgSpeed,handles.directionMetrics,handles.rms,handles.totalDistance,handles.thrashing];
    
    optionsMatrix = splineFileData(rowNum).optionsMatrix;
    bendNumber = splineFileData(rowNum).bendNumber;
    splinePoint = splineFileData(rowNum).splinePoint;
    
    for i=1:length(optionsMatrix)
        
        set(optionsHandles(i),'Value',optionsMatrix(i))
        
    end
    
    set(handles.bendNumber,'Value',bendNumber)
    set(handles.splinePoint,'Value',splinePoint+1)
    
end

function splineFileList_CreateFcn(hObject, eventdata, handles)

set(hObject,'UserData',struct());

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function splineFilePath_Callback(hObject, eventdata, handles)

splinePath = get(hObject,'String');

comp = computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash = '/';
else
    slash = '\';
end

if exist(splinePath,'file')
    
    lastSlash = find(splinePath==slash);
    lastSlash = lastSlash(end);
    
    wormName = splinePath(lastSlash+1:end-11);
    
    set(handles.splineFilePath,'String',splinePath,'UserData',wormName);
    
    stagePath = [splinePath(1:lastSlash) wormName slash wormName '.txt'];
    timesPath = [splinePath(1:lastSlash) wormName slash wormName '_times.txt'];
    savePath = [splinePath(1:lastSlash) wormName '_results.xlsx'];
    
    set(handles.exportPath,'UserData',savePath);
    
    if exist(stagePath,'file') && exist(timesPath,'file')
        
        set(handles.stageFilePath,'String',stagePath);
        set(handles.timesFilePath,'String',timesPath);
        
        set(handles.add,'Enable','on');
        
        flashBox('g',handles.splineFilePath,handles.stageFilePath,handles.timesFilePath);
        
    elseif exist(stagePath,'file') && ~exist(timesPath,'file')
        
        set(handles.stageFilePath,'String',stagePath);
        set(handles.timesFilePath,'String','Enter path to times .txt file');
        
        set(handles.add,'Enable','off');
        
        flashBox('g',handles.splineFilePath,handles.stageFilePath,'r',handles.timesFilePath);
                
    elseif ~exist(stagePath,'file') && exist(timesPath,'file')
                
        set(handles.stageFilePath,'String','Enter path to stage .txt file');
        set(handles.timesFilePath,'String',timesPath);
        
        set(handles.add,'Enable','off');
        
        flashBox('g',handles.splineFilePath,handles.timesFilePath,'r',handles.stageFilePath)
                
    elseif ~exist(stagePath,'file') && ~exist(timesPath,'file')
                
        set(handles.stageFilePath,'String','Enter path to stage .txt file');
        set(handles.timesFilePath,'String','Enter path to times .txt file');
        
        set(handles.add,'Enable','off');
        
        flashBox('g',handles.splineFilePath,'r',handles.stageFilePath,handles.timesFilePath);
        
    end
    
else
    
    set(handles.add,'Enable','off');
    
    flashBox('r',hObject);
    
end

function splineFilePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browse_Callback(hObject, eventdata, handles)
savePath = get(handles.exportPath,'String');
saveIndex = get(handles.exportPath,'Value');
switch savePath
    case 'Browse to name an Excel file to save results...'
        msg=msgbox('Enter Excel file to export results.');
    otherwise
        newsplinePath= get(handles.splineFilePath,'String');
        %[lastsplinePath,~]=fileparts(newsplinePath);
        %cd(newsplinePath)
 
     if isempty(newsplinePath)
         
         [filename,pathname] = uigetfile('*.txt',pwd);   
     else
         disp('yes')
         [filename,pathname] = uigetfile('*.txt',newsplinePath);
         %lastsplinePath
     end

splinePath = [pathname,filename];

comp = computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash = '/';
else
    slash = '\';
end

if ~isnumeric(splinePath)
    
    lastSplinePath = splinePath;
    
    lastSlash = find(splinePath==slash);
    lastSlash = lastSlash(end);
    
    wormName = splinePath(lastSlash+1:end-11);
    
    set(handles.splineFilePath,'String',splinePath,'UserData',wormName);
    
    stagePath = [splinePath(1:lastSlash) wormName slash wormName '.txt'];
    timesPath = [splinePath(1:lastSlash) wormName slash wormName '_times.txt'];
    savePath = [splinePath(1:lastSlash) wormName '_results.xlsx'];
    
    set(handles.exportPath,'UserData',savePath);
    
    if exist(stagePath,'file') && exist(timesPath,'file')
        
        set(handles.stageFilePath,'String',stagePath);
        set(handles.timesFilePath,'String',timesPath);
        
        set(handles.add,'Enable','on');
        set(handles.avgSumOfBends,'Value',1);
        set(handles.avgAmplitude,'Value',1);
        %set(handles.maxBend,'Value',1);
        set(handles.frequency,'Value',1);
        set(handles.avgSpeed,'Value',1);
        set(handles.directionMetrics,'Value',1);
        set(handles.rms,'Value',1);
        set(handles.totalDistance,'Value',1);
        %set(handles.thrashing,'Value',1);
        
        
        
        
        
        flashBox('g',handles.splineFilePath,handles.stageFilePath,handles.timesFilePath);
        
    elseif exist(stagePath,'file') && ~exist(timesPath,'file')
        
        set(handles.stageFilePath,'String',stagePath);
        set(handles.timesFilePath,'String','Enter path to times .txt file');
        
        set(handles.add,'Enable','off');
        
        flashBox('g',handles.splineFilePath,handles.stageFilePath,'r',handles.timesFilePath);
                
    elseif ~exist(stagePath,'file') && exist(timesPath,'file')
                
        set(handles.stageFilePath,'String','Enter path to stage .txt file');
        set(handles.timesFilePath,'String',timesPath);
        
        set(handles.add,'Enable','off');
        
        flashBox('g',handles.splineFilePath,handles.timesFilePath,'r',handles.stageFilePath)
                
    elseif ~exist(stagePath,'file') && ~exist(timesPath,'file')
                
        set(handles.stageFilePath,'String','Enter path to stage .txt file');
        set(handles.timesFilePath,'String','Enter path to times .txt file');
        
        set(handles.add,'Enable','off');
        
        flashBox('g',handles.splineFilePath,'r',handles.stageFilePath,handles.timesFilePath);
        
    end
    
end
end


function stageFilePath_Callback(hObject, eventdata, handles)

stagePath = get(hObject,'String');

if exist(stagePath,'file')
      
    splinePath = get(handles.splineFilePath,'String');
    timesPath = get(handles.timesFilePath,'String');
    
    if exist(splinePath,'file') && exist(timesPath,'file')
        
        set(handles.add,'Enable','on');
        
        flashBox('g',hObject);
        
    else
        
        set(handles.add,'Enable','off');
        
        flashBox('r',hObject);
        
    end
    
else
    
    set(handles.add,'Enable','off');
    
    flashBox('r',hObject);
    
end

function stageFilePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseStage_Callback(hObject, eventdata, handles)
savePath = get(handles.exportPath,'String');
saveIndex = get(handles.exportPath,'Value');
switch savePath
    case 'Enter Excel file to export results...'
        msg=msgbox('Enter Excel file to export results.');
    otherwise
        persistent lastStagePath

        if isempty(lastStagePath)   
            [filename,pathname] = uigetfile('*.txt',pwd);   
        else
            [filename,pathname] = uigetfile('*.txt',lastStagePath);
end

stagePath = [pathname,filename];

if ~isnumeric(stagePath)
    
    lastStagePath = stagePath;
      
    splinePath = get(handles.splineFilePath,'String');
    timesPath = get(handles.timesFilePath,'String');
    
    if exist(splinePath,'file') && exist(timesPath,'file')
        
        set(handles.add,'Enable','on');
        
        flashBox('g',handles.stageFilePath);
        
    else
        
        set(handles.add,'Enable','off');
        
        flashBox('r',handles.stageFilePath);
        
    end
    
end
end

function timesFilePath_Callback(hObject, eventdata, handles)

timesPath = get(hObject,'String');

if exist(timesPath,'file')
      
    splinePath = get(handles.splineFilePath,'String');
    stagePath = get(handles.stageFilePath,'String');
    
    if exist(splinePath,'file') && exist(stagePath,'file')
        
        set(handles.add,'Enable','on');
        
        flashBox('g',hObject);
        
    else
        
        set(handles.add,'Enable','off');
        
        flashBox('r',hObject);
        
    end
    
else
    
    set(handles.add,'Enable','off');
    
    flashBox('r',hObject);
    
end

function timesFilePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseTimes_Callback(hObject, eventdata, handles)
savePath = get(handles.exportPath,'String');
saveIndex = get(handles.exportPath,'Value');
switch savePath
    case 'Enter Excel file to export results...'
        msg=msgbox('Enter Excel file to export results.');
    otherwise
        persistent lastTimesPath

        if isempty(lastTimesPath)   
            [filename,pathname] = uigetfile('*.txt',pwd);   
        else
            [filename,pathname] = uigetfile('*.txt',lastTimesPath);
        end

timesPath = [pathname,filename];

if ~isnumeric(timesPath)
    
    lastTimesPath = timesPath;
      
    splinePath = get(handles.splineFilePath,'String');
    stagePath = get(handles.stageFilePath,'String');
    
    if exist(splinePath,'file') && exist(stagePath,'file')
        
        set(handles.add,'Enable','on');
        
        flashBox('g',handles.timesFilePath);
        
    else
        
        set(handles.add,'Enable','off');
        
        flashBox('r',handles.timesFilePath);
        
    end
    
end
end

function add_Callback(hObject, eventdata, handles)

splineFilePath = get(handles.splineFilePath,'String');
stageFilePath = get(handles.stageFilePath,'String');
timesFilePath = get(handles.timesFilePath,'String');
wormName = get(handles.splineFilePath,'UserData');
savePath = get(handles.exportPath,'String');
% if ~strcmp(get(handles.exportPath,'String'),'Browse to name an Excel file to save results...')
%     
%     if exist(savePath,'file')
%         
%         overwriteOption = questdlg('Results Excel file already exists. Ovewrite or append new data?','Overwite confirmation','Overwrite','Append','Cancel','Cancel');
% 
%         switch overwriteOption
%             
%             case 'Overwrite'
%                 overwriteOption = 1;
%             case 'Append'
%                 overwriteOption = 0;
%             case 'Cancel'
%                 return
%                 
%         end
%         
%         set(handles.exportPath,'String',savePath,'Value',overwriteOption);
%         
%     else
%         
%         set(handles.exportPath,'String',savePath,'Value',1);
%         
%     end
%     
% end
        
avgSumOfBends = get(handles.avgSumOfBends,'Value');
avgAmplitude = get(handles.avgAmplitude,'Value');
maxBend = get(handles.maxBend,'Value');
frequency = get(handles.frequency,'Value');
avgSpeed = get(handles.avgSpeed,'Value');
directionMetrics = get(handles.directionMetrics,'Value');
rms = get(handles.rms,'Value');
totalDistance = get(handles.totalDistance,'Value');
thrashing = get(handles.thrashing,'Value');

bendNumber = get(handles.bendNumber,'Value');
splinePoint = get(handles.splinePoint,'Value')-1;

[~,calib] = parseStageFile(stageFilePath);
[~,framerate] = parseTimesFile(timesFilePath);

totalFrames = countFramesInFile(splineFilePath);

splineFileList = get(handles.splineFileList,'String');
fileData = get(handles.splineFileList,'UserData');

newRow = length(splineFileList)+1;

optionsMatrix = logical([avgSumOfBends,avgAmplitude,maxBend,frequency,avgSpeed,directionMetrics,rms,totalDistance,thrashing]);
%optionsMatrix = logical(maxBend)
fileData(newRow).wormName = wormName;
fileData(newRow).bendNumber = bendNumber;
fileData(newRow).splinePoint = splinePoint;
fileData(newRow).calib = calib;
fileData(newRow).framerate = framerate;
fileData(newRow).framesToAnalyze = [1,totalFrames];
fileData(newRow).optionsMatrix = optionsMatrix;
fileData(newRow).splineFile = splineFilePath;
fileData(newRow).stageFile = stageFilePath;
fileData(newRow).timesFile = timesFilePath;

if splinePoint
    splinePoint = num2str(splinePoint);
else
    splinePoint = 'C';
end

summaryStringOptions = [{'ASoB'},{'AA'},{'MB'},{'F'},{'AS'},{'DM'},{'RMS'},{'TD'},{'T'}];
summaryStringOptions = summaryStringOptions(optionsMatrix);

dashPadding = {' - '};
dashPadding = repelem(dashPadding,max(length(summaryStringOptions)-1,0));

summaryString = cell([1 length(dashPadding)+length(summaryStringOptions)]);
summaryString(1:2:end) = summaryStringOptions; summaryString(2:2:end) = dashPadding;
summaryString = [wormName ': ' cell2mat(summaryString) ' - Bend#: ' num2str(bendNumber) ', SplinePt#: ' splinePoint];

splineFileList = [splineFileList;{summaryString}];

selectedSplineFileList = get(handles.splineFileList,'Value');

if isempty(selectedSplineFileList)
    selectedSplineFileList = 1;
else
    selectedSplineFileList = max(selectedSplineFileList,1);
end

set(handles.splineFileList,'String',splineFileList,'UserData',fileData,'Value',selectedSplineFileList);
set(handles.remove,'Enable','on');
set(handles.set,'Enable','on');

function remove_Callback(hObject, eventdata, handles)

splineFileList = get(handles.splineFileList,'String');
fileData = get(handles.splineFileList,'UserData');
rowNum = get(handles.splineFileList,'Value');

% CHOSE ROW TO LEAVE SELECTED AFTER REMOVING CURRENT ONE
if rowNum==1 && length(splineFileList)==1
    newRowNum = 0;
elseif rowNum==length(splineFileList)
    newRowNum = rowNum-1;
else
    newRowNum =  rowNum;
end

if newRowNum==0
    set(handles.exportPath,'String','Browse to name an Excel file to save results...','Value',0);
end

if rowNum~=0
    
    splineFileList = [splineFileList(1:rowNum-1);splineFileList(rowNum+1:end)];
%     fileData = [fileData(1:rowNum-1),fileData(rowNum+1:end)];
    fileData(rowNum) = [];
    
    set(handles.splineFileList,'String',splineFileList,'UserData',fileData,'Value',newRowNum);
    
    if ~newRowNum
        
        set(hObject,'Enable','off');
        set(handles.set,'Enable','off');
        
    end
    
end

function set_Callback(hObject, eventdata, handles)

rowNum = get(handles.splineFileList,'Value');
splineFileList = get(handles.splineFileList,'String');
fileData = get(handles.splineFileList,'UserData');

avgSumOfBends = get(handles.avgSumOfBends,'Value');
avgAmplitude = get(handles.avgAmplitude,'Value');
maxBend = get(handles.maxBend,'Value');
frequency = get(handles.frequency,'Value');
avgSpeed = get(handles.avgSpeed,'Value');
directionMetrics = get(handles.directionMetrics,'Value');
rms = get(handles.rms,'Value');
totalDistance = get(handles.totalDistance,'Value');
thrashing = get(handles.thrashing,'Value');

bendNumber = get(handles.bendNumber,'Value');
splinePoint = get(handles.splinePoint,'Value')-1;

wormName = fileData(rowNum).wormName;

optionsMatrix = logical([avgSumOfBends,avgAmplitude,maxBend,frequency,avgSpeed,directionMetrics,rms,totalDistance,thrashing]);

fileData(rowNum).bendNumber = bendNumber;
fileData(rowNum).splinePoint = splinePoint;
fileData(rowNum).optionsMatrix = optionsMatrix;

if splinePoint
    splinePoint = num2str(splinePoint);
else
    splinePoint = 'C';
end

summaryStringOptions = [{'ASoB'},{'AA'},{'MB'},{'F'},{'AS'},{'DM'},{'RMS'},{'TD'},{'T'}];
summaryStringOptions = summaryStringOptions(optionsMatrix);

dashPadding = {' - '};
dashPadding = repelem(dashPadding,max(length(summaryStringOptions)-1,0));

summaryString = cell([1 length(dashPadding)+length(summaryStringOptions)]);
summaryString(1:2:end) = summaryStringOptions; summaryString(2:2:end) = dashPadding;
summaryString = [wormName ': ' cell2mat(summaryString) ' - Bend#: ' num2str(bendNumber) ', SplinePt#: ' splinePoint];

splineFileList = [splineFileList(1:rowNum-1);{summaryString};splineFileList(rowNum+1:end)];

if ~get(handles.splineFileList,'Value')
    set(handles.splineFileList,'Value',1);
end

set(handles.splineFileList,'String',splineFileList,'UserData',fileData);

function bendNumber_Callback(hObject, eventdata, handles)

function bendNumber_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function splinePoint_Callback(hObject, eventdata, handles)

function splinePoint_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function analyze_Callback(hObject, eventdata, handles)
savePath = get(handles.exportPath,'String');
StageData=get(handles.stageFilePath,'String');
StageData = importdata(StageData);
StageData=StageData.data;
if ~strcmp(get(handles.exportPath,'String'),'Browse to name an Excel file to save results...')
    
    if exist(savePath,'file')
        
        overwriteOption = questdlg('Results Excel file already exists. Ovewrite or append new data?','Overwite confirmation','Overwrite','Append','Cancel','Cancel');

        switch overwriteOption
            
            case 'Overwrite'
                overwriteOption = 1;
            case 'Append'
                overwriteOption = 0;
            case 'Cancel'
                return
                
        end
        
        set(handles.exportPath,'String',savePath,'Value',overwriteOption);
        
    else
        
        set(handles.exportPath,'String',savePath,'Value',1);
        
    end
    
end
savePath = get(handles.exportPath,'String');
overwriteOption = get(handles.exportPath,'Value');

if ~strcmp(savePath,'Browse to name an Excel file to save results...')
    
    fileData = get(handles.splineFileList,'UserData');
    
    batchThreshold = str2double(get(handles.batchThreshold, 'String'));
    batchAnalyze(StageData,fileData,savePath,overwriteOption,batchThreshold);
    
else
    
    disp('Enter path to export Excel file');
    
end

function avgSumOfBends_Callback(hObject, eventdata, handles)


function frequency_Callback(hObject, eventdata, handles)
filefunction rms_Callback(hObject, eventdata, handles)

function avgAmplitude_Callback(hObject, eventdata, handles)

function avgSpeed_Callback(hObject, eventdata, handles)

function totalDistance_Callback(hObject, eventdata, handles)

function maxBend_Callback(hObject, eventdata, handles)
[splineFile,~,~,framerate,~,~,framesToAnalyze,~] = getAnalysisProperties(handles);
batchThreshold = str2double(get(handles.batchThreshold, 'String'));

bendNumber = get(handles.bendNumber,'Value');
fs = framerate;

[~,time,selectedBendAngles] = fftFunction(splineFile,bendNumber,fs,framesToAnalyze);

exc = bendCursor_gui(time,selectedBendAngles, batchThreshold);
exc = round(exc*100)/100;

function directionMetrics_Callback(hObject, eventdata, handles)

function thrashing_Callback(hObject, eventdata, handles)

function exportPath_Callback(hObject, eventdata, handles)

% savePath = get(hObject,'String');
% 
% if exist(savePath,'file')
%     
%     overwriteOption = questdlg('Results Excel file already exists. Ovewrite or append new data?','Overwite confirmation','Overwrite','Append','Cancel','Cancel');
%     
%     switch overwriteOption
%         
%         case 'Overwrite'
%             overwriteOption = 0;
%         case 'Append'
%             overwriteOption = 1;
%         case 'Cancel'
%             return
%             
%     end
%     
%     set(handles.exportPath,'String',savePath,'Value',overwriteOption);
%     
% else
%     
%     set(handles.exportPath,'String',savePath,'Value',0);
%     
% end

function exportPath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseExport_Callback(hObject, eventdata, handles)

defaultSavePath = get(hObject,'UserData');

if isempty(defaultSavePath)
    defaultSavePath = pwd;
end

[filename,pathname] = uiputfile('*.xlsx', 'Save data in spreadsheet',defaultSavePath);
if ~isnumeric(filename) && ~isnumeric(pathname)
    set(handles.exportPath,'String',[pathname filename]);
end
savePath = [pathname,filename];

% if ~isnumeric(savePath)
% 
%     if exist(savePath,'file')
%         
%         overwriteOption = questdlg('Results Excel file already exists. Ovewrite or append new data?','Overwite confirmation','Overwrite','Append','Cancel','Cancel');
%         
%         switch overwriteOption
%             
%             case 'Overwrite'
%                 overwriteOption = 0;
%             case 'Append'
%                 overwriteOption = 1;
%             case 'Cancel'
%                 return
%                 
%         end
%         
%         set(handles.exportPath,'String',savePath,'Value',overwriteOption);
%         
%     else
%         
%         set(handles.exportPath,'String',savePath,'Value',0);
%         
%     end
%    
% --- Executes during object creation, after setting all properties.
function analyze_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function analyze_DeleteFcn(hObject, eventdata, handles)

    



function batchThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to batchThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of batchThreshold as text
%        str2double(get(hObject,'String')) returns contents of batchThreshold as a double


% --- Executes during object creation, after setting all properties.
function batchThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batchThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
