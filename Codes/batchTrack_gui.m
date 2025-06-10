function varargout = batchTrack_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @batchTrack_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @batchTrack_gui_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

function batchTrack_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

function varargout = batchTrack_gui_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

function imagePath_Callback(hObject, eventdata, handles)

imagePath = get(hObject,'String');

if exist(imagePath,'dir')
    
    set(handles.load,'Enable','on');
    set(handles.imagePath,'String',imagePath);
    
    inputSplinePath = [imagePath '_spline.txt'];
    
    if exist(inputSplinePath,'file')
        
        set(handles.loadInputSpline,'Enable','on');
        set(handles.inputSplinePath,'String',inputSplinePath);
        
        flashBox('g',handles.imagePath,handles.inputSplinePath);
        
    else
        
        set(handles.loadInputSpline,'Enable','off');
        set(handles.inputSplinePath,'String','Enter path to spline .txt...');
        
        flashBox('g',handles.imagePath,handles.inputSplinePath);
        
    end
    
else
    
    set(handles.load,'Enable','off');
    
    set(handles.loadInputSpline,'Enable','off');
    set(handles.inputSplinePath,'String','Enter path to spline .txt...');
    
    flashBox('r',handles.imagePath,handles.loadInputPath);
    
end

function imagePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseImage_Callback(hObject, eventdata, handles)

persistent lastImagePath

if isempty(lastImagePath)   
    imagePath = uigetdir(pwd);   
else  
    imagePath = uigetdir(lastImagePath);
end

if ~isnumeric(imagePath)
    
    lastImagePath = imagePath;
    
    set(handles.load,'Enable','on');
    set(handles.imagePath,'String',imagePath);
    
    inputSplinePath = [imagePath '_spline.txt'];
    
    if exist(inputSplinePath,'file')
        
        set(handles.loadInputSpline,'Enable','on');
        set(handles.inputSplinePath,'String',inputSplinePath);

        flashBox('g',handles.imagePath,handles.inputSplinePath);
        
    else
        
        set(handles.loadInputSpline,'Enable','off');
        set(handles.inputSplinePath,'String','Enter path to spline .txt...');
        
        flashBox('g',handles.imagePath,'r',handles.inputSplinePath);
    
    end
    
end

function load_Callback(hObject, eventdata, handles)

swapHandles = [handles.swapA,handles.swapB,handles.swapC,handles.swapD,handles.swapE,handles.swapF,handles.swapG,handles.swapH,handles.swapI,handles.swapJ];
manualHandles = [handles.manualA,handles.manualB,handles.manualC,handles.manualD,handles.manualE,handles.manualF,handles.manualG,handles.manualH,handles.manualI,handles.manualJ];
windowHandles = [handles.winA,handles.winB,handles.winC,handles.winD,handles.winE,handles.winF,handles.winG,handles.winH,handles.winI,handles.winJ];
crossHandles = [handles.crossA,handles.crossB,handles.crossC,handles.crossD,handles.crossE,handles.crossF,handles.crossG,handles.crossH,handles.crossI,handles.crossJ];

% FIND APPROPRIATE SLASH FOR USERS'S COMPUTER
comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end

imagePath = get(handles.imagePath,'String');

splinePath = [imagePath '_spline.txt'];

set(handles.inputSplinePath,'UserData',[]);
set(handles.save,'UserData',splinePath);

% REMOVE EXISITING CROSS DATA
set(handles.crossA,'UserData',[]);

% LOAD IMAGES AND CHECK THAT LENGTHS ARE APPROPRIATE
fixNumbers(imagePath);

%Check resolution of images and assign appropriate file List
fileList = listJpegsInFolder(imagePath);
img=imread(fileList{1});
[height, width, ~] = size(img);

if width == 728 
    %Define a temp folder to store the resized images
    tempFolder = fullfile(imagePath, 'resized_temp');
    if ~exist(tempFolder, 'dir')
        mkdir(tempFolder)
    end

    % Get JPEG files
    imageFiles = dir(fullfile(imagePath, '*.jpeg'));
    fileList = {};  % Initialize cell array to hold paths to resized images

    % Resize and save to temp folder
    for k = 1:length(imageFiles)
        originalPath = fullfile(imagePath, imageFiles(k).name);
        img = imread(originalPath);
        img_resized = imresize(img, 0.5);

        newPath = fullfile(tempFolder, imageFiles(k).name);
        imwrite(img_resized, newPath);
        fileList{end+1} = newPath;  % Store path to resized image
    end

    % Set handles.imagePath to file list
    set(handles.imagePath, 'UserData', fileList);
    disp('resizing done')
else
    set(handles.imagePath,'UserData',fileList);
    disp('No resizing')
end



% fixNumbers(imagePath);
% filelist = listJpegsInFolder(imagePath);
% 
% disp('All .jpeg images have been resized by half.');
% class(resizedImages)




numberOfFrames = length(fileList);
m = ceil(numberOfFrames/5);
frameMatrix=zeros(5,m);
frameMatrix(1:numberOfFrames) = 1:numberOfFrames;
frameMatrix=frameMatrix';
set(handles.frame,'UserData',frameMatrix);

% CLEAR ALL IMAGE FRAMES
for i=1:10
    cla(windowHandles(i));
end

% RETURN SCROLL TO TOP ROW (FRAME NUMBERS 1-5)
topRow = 1;
set(handles.topRow,'Value',topRow,'String',num2str(topRow),'Enable','on');
updateBatchTrackFrames(handles,topRow)

% TURN OFF ALL BUTTONS
set(swapHandles,'Enable','off');
set(manualHandles,'Enable','off');
set(crossHandles,'Enable','off');

% GET VENTRAL DIRECTION FROM FILE NAMES
ventralDir = zeros(1,length(fileList)); %0 = none

for i=1:length(fileList)
    
    currentFile = fileList{i};
    
    lastSlash = find(currentFile==slash);
    lastSlash = lastSlash(end);
    
    currentFile = currentFile(lastSlash+1:end);
    
%         1 = LEFT   
    if strcmp(currentFile(1:2),'R_')
        ventralDir(i)=1;
%         2 = LEFT
    elseif strcmp(currentFile(1:2),'L_')
        ventralDir(i)=2;
    else
        ventralDir(i)=0;
    end
    
end
set(handles.ventralMessage,'UserData',ventralDir);

function threshold_Callback(hObject, eventdata, handles)

function threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function start_Callback(hObject, eventdata, handles)
set(handles.percentComplete,'Enable','on');

persistent prevX prevY

% HANDLES FOR USE IN SOME LOOPS
swapHandles = [handles.swapA,handles.swapB,handles.swapC,handles.swapD,handles.swapE,handles.swapF,handles.swapG,handles.swapH,handles.swapI,handles.swapJ];
manualHandles = [handles.manualA,handles.manualB,handles.manualC,handles.manualD,handles.manualE,handles.manualF,handles.manualG,handles.manualH,handles.manualI,handles.manualJ];
crossHandles = [handles.crossA,handles.crossB,handles.crossC,handles.crossD,handles.crossE,handles.crossF,handles.crossG,handles.crossH,handles.crossI,handles.crossJ];

imagePath = get(handles.imagePath,'String');
%Check resolution of images and assign appropriate file List
fileList = listJpegsInFolder(imagePath);
img=imread(fileList{1});
[height, width, ~] = size(img);

if width == 728 
    %Define a temp folder to store the resized images
    tempFolder = fullfile(imagePath, 'resized_temp');
    imageFiles = dir(fullfile(tempFolder, '*.jpeg'));
    fileList = {};
    for k = 1:length(imageFiles)
         newPath = fullfile(tempFolder, imageFiles(k).name);
         fileList{end+1} = newPath;  % Store path to resized image
    end
    % Set handles.imagePath to file list
    set(handles.imagePath, 'UserData', fileList);
    disp('Done Now- Resizing');
else
    fileList = get(handles.imagePath,'UserData');
    disp('Done Now- No resizing')
end
%filelist = get(handles.imagePath,'UserData');


frameMatrix = get(handles.frame,'UserData');

splineData = zeros(2*length(fileList),13);

clow = 0; chigh = 1;

threshold = str2double(get(handles.threshold,'String'));

% MAIN IMAGE PROCESSING SCRIPT
tic;
analysisLoop
elapsedTime = toc;
disp(elapsedTime)
fprintf('Script executed in %.2f seconds.\n', elapsedTime);

% STORE DATA IN HANDLES' USERDATA -- CROSS DATA IS ONLY RELEVANT FOR IMAGES
% WHERE A CROSS IS IDENTIFIED -- IT IS AN 'ALTERNATIVE' SET OF SPLINE POINT
% IN THESE FRAMES, AND IT IS A 1X13 ROW OF ZEROS IN ALL OTHER FRAMES
set(handles.inputSplinePath,'UserData',splineData);
set(handles.crossA,'UserData',crossData);
%set(handles.manualNeededText,'UserData',manualNeeded);
set(handles.resHolder,'UserData',res);

% DISPLAY RED BOXES AND MANUAL NEEDED MESSAGE IN ANY FRAMES THAT COULD NOT
% BE COMPLETED
%displayManualNeededMessage(handles);

disp('Done Analyzing Frames')
Done='Done Analyzing Frames';
set(handles.percentComplete,'String', Done);
topRow = str2double(get(handles.topRow,'String'));

updateBatchTrackFrames(handles,topRow);

function inputSplinePath_Callback(hObject, eventdata, handles)

inputSplinePath = get(handles.inputSplinePath,'String');

if exist(inputSplinePath,'file')
    
    set(handles.loadInputSpline,'Enable','on');
    
    flashBox('g',handles.inputSplinePath);
    
else
    
    set(handles.loadInputSpline,'Enable','off');
    
    flashBox('r',handles.inputSplinePath);
    
end

function inputSplinePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseInputSpline_Callback(hObject, eventdata, handles)

persistent lastInputSplinePath

if isempty(lastInputSplinePath)   
    inputSplinePath = uigetfile('*.txt',pwd);   
else
    inputSplinePath = uigetfile('*.txt',lastInputSplinePath);
end

if ~isnumeric(inputSplinePath)
    
    set(handles.loadInputSpline,'Enable','on');
    
    lastInputSplinePath = inputSplinePath;
    
end

function loadInputSpline_Callback(hObject, eventdata, handles)

swapHandles = [handles.swapA,handles.swapB,handles.swapC,handles.swapD,handles.swapE,handles.swapF,handles.swapG,handles.swapH,handles.swapI,handles.swapJ];
manualHandles = [handles.manualA,handles.manualB,handles.manualC,handles.manualD,handles.manualE,handles.manualF,handles.manualG,handles.manualH,handles.manualI,handles.manualJ];
crossHandles = [handles.crossA,handles.crossB,handles.crossC,handles.crossD,handles.crossE,handles.crossF,handles.crossG,handles.crossH,handles.crossI,handles.crossJ];

splinePath = get(handles.inputSplinePath,'String');

[~,ventralData,splineData,crossData] = parseSplineFile(splinePath);
size(ventralData)
res = parseSplineFileForRes(splinePath);
res

set(handles.inputSplinePath,'UserData',splineData);
set(handles.crossA,'UserData',crossData);
set(handles.resHolder,'UserData',res);
set(handles.ventralMessage,'UserData',ventralData);

topRow = get(handles.topRow,'Value');
updateBatchTrackFrames(handles,topRow);

disp('Loaded previously produced spline data');

set(swapHandles,'Enable','on');
set(manualHandles,'Enable','on');
set(crossHandles,'Enable','on');

function swap_Callback(hObject, eventdata, handles)

swapHandles = [handles.swapA,handles.swapB,handles.swapC,handles.swapD,handles.swapE,handles.swapF,handles.swapG,handles.swapH,handles.swapI,handles.swapJ];

splineData = get(handles.inputSplinePath,'UserData');
crossData = get(handles.crossA,'UserData');

frameMatrix = get(handles.frame,'UserData');
topRow = get(handles.topRow,'Value');
framesToDisplay = frameMatrix(topRow:topRow+1,:);

% FIND THE CURRENT FRAME OF THE AXES USING ITS HANDLE
currentFrameNumber = find(swapHandles==hObject);
currentFrameNumber = framesToDisplay(floor((currentFrameNumber-1)/5)+1,mod(currentFrameNumber-1,5)+1);

% FLIP L/R ORDER OF SPLINE AND CROSS ROWS FOR FRAMENUMBER'S X&Y ROWS AND
% ALL AFTER IT
splineData = [splineData(1:2*(currentFrameNumber-1),:);fliplr(splineData(2*currentFrameNumber-1:end,:))];
crossData = [crossData(1:2*(currentFrameNumber-1),:);fliplr(crossData(2*currentFrameNumber-1:end,:))];

set(handles.inputSplinePath,'UserData',splineData);
set(handles.crossA,'UserData',crossData);

updateBatchTrackFrames(handles,topRow);

function manual_Callback(hObject, eventdata, handles)

% USED IN CASE TOPROW WAS UPDATED RECENTLY
drawnow

topRow = get(handles.topRow,'Value');

% CALL MANUAL GUI AND UPDATE SPLINE DATA
callManualSpline(handles,hObject);

updateBatchTrackFrames(handles,topRow);

function cross_Callback(hObject, eventdata, handles)

crossHandles = [handles.crossA,handles.crossB,handles.crossC,handles.crossD,handles.crossE,handles.crossF,handles.crossG,handles.crossH,handles.crossI,handles.crossJ];

splineData = get(handles.inputSplinePath,'UserData');
crossData = get(handles.crossA,'UserData');

frameMatrix = get(handles.frame,'UserData');
topRow = get(handles.topRow,'Value');
framesToDisplay = frameMatrix(topRow:topRow+1,:);

% FIND THE CURRENT FRAME OF THE AXES USING ITS HANDLE
currentFrameNumber = find(crossHandles==hObject);
currentFrameNumber = framesToDisplay(floor((currentFrameNumber-1)/5)+1,mod(currentFrameNumber-1,5)+1);

% GET CORRESPONDING SPLINE AND CROSS ROWS FOR X&Y OF FRAME ROW
xSpline = splineData(2*currentFrameNumber-1,:); ySpline = splineData(2*currentFrameNumber,:);
xCrossSpline = crossData(2*currentFrameNumber-1,:); yCrossSpline = crossData(2*currentFrameNumber,:);

% SWAP CORRESPONDING SPLINE AND CROSS ROWS FOR X&Y OF FRAME ROW
newSplineData = [splineData(1:2*(currentFrameNumber-1),:);xCrossSpline;yCrossSpline;splineData(2*(currentFrameNumber+1)-1:end,:)];
newCrossData = [crossData(1:2*(currentFrameNumber-1),:);xSpline;ySpline;crossData(2*(currentFrameNumber+1)-1:end,:)];

% SAVE NEW SPLINE AND CROSS DATA
set(handles.inputSplinePath,'UserData',newSplineData);
set(handles.crossA,'UserData',newCrossData);

updateBatchTrackFrames(handles,topRow);

function pageUp_Callback(hObject, eventdata, handles)

frameMatrix = get(handles.frame,'UserData');
frameMatrixLength = length(frameMatrix(:,1));
topRow = str2double(get(handles.topRow,'String'));

if isnan(topRow)
    topRow = 2;
end

topRow = max(topRow-1,1);

set(handles.topRow,'Value',topRow,'String',num2str(topRow));

% ENABLE PAGE DOWN IF ROW HAS MOVED UP TO THE THIRD TO LAST ROW
if topRow == frameMatrixLength-2
    set(handles.pageDown,'Enable','on')
end

% DISABLE PAGE UP IF ROW HAS MOVED UP TO TOP ROW
if topRow==1
    set(handles.pageUp,'Enable','off')
end

updateBatchTrackFrames(handles,topRow);

function topRow_Callback(hObject, eventdata, handles)

drawnow

frameMatrix=get(handles.frame,'UserData');
numberOfRows = size(frameMatrix,1);

oldRowNumber = get(hObject,'Value');
input = str2double(get(hObject,'String'));

if input>numberOfRows-1 || input<=0 || isnan(input)
    
    pause(.2)
    flashBox('r',hObject);
    set(hObject,'String',num2str(oldRowNumber));
    
else
    
    topRow = input;
    pause(.2)
    flashBox('g',hObject);
    set(hObject,'Value',topRow)
    
    if topRow==numberOfRows-1
        set(handles.pageUp,'Enable','on');
        set(handles.pageDown,'Enable','off');
    elseif topRow==1
        set(handles.pageUp,'Enable','off');
        set(handles.pageDown,'Enable','on');
    else
        set(handles.pageUp,'Enable','on');
        set(handles.pageDown,'Enable','on');
    end
    
    updateBatchTrackFrames(handles,topRow);
    
end

function topRow_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pageDown_Callback(hObject, eventdata, handles)

frameMatrix = get(handles.frame,'UserData');
frameMatrixLength = length(frameMatrix(:,1));
topRow = str2double(get(handles.topRow,'String'));

if isnan(topRow)
    topRow = 0;
end

topRow = min(topRow+1,frameMatrixLength-1);

set(handles.topRow,'Value',topRow);
set(handles.topRow,'String',num2str(topRow));

% DISABLE PAGE DOWN IF ROW HAS MOVED DOWN TO SECOND TO LAST ROW
if topRow==frameMatrixLength-1
    set(handles.pageDown,'Enable','off')
end

% ENABLE PAGE UP IF ROW HAS MOVED DOWN TO SECOND ROW
if topRow==2
    set(handles.pageUp,'Enable','on')
end

updateBatchTrackFrames(handles,topRow);

function save_Callback(hObject, eventdata, handles)

defaultSavePath = get(hObject,'UserData');

[filename,pathname] = uiputfile('*.txt','Save spline data',defaultSavePath);
savePath = [pathname,filename];

if ~isnumeric(savePath)
    
    splineData = get(handles.inputSplinePath,'UserData');
    ventralData = get(handles.ventralMessage,'UserData');
    size(ventralData)
    crossData = get(handles.crossA,'UserData');
    res = get(handles.resHolder,'UserData');
    filelist = get(handles.imagePath,'UserData');
    
    res = repmat(fliplr(res(1:2))',[size(splineData,1)/2,1,1]);
    
%     DOUBLE THE VENTRAL DATA ARRAY TO ACCOMODATE EACH PAIR OF X/Y ROWS
    ventralData = repelem(ventralData',2);
    size(ventralData)

    
    frameNumbers = NaN([length(filelist),1]);
    
%     GET ORIGINAL FRAME NUMBER FROM EACH FILENAME
    for i=1:length(filelist)
        
        currentFrameNumber = strsplit(filelist{i},{'img','jpeg'});
        currentFrameNumber = currentFrameNumber{2};
        frameNumbers(i) = str2double(currentFrameNumber);
        
    end
    
    frameNumbers = repelem(frameNumbers,2);
    %size(frameNumbers)
    %size(ventralData)
    % size(splineData)
    % size(crossData)
    % size(res)
    data = [frameNumbers,ventralData ,splineData,crossData,res];
    labels = [{'%%FrameNumber'} {'%%Ventral'} {'%%Head'} {'%%2'} {'%%3'} {'%%4'} {'%%5'} {'%%6'} {'%%7'} {'%%8'} {'%%9'} {'%%10'} {'%%11'} {'%%12'} {'%%Tail'} {'%%Cross 1'} {'%%2'} {'%%3'} {'%%4'} {'%%5'} {'%%6'} {'%%7'} {'%%8'} {'%%9'} {'%%10'} {'%%11'} {'%%12'} {'%%13'} {'%%Res'}];
    

    disp('Saving data...');
    Save='Saving data...';
    set(handles.percentComplete,'String', Save);
    
%SAVE FRAMENUMBERS, VENTRAL DATA, SPLINE DATA, AND CROSS DATA
    saveDataMatrix(labels,data,savePath);
    
    disp('Data saved');
    Saved='Data saved';
    set(handles.percentComplete,'String', Saved);

    % Get the path to the temp folder
    imagePath = get(handles.imagePath,'String');
    tempFolder = fullfile(imagePath, 'resized_temp');

    % Check if it exists before trying to delete
    if exist(tempFolder, 'dir')
        rmdir(tempFolder, 's');  % 's' means delete subfolders and files
        disp('Temporary folder deleted successfully.');
    else
        disp('Temporary folder does not exist.');
    end

    
end

function splinePath_Callback(hObject, eventdata, handles)

function splinePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function figure1_WindowKeyPressFcn(hObject, eventdata, handles)

% ALLOWS SCROLLING VIA ARROW KEYS

if strcmp(eventdata.Key,'uparrow') && strcmp(get(handles.pageUp,'Enable'),'on')
    pageUp_Callback(handles.pageUp,[],handles);
elseif strcmp(eventdata.Key,'downarrow') && strcmp(get(handles.pageDown,'Enable'),'on')
    pageDown_Callback(handles.pageDown,[],handles);
end


% --- Executes during object creation, after setting all properties.
function resHolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resHolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function percentComplete_Callback(hObject, eventdata, handles)
% hObject    handle to percentComplete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of percentComplete as text
%        str2double(get(hObject,'String')) returns contents of percentComplete as a double


% --- Executes during object creation, after setting all properties.
function percentComplete_CreateFcn(hObject, eventdata, handles)
% hObject    handle to percentComplete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function percentComplete_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to percentComplete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ventralMessage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ventralMessage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % Access handles
    handles = guidata(hObject);

    % Get the imagePath from the handles
    if isfield(handles, 'imagePath')
        if ischar(get(handles.imagePath, 'String'))
            imagePath = get(handles.imagePath, 'String');
        else
            imagePath = get(handles.imagePath, 'UserData');
        end

        % Build the temp folder path
        tempFolder = fullfile(imagePath, 'resized_temp');

        % Delete if exists
        if exist(tempFolder, 'dir')
            try
                rmdir(tempFolder, 's');
                disp('Temporary folder deleted on GUI close.');
            catch ME
                warning('Failed to delete temp folder: %s', E.message);
            end
        end
    end

    % Then close the GUI
    delete(hObject);
