function varargout = batchSpline_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @batchSpline_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @batchSpline_gui_OutputFcn, ...
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

function batchSpline_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

function varargout = batchSpline_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function folderList_Callback(hObject, eventdata, handles)

rowNum = get(hObject,'Value');
folderData = get(hObject,'UserData');

% UPDATE THRESHOLD TO MATCH THAT OF SELECTED FOLDER
if rowNum
    set(handles.threshold,'String',num2str(folderData{rowNum,2}));   
end

function folderList_CreateFcn(hObject, eventdata, handles)
 set(hObject, 'Value', 1);

    % Update handles structure
    guidata(hObject, handles);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function imagePath_Callback(hObject, eventdata, handles)

function imagePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browse_Callback(hObject, eventdata, handles)

persistent pathname

if isnumeric(pathname)
    [pathname] = uigetdir(pwd,'Choose Jpeg Folder');
else
    [pathname] = uigetdir(pathname,'Choose Jpeg Folder');
end

if ~isnumeric(pathname)
    
    set(handles.add,'Enable','on');
    set(handles.imagePath,'String',pathname)
    
end

function add_Callback(hObject, eventdata, handles)

try
    
    imagePath = get(handles.imagePath,'String');
    savePath = [imagePath '_spline.txt'];
    
    threshold = str2double(get(handles.threshold,'String'));
    
%     CHECK IF FILE EXISTS AND PROMPT FOR OVERWRITE
    if exist(savePath,'file')
        
        choice = questdlg('Spline file for this recording already exists, overwrite?','Spline file overwrite confirmation','Overwrite','Cancel','Cancel');
        
        switch choice
            
            case 'Overwrite'
            case 'Cancel'
                return
                
        end
        
    end
    
%     FOLDER DATA CONTAINS THE PATH AND NUMERIC THRESHOLD FOR EACH FILE
    newFolderDataRow = [{imagePath},{threshold}];
    
%     PAD THRESHOLD STRING
    if threshold<100 && threshold>9
        threshold = ['0' num2str(threshold)];
    elseif threshold <10
        threshold = ['00' num2str(threshold)];
    else
        threshold = num2str(threshold);
    end
    
    summaryString = [imagePath ' THRESHOLD: ' threshold];
    
    folderList = get(handles.folderList,'String');
    folderData = get(handles.folderList,'UserData');

    folderList = [folderList;{summaryString}];
    folderData = [folderData;newFolderDataRow];
    
    rowNum = get(handles.folderList,'Value');
    
    if ~rowNum
        set(handles.folderList,'Value',1);
    end
    
    set(handles.folderList,'String',folderList,'UserData',folderData);
    set(handles.remove,'Enable','on');
    
catch
    
    disp('Error loading folder');
    
end

function analyze_Callback(hObject, eventdata, handles)

persistent prevX prevY

comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end

inBatchMode = 1;
clow = 0; chigh = 1;

folderData = get(handles.folderList,'UserData');

folderPathList = folderData(:,1);
thresholds = cell2mat(folderData(:,2));

disp('Folders:'); disp(folderPathList);
disp('Thresholds:'); disp(thresholds);
disp(length(folderPathList))
currentLine = get(handles.folderList, 'Value');
    
    

for i=1:length(folderPathList) 
    
    
    imagePath = folderPathList{i};
    
    threshold = thresholds(i);
    
    if i==1
        prevX=[]; prevY=[];
    end
    
    fixNumbers(imagePath);
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
    
    frameNumbers = NaN([length(fileList),1]);
    ventralData = zeros(1,length(fileList));
    splineData = zeros(2*length(fileList),13);
    
    
    for j=1:length(fileList)
        
        currentFile = fileList{j};
        
        lastSlash = find(currentFile==slash);
        lastSlash = lastSlash(end);
        
        currentFile = currentFile(lastSlash+1:end);
        
%         1 = RIGHT
        if strcmp(currentFile(1:2),'R_')
            ventralData(j)=1;
%         2 = LEFT
        elseif strcmp(currentFile(1:2),'L_')
            ventralData(j)=2;
        else
            ventralData(j)=0;
        end
        
        currentFrameNumber = strsplit(fileList{j},{'img','jpeg'});
        currentFrameNumber = currentFrameNumber{2};
        frameNumbers(j) = str2double(currentFrameNumber);
        
    end
    
    analysisLoop
    % Increment the current line or loop back to line one
    currentLine = currentLine + 1;
    set(handles.folderList, 'Value', currentLine);
    if currentLine > length(folderPathList)
        currentLine = 1;
    end
    
    % Set the selected item based on the updated current line
    set(handles.folderList, 'Value', currentLine);
    
    % Update handles structure
    guidata(hObject, handles);
    
    disp('Done Analyzing Frames')
    Done='Done Analyzing Frames';
    set(handles.percentComplete,'String',Done);
    ventralData = repelem(ventralData',2);
    frameNumbers = repelem(frameNumbers,2);
    res = repmat(fliplr(res(1:2))',[size(splineData,1)/2,1,1]);
    size(frameNumbers)
    size(ventralData)
    size(splineData)
    size(crossData)
    data = [frameNumbers,ventralData ,splineData,crossData,res];
    labels = [{'%%FrameNumber'} {'%%Ventral'} {'%%Head'} {'%%2'} {'%%3'} {'%%4'} {'%%5'} {'%%6'} {'%%7'} {'%%8'} {'%%9'} {'%%10'} {'%%11'} {'%%12'} {'%%Tail'} {'%%Cross 1'} {'%%2'} {'%%3'} {'%%4'} {'%%5'} {'%%6'} {'%%7'} {'%%8'} {'%%9'} {'%%10'} {'%%11'} {'%%12'} {'%%13'} {'%%Res'}];

    savePath = [imagePath '_spline.txt'];
    
    disp('Saving data...');
    
    saveDataMatrix(labels,data,savePath);
    
    disp(['Successfully saved data to: ' savePath]); fprintf('\n\n\n')

    % Check if it exists before trying to delete
    if exist(tempFolder, 'dir')
        rmdir(tempFolder, 's');  % 's' means delete subfolders and files
        disp('Temporary folder deleted successfully.');
    else
        disp('Temporary folder does not exist.');
    end

    
end

function remove_Callback(hObject, eventdata, handles)

folderList = get(handles.folderList,'String');
folderData = get(handles.folderList,'UserData');
rowNum = get(handles.folderList,'Value');

% CHOSE ROW TO LEAVE SELECTED AFTER REMOVING CURRENT ONE
if rowNum==1 && length(folderList)==1
    newRowNum = 0;
elseif rowNum==length(folderList)
    newRowNum = rowNum-1;
else
    newRowNum =  rowNum;
end

if rowNum~=0
    
    folderList = [folderList(1:rowNum-1);folderList(rowNum+1:end)];
    folderData = [folderData(1:rowNum-1,:);folderData(rowNum+1:end,:)];
    
    set(handles.folderList,'String',folderList,'UserData',folderData,'Value',newRowNum);
    
    if ~newRowNum
        set(hObject,'Enable','off');
    end
    
end

function threshold_Callback(hObject, eventdata, handles)

function threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setThreshold_Callback(hObject, eventdata, handles)

rowNum = get(handles.folderList,'Value');
folderList = get(handles.folderList,'String');
folderData = get(handles.folderList,'UserData');

thresholds = folderData(:,2);
paths = folderData(:,1);

newThreshold = str2double(get(handles.threshold,'String'));

if ~isnan(newThreshold) && rowNum
    thresholds(rowNum) = {newThreshold};  
end

folderData = [folderData(:,1) thresholds];
summaryString = [paths{rowNum} ' T~ ' num2str(newThreshold)];

set(handles.folderList,'String',[folderList(1:rowNum-1);{summaryString};folderList(rowNum+1:end)],'UserData',folderData);



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


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

% Hint: delete(hObject) closes the figure
delete(hObject);
