function varargout = playback_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @playback_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @playback_gui_OutputFcn, ...
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

function playback_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

function varargout = playback_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function prevFrame_Callback(hObject, eventdata, handles)
set(handles.nextFrame,'Enable','on');
currentFrameNumber = get(handles.currentFrameNumber,'Value');

% DECREASE FRAME NUMBER IF NOT ONE
currentFrameNumber= max(currentFrameNumber-1,1);

if currentFrameNumber==1
    set(hObject,'Enable','off');
    set(handles.nextFrame,'Enable','on');
end
sVal = get(handles.slider1,'Value');
set(handles.slider1,'Value',sVal-1);

updatePlaybackFrame(currentFrameNumber,handles);

function pause_Callback(hObject, eventdata, handles)

% CHANGE OBJECT USERDATA AND ENABLE FRAME STEPPING
set(hObject,'UserData',1);
drawnow;
set(handles.prevFrame,'Enable','on');
set(handles.nextFrame,'Enable','on');
set(handles.currentFrameNumber,'Enable','on');
set(handles.slider1,'Enable','on');
currentFrameNumber = get(handles.currentFrameNumber,'Value');
sVal = get(handles.slider1,'Value');
set(handles.slider1,'Value',currentFrameNumber);

function play_Callback(hObject, eventdata, handles)

% ENABLE PAUSE, DISABLE FRAME STEPPING AND PLAY
set(handles.pause,'UserData',0);
drawnow;
set(handles.prevFrame,'Enable','off');
set(handles.nextFrame,'Enable','off');
set(handles.pause,'Enable','on');
set(handles.slider1,'Enable','on');
set(hObject,'Enable','off');
set(handles.currentFrameNumber,'Enable','off');

% GET FILE DATA
currentFrameNumber = get(handles.currentFrameNumber,'Value');
framerate = str2double(get(handles.movieFPS,'String'));
% framerate = get(handles.framerateOptions,'UserData');
fileList = get(handles.frame,'UserData');

totalNumberOfFrames = length(fileList);

% IF RECORDING HAS BEEN PLAYED TO THE END BEFORE BE KIND, REWIND
if currentFrameNumber==totalNumberOfFrames
    
    currentFrameNumber = 1;
    updatePlaybackFrame(currentFrameNumber,handles)
    
end

% INCREASE FRAME EVERY 1/framerate SECONDS
while currentFrameNumber<=totalNumberOfFrames && ~get(handles.pause,'UserData')
    
   if framerate == 1
      updatePlaybackFrame(currentFrameNumber,handles);
      currentFrameNumber = currentFrameNumber+1;
      pause(1);
   else
       updatePlaybackFrame(currentFrameNumber,handles);
       currentFrameNumber = currentFrameNumber+1;
       pause(1/framerate);
   end
   drawnow;
    
end

% ENABLE PLAY AND FRAME STEPPING, DISABLE PAUSE
set(hObject,'Enable','on');
set(handles.pause,'Enable','off');
set(handles.currentFrameNumber,'Enable','on');
set(handles.prevFrame,'Enable','on');

function nextFrame_Callback(hObject, eventdata, handles)
set(handles.prevFrame,'Enable','on');

currentFrameNumber = get(handles.currentFrameNumber,'Value');
fileList = get(handles.frame,'UserData');

% INCREASE FRAME NUMBER IF NOT AT THE END
currentFrameNumber = min(currentFrameNumber+1,length(fileList));

if currentFrameNumber==length(fileList)
    set(hObject,'Enable','off');
end
sVal = get(handles.slider1,'Value');
set(handles.slider1,'Value',sVal+1);
updatePlaybackFrame(currentFrameNumber,handles);


function imagePath_Callback(hObject, eventdata, handles)

comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end

drawnow

imagePath = get(hObject,'String');

if exist(imagePath,'dir')

%     ATTEMT TO GENERATE SPLINE AND MOVIE PATHS
    splinePath = [imagePath '_spline.txt'];
    moviePath = [imagePath ' _movie.avi'];
    
    lastSlash = find(imagePath==slash);
    lastSlash = lastSlash(end);
    
%     ATTEMPT TO GENERATE TIMES FILE
    timesPath = [imagePath slash imagePath(lastSlash+1:end) '_times.txt'];
    
%     SAVE PATHS IN HANDLES' USERDATA
    set(handles.imagePath,'String',imagePath);
    set(handles.exportMovie,'UserData',moviePath);
    set(handles.load,'Enable','on');
    
%     NOTE THAT IMAGE FOLDER HAS BEEN FOUND
    filesDetected = get(handles.load,'UserData');
    filesDetected(1) = 1;

%     ALLOW SPLINE TO BE ADDED IF EXISTENT
    if exist(splinePath,'file')
        
        set(handles.splinePath,'String',splinePath);
        set(handles.loadSpline,'Enable','on');
        foundSpline = 1;
        
    else
        
        set(handles.showSplines,'Enable','off','Value',0);
        set(handles.splinePath,'String','Enter spline path');
        disp('No spline file automatically detected');
        foundSpline = 0;
        
    end
    
%     NOTE THAT TIMES FILE HAS BEEN FOUND
    if exist(timesPath,'file')
        
        set(handles.timesPath,'String',timesPath);
        set(handles.reduceFramerate,'Enable','off');
        filesDetected(2) = 1;
        
    else
        
        set(handles.timesPath,'String','Enter times file');
        disp('No times file automatically detected');
        
    end
    
    set(handles.load,'UserData',filesDetected);
    
%     IF BOTH FOUND, ALLOW LOADING
    if all(filesDetected)
        set(handles.load,'Enable','on');
    else
        set(handles.load,'Enable','off');
    end
    
    if filesDetected(2) && foundSpline
        
        flashBox('g',hObject,handles.splinePath,handles.timesPath);
        
    elseif filesDetected(2)
        
        flashBox('g',hObject,handles.timesPath,'r',handles.splinePath);
        
    elseif foundSpline
        
        flashBox('g',hObject,handles.splinePath,'r',handles.timesPath);
        
    else
        
        flashBox('g',hObject,'r',handles.splinePath,handles.timesPath);
        
    end
    
else
    
    flashBox('r',hObject);
    
end

function imagePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browse_Callback(hObject, eventdata, handles)

persistent lastImagePath

comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end

if isempty(lastImagePath)   
    imagePath = uigetdir();   
else  
    imagePath = uigetdir(lastImagePath);
end

if ~isnumeric(imagePath)
    
%     ATTEMT TO GENERATE SPLINE AND MOVIE PATHS
    splinePath = [imagePath '_spline.txt'];
    moviePath = [imagePath ' _movie.avi'];
    
    lastSlash = find(imagePath==slash);
    lastSlash = lastSlash(end);
    
%     ATTEMPT TO GENERATE TIMES FILE
    timesPath = [imagePath slash imagePath(lastSlash+1:end) '_times.txt'];
    
%     SAVE PATHS IN HANDLES' USERDATA
    set(handles.imagePath,'String',imagePath);
    set(handles.exportMovie,'UserData',moviePath);
    set(handles.load,'Enable','on');
    
%     NOTE THAT IMAGE FOLDER HAS BEEN FOUND
    filesDetected = get(handles.load,'UserData');
    filesDetected(1) = 1;

    lastImagePath = imagePath;
    
%     ALLOW SPLINE TO BE ADDED IF EXISTENT
    if exist(splinePath,'file')
        
        set(handles.splinePath,'String',splinePath);
        set(handles.loadSpline,'Enable','on');
        
    else
        
        set(handles.showSplines,'Enable','off','Value',0);
        set(handles.splinePath,'String','Enter spline path');
        disp('No spline file automatically detected');
        
    end
    
%     NOTE THAT TIMES FILE HAS BEEN FOUND
    if exist(timesPath,'file')
        
        set(handles.timesPath,'String',timesPath);
        set(handles.reduceFramerate,'Enable','off');
        filesDetected(2) = 1;
        
    else
        
        set(handles.timesPath,'String','Enter times file');
        disp('No times file automatically detected');
        
    end
    
    set(handles.load,'UserData',filesDetected);
    
%     IF BOTH FOUND, ALLOW LOADING
    if all(filesDetected)
        set(handles.load,'Enable','on');
    end
    
end

function load_Callback(hObject, eventdata, handles)

imagePath = get(handles.imagePath,'String');
timesPath = get(handles.timesPath,'String');
timesData = importdata(timesPath);
timesData=timesData.data;

fixNumbers(imagePath);

fileList = listJpegsInFolder(imagePath);
totalNumberOfFrames = length(fileList);
set(handles.timesPath,'UserData',timesPath);

% FACTOR FRAMERATE TO ALLOW DECREASES

[~,framerate] = parseTimesFile(timesPath);

if framerate==15
    framerateFactors = [1,3,5];
    framerateFactors = num2cell(unique(framerateFactors));
elseif framerate==5
    framerateFactors=[1,3];
    framerateFactors = num2cell(unique(framerateFactors));
elseif framerate==3
    framerateFactors=[1];
    framerateFactors = num2cell(unique(framerateFactors));
elseif framerate==1
    framerateFactors='-';
    framerateFactors = cellstr(unique(framerateFactors));
end

    set(handles.movieFPS,'Value',framerate,'String',num2str(framerate));
    
    framerateStrings = cellfun(@num2str,framerateFactors,'UniformOutput',false);

% SAVE LIST OF IMAGES IN frame USERDATA
set(handles.frame,'UserData',fileList);

% SAVE FRAMERATE FACTORS
%if length(framerateFactors)>1
if size(timesData,2)==2
    
    set(handles.framerateOptions,'String',framerateStrings,'UserData',framerate,'Value',1);
    set(handles.reduceFramerate,'Enable','on');
    set(handles.restoreFramerate,'Enable','off');

    
else
    
    set(handles.framerateOptions,'String',{'-'},'UserData',[],'Value',1,'Enable','on');
    set(handles.reduceFramerate,'Enable','off');
    set(handles.restoreFramerate,'Enable','on');
  
end
 
%  set(handles.restorecut,'Enable','on');

 
%originalTimesPath = [timesPath(1:end-4) '_original.txt'];

% if exist(originalTimesPath,'file')
%     set(handles.restoreFramerate,'Enable','on');
% else
%     set(handles.restoreFramerate,'Enable','off');
% end

% SET FRAME COUNT
set(handles.totalNumberOfFrames,'String',['/ ' num2str(totalNumberOfFrames)]);

% SET DEFAULT VALUES OF START AND END CUT AND MOVIE FRAMES
% set(handles.newBeginFrame,'Value',1,'String','1');
% set(handles.newEndFrame,'Value',totalNumberOfFrames,'String',num2str(totalNumberOfFrames));
set(handles.movieBeginFrame,'Value',1,'String','1');
set(handles.movieEndFrame,'Value',totalNumberOfFrames,'String',num2str(totalNumberOfFrames));


set(handles.exportMovie,'Enable','on');
% set(handles.cut,'Enable','on');

% SET DEFAUT PLAY/PAUSE AND FRAME SKIPPING
set(handles.prevFrame,'Enable','off');
set(handles.nextFrame,'Enable','on');
set(handles.play,'Enable','on');
set(handles.pause,'Enable','off');
set(handles.slider1,'Enable','on');
set(handles.currentFrameNumber,'Value',1,'String','1');
updatePlaybackFrame(1,handles)
totalNumberOfFrames = length(fileList);
count = floor(get(handles.slider1,'Value'));
imageFile = fileList{count};
current = imread(imageFile);

low = min(min(current));
high = max(max(current));
imshow(current,[low,high],'Parent',handles.win);
axis(handles.win, 'image');
%imshow(current,[low,high],'Parent',ax, 'InitialMagnification','fit');
% database=[];
% for ii=1:totalNumberOfFrames
%    currentfilename= char(fileList(ii));
%    currentimage = imread(currentfilename);
%    database(:,:,ii) = currentimage;
% end
N_images=totalNumberOfFrames;
set(handles.framerateOptions,'Enable','on');
set(handles.slider1,'Min',1,'Max',N_images,'SliderStep',[1/(N_images-1) 0.04]);


function timesPath_Callback(hObject, eventdata, handles)

filesDetected = get(handles.load,'UserData');

if exist(get(hObject,'String'),'file')
    
%     NOTE THAT TIMES FILE HAS BEEN FOUND
    filesDetected(2) = 1;

    set(handles.load,'UserData',filesDetected);
    
%     IF BOTH FILES 
    if all(filesDetected)
        set(handles.load,'Enable','on');
    else
        set(handles.load,'Enable','off');
    end
    
    flashBox('g',hObject);
    
else
    
    filesDetected(2) = 0;
    
    flashBox('r',hObject);
    
    set(handles.load,'Enable','off','UserData',filesDetected);
    
end

function timesPath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseTimes_Callback(hObject, eventdata, handles)

persistent lastTimesPath

if isempty(lastTimesPath)   
    timesPath = uigetdir();   
else  
    timesPath = uigetdir(lastTimesPath);
end

filesDetected = get(handles.load,'UserData');

if ~isnumeric(lastTimesPath)
    
    set(handles.imagePath,'String',timesPath);
    
%     NOTE THAT TIMES FILE HAS BEEN FOUND
    filesDetected(2) = 1;

    lastTimesPath = timesPath;

    set(handles.load,'UserData',filesDetected);
    
%     IF BOTH FILES 
    if all(filesDetected)
        set(handles.load,'Enable','on');
    end

end

function currentFrameNumber_Callback(hObject, eventdata, handles)

drawnow

fileList =get(handles.frame,'UserData');
totalNumberOfFrames = length(fileList);

oldCurrentFrameNumber = get(hObject,'Value');
input = floor(str2double(get(hObject,'String')));

if input>totalNumberOfFrames || input<=0 || isnan(input)
    
    pause(.2)
    flashBox('r',hObject);
    set(hObject,'String',num2str(oldCurrentFrameNumber));
    
else
    
    currentFrameNumber = input;
    pause(.2)
    flashBox('g',hObject);
    set(hObject,'Value',currentFrameNumber)
    
    updatePlaybackFrame(currentFrameNumber,handles);
    
end

function currentFrameNumber_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function threshold_Callback(hObject, eventdata, handles)

function threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function showThresh_Callback(hObject, eventdata, handles)

function splinePath_Callback(hObject, eventdata, handles)

if exist(get(hObject,'String'),'file')
    
    filesDetected = get(handles.load,'UserData');
    
%     NOTE THAT TIMES FILE HAS BEEN FOUND
    filesDetected(1) = 1;

    set(handles.load,'UserData',filesDetected);
    
%     IF BOTH FILES 
    if all(filesDetected)
        set(handles.load,'Enable','on');
    else
        set(handles.load,'Enable','off');
    end
    
else
    
    flashBox('r',hObject);
    
end

function splinePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseSpline_Callback(hObject, eventdata, handles)

function loadSpline_Callback(hObject, eventdata, handles)

splinePath = get(handles.splinePath,'String');
fileList = get(handles.frame,'UserData');

if ~isempty(splinePath)
    
    try
%         ATTEMPT TO RETRIEVE SPLINE DATA
        [~,~,splineData,~] = parseSplineFile(splinePath);
        
        set(handles.splinePath,'UserData',splineData);
        set(handles.showSplines,'Enable','on','Value',1);
        
%         CHECK THAT THE LENGTH OF THE SPLINE FILE IS EQUAL TO THE NUMBER
%         OF IMAGE FILES
        assert(length(splineData)/2==length(fileList));
        disp('Spline File Loaded')
     
    catch
        
        set(handles.showSplines,'Enable','off','Value',0);
        disp('Error loading spline file -- file is invalid or lengths do not match');
        
    end
    
end
currentFrameNumber = get(handles.currentFrameNumber,'Value');
 updatePlaybackFrame(currentFrameNumber,handles)

function showSplines_Callback(hObject, eventdata, handles)

% function newBeginFrame_Callback(hObject, eventdata, handles)

% drawnow
% 
% fileList =get(handles.frame,'UserData');
% totalNumberOfFrames = length(fileList);
% 
% oldNewBeginFrame = get(hObject,'Value');
% input = floor(str2double(get(hObject,'String')));
% 
% % CHECK THAT THE BEGINNING FRAME IS INVALID
% if input>totalNumberOfFrames || input<=0 || isnan(input)
%     
%     pause(.2)
%     flashBox('r',hObject);
%     set(hObject,'String',num2str(oldNewBeginFrame));
%    
% % OTHERWISE SET NEW VALUE AND ENABLE CUTTING IF LESS THAN END FRAME
% else
%     
%     newBeginFrame = input;
%     pause(.2)
%     flashBox('g',hObject);
%     set(hObject,'Value',newBeginFrame)
%     
%     newEndFrame = get(handles.newEndFrame,'Value');
%     
%     if newBeginFrame>=newEndFrame
%         set(handles.cut,'Enable','off');
%     else
%         set(handles.cut,'Enable','on');
%     end
%     
% end
% 
% function newBeginFrame_CreateFcn(hObject, eventdata, handles)
% 
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% function newEndFrame_Callback(hObject, eventdata, handles)
% 
% drawnow
% 
% fileList =get(handles.frame,'UserData');
% totalNumberOfFrames = length(fileList);
% 
% oldNewEndFrame = get(hObject,'Value');
% input = floor(str2double(get(hObject,'String')));
% 
% % CHECK THAT END FRAME IS INVALID
% if input>totalNumberOfFrames || input<=0 || isnan(input)
%     
%     pause(.2)
%     flashBox('r',hObject);
%     set(hObject,'String',num2str(oldNewEndFrame));
%  
% % OTHERWISE SET NEW VALUE AND ENABLE CUTTING IF GREATER THAN BEGINNING
% % FRAME
% else
%     
%     newEndFrame = input;
%     pause(.2)
%     flashBox('g',hObject);
%     set(hObject,'Value',newEndFrame)
%         
%     newBeginFrame = get(handles.newBeginFrame,'Value');
%     
%     if newBeginFrame>=newEndFrame
%         set(handles.cut,'Enable','off');
%     else
%         set(handles.cut,'Enable','on');
%     end
%         
% end
% 
% function newEndFrame_CreateFcn(hObject, eventdata, handles)
% 
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% function cut_Callback(hObject, eventdata, handles)

% comp=computer;
% if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
%     slash='/';
% else
%     slash='\';
% end
% 
% fileList = get(handles.frame,'UserData');
% newBeginFrame = get(handles.newBeginFrame,'Value');
% newEndFrame = get(handles.newEndFrame,'Value');
% imagePath = get(handles.imagePath,'String');
% timesPath = get(handles.timesPath,'String');
% splinePath= get(handles.splinePath,'String');
% 
% [pathstr, times_name, ext]= fileparts(timesPath);
% originalFileNameTimes = strcat(times_name,'_original');
% originalSavePathTimes = [imagePath slash strcat(originalFileNameTimes,'.txt')]; 
% newSavePathTimes = [imagePath slash strcat(times_name,'.txt')];
% 
% [pathstrs, spline_name, ext]= fileparts(splinePath);
% originalFileNameSpline = strcat(spline_name,'_before_CF');
% originalSavePathSpline = [pathstrs slash strcat(originalFileNameSpline,'.txt')];
% newSavePathSpline = [pathstrs slash strcat(spline_name,'.txt')];
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% stagePath= regexp(imagePath,"\",'split'); % Parse File path into a 1x5 cell array
% stageFileName= stagePath{size(stagePath,2)}; % Extract the last element of the cell array
% stagePath= [imagePath slash strcat(stageFileName,'.txt')]; % Concat FileName with Full Path and Passed into importdata
% originalFileNameStage =  strcat(stageFileName,'_original');
% originalSavePathStage= [imagePath slash strcat(originalFileNameStage,'.txt')];
% 
% 
% 
% % CREATE 'REMOVED' FOLDER IN IMAGE FOLDER
% removedFolder = [imagePath slash 'removed_CF'];
% 
% mkdir(removedFolder);
% 
% % CREATE LIST OF FILES OUTSIDE OF BEGIN AND END FRAME
% frameFilesToCut = [fileList(1:newBeginFrame-1);fileList(newEndFrame+1:end)];
% 
% 
% 
% % MOVE FILES IN LIST
% for i=1:length(frameFilesToCut)
%     movefile(frameFilesToCut{i},removedFolder)
% end
% 
% %UPDATE TIMES FILE
%  time_files= importdata(timesPath);
%  time_files=time_files.data;
% 
%  %time_files=time_files(:,1:2:end)
%  time_files_1= table(time_files,'VariableNames',{'a'});
%  time_files_1= splitvars(time_files_1);
%  time_files_1.Properties.VariableNames={'current_t','framerate'};
%  writetable(time_files_1,originalSavePathTimes,'WriteVariableNames',true);
%  
%  
%  New_data=time_files(newBeginFrame:newEndFrame,:);
%  New_data= table(New_data,'VariableNames',{'a'});
%  New_data= splitvars(New_data);
%  New_data.Properties.VariableNames={'current_t','framerate'};
%  writetable(New_data,newSavePathTimes,'WriteVariableNames',true);
% 
% %UPDATE SPLINE FILE
% splineData= importdata(splinePath);
% splineData= splineData.data;
% %size(splineData)
% spline_files_1= table(splineData,'VariableNames',{'a'});
% spline_files_1= splitvars(spline_files_1);
% spline_files_1.Properties.VariableNames={'Frame','Number','Ventral','VentralY','Head','2','3','4','5','6','7','8','9','10','11','12','Tail','Cross','1a','2a','3a','4a','5a','6a','7a','8a','9a','10a','11a'};
% writetable(spline_files_1,originalSavePathSpline,'WriteVariableNames',true)
% 
%  New_data_spline_x = splineData(1:2:end,:);
%  New_data_spline_y = splineData(2:2:end,:);
%  New_data_spline_x=New_data_spline_x(newBeginFrame:newEndFrame,:);
%  New_data_spline_y = New_data_spline_y(newBeginFrame:newEndFrame,:);
%  %New_data_spline_x = New_data_spline_x(1+length(frameFilesToCut):(size(splineData,1)/2),:);
%  %New_data_spline_y = New_data_spline_y(1+length(frameFilesToCut):(size(splineData,1)/2),:);
%  New_data_spline = cat(1,New_data_spline_x,New_data_spline_y);
%  New_data_spline = sortrows(New_data_spline,1);
% New_data_spline= table(New_data_spline,'VariableNames',{'a'});
% New_data_spline= splitvars(New_data_spline);
% New_data_spline.Properties.VariableNames={'Frame','Number','Ventral','VentralY','Head','2','3','4','5','6','7','8','9','10','11','12','Tail','Cross','1a','2a','3a','4a','5a','6a','7a','8a','9a','10a','11a'};
% writetable(New_data_spline,newSavePathSpline,'WriteVariableNames',true);
% 
% %UPDATE STAGE FILE
% stage_files= importdata(stagePath);
% stage_files=stage_files.data;
% stage_files_1= table(stage_files,'VariableNames',{'a'});
% stage_files_1= splitvars(stage_files_1);
% stage_files_1.Properties.VariableNames={'delta_x','delta_y','calib_factor'};
% writetable(stage_files_1,originalSavePathStage,'WriteVariableNames',true);
% 
% New_data_stage= stage_files(1+fix(length(frameFilesToCut)/15):size(stage_files,1),:);
% New_data_stage= table(New_data_stage,'VariableNames',{'a'});
% New_data_stage= splitvars(New_data_stage);
% New_data_stage.Properties.VariableNames={'delta_x','delta_y','calib_factor'};
% writetable(New_data_stage,stagePath,'WriteVariableNames',true);
%  
%  
% % RELOAD REMAINING IMAGES FROM FOLDER
% load_Callback(handles.load,[],handles);
% 
% disp('Cutting Done')
%  set(handles.restorecut,'Enable','on');
%  set(handles.cut,'Enable','off');
%  set(handles.newBeginFrame,'Enable','off');
%  set(handles.newEndFrame,'Enable','off');

function framerateOptions_Callback(hObject, eventdata, handles)

function framerateOptions_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function reduceFramerate_Callback(hObject, eventdata, handles)
%set(handles.restoreFramerate,'Enable','on');
comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end

fileList = get(handles.frame,'UserData');
imagePath = get(handles.imagePath,'String');
timesPath = get(handles.timesPath,'UserData');
% splinePath= get(handles.splinePath,'String');

[pathstr, times_name, ext]= fileparts(timesPath);
originalFileNameTimes = strcat(times_name,'_before_RF');
originalSavePathTimes = [imagePath slash strcat(originalFileNameTimes,'.txt')];
newSavePathTimes = [imagePath slash strcat(times_name,'.txt')];


% [pathstrs, spline_name, ext]= fileparts(splinePath);
% originalFileNameSpline = strcat(spline_name,'_before_RF');
% originalSavePathSpline = [pathstrs slash strcat(originalFileNameSpline,'.txt')];
% newSavePathSpline = [pathstrs slash strcat(spline_name,'.txt')];

framerateOptions = get(handles.framerateOptions,'String');
% OriginalRate(framerateOptions);
newFramerate = get(handles.framerateOptions,'Value');
oldFramerate = get(handles.framerateOptions,'UserData');

%timesLabels =[{'%%current-t'} {'%%framerate'}];
%timesData = load(timesPath);
timesData= importdata(timesPath);
timesData= timesData.data;
% class(timesData)
% T=height(timesData)
% empty=cell(height(timesData),1);
% timesData=table(timesData,empty)
time_files_1= table(timesData,'VariableNames',{'a'});
time_files_1= splitvars(time_files_1);
time_files_1.Properties.VariableNames={'current_t','framerate'};
writetable(time_files_1,originalSavePathTimes,'WriteVariableNames',true);

% splineData= importdata(splinePath);
% splineData= splineData.data;
% size(splineData)
% spline_files_1= table(splineData,'VariableNames',{'a'});
% spline_files_1= splitvars(spline_files_1);
% spline_files_1.Properties.VariableNames={'Frame','Number','Ventral','VentralY','Head','2','3','4','5','6','7','8','9','10','11','12','Tail','Cross','1a','2a','3a','4a','5a','6a','7a','8a','9a','10a','11a'};
% writetable(spline_files_1,originalSavePathSpline,'WriteVariableNames',true)
%newTimesPath = [timesPath(1:end-4) '_original.txt'];

%if ~exist(newTimesPath,'file')
    %saveDataMatrix(timesLabels,timesData,newTimesPath);
%end

%[times,~] = parseTimesFile(timesPath);

%newTimesData = [times,newFramerate*ones(size(times))];

%saveDataMatrix(timesLabels,newTimesData,timesPath);

% frameSkip IS RECIPRICAL OF NEW FRAMERATE
newFramerate = str2double(framerateOptions{newFramerate});
frameSkip = oldFramerate/newFramerate;



set(hObject,'UserData',newFramerate);

% SET NEW FILELIST AS EACH FRAME IN INTERVALS OF frameSkip
newFileList = fileList(1:frameSkip:end);

% CREATE 'REMOVED' FOLDER IN IMAGE FOLDER
removedFolder = [imagePath slash 'Removed'];

mkdir(removedFolder);

% SET CUT LIST AS THE DIFFERENCE BETWEEN OLD AND NEW LIST OF FILE NAMES
frameFilesToCut = setdiff(fileList,newFileList);

% MOVE CUT LIST FILES TO REMOVED FOLDER
for i=1:length(frameFilesToCut)
    movefile(frameFilesToCut{i},removedFolder)
end
%Updated Times file

if oldFramerate==15
    New_data = timesData(1:frameSkip:end,:);
    New_data(:,2)= oldFramerate;
    New_data(:,3)= newFramerate;
    New_data= table(New_data,'VariableNames',{'a'});
    New_data= splitvars(New_data);
    New_data.Properties.VariableNames={'current_t','framerate','reducedframerate'};
    writetable(New_data,newSavePathTimes,'WriteVariableNames',true);  
elseif oldFramerate==5||oldFramerate==1||oldFramerate==3
   New_data = timesData(1:frameSkip:end,:);
    New_data(:,3)= oldFramerate;
    New_data(:,2)= newFramerate;
    New_data= table(New_data,'VariableNames',{'a'});
    New_data= splitvars(New_data);
    New_data.Properties.VariableNames={'current_t','reducedframerate','framerate'};
    writetable(New_data,newSavePathTimes,'WriteVariableNames',true);
end


% New_data = timesData(1:frameSkip:end,:);
% New_data(:,2)= newFramerate;
% New_data= table(New_data,'VariableNames',{'a'});
% New_data= splitvars(New_data);
% New_data.Properties.VariableNames={'current_t','framerate'};
% writetable(New_data,newSavePathTimes,'WriteVariableNames',true);

%  New_data_spline_x = splineData(1:2:end,:);
%  New_data_spline_y = splineData(2:2:end,:);
%  New_data_spline_x = New_data_spline_x((1:frameSkip:end),:);
%  New_data_spline_y = New_data_spline_y((1:frameSkip:end),:);
%  New_data_spline = cat(1,New_data_spline_x,New_data_spline_y);
%  New_data_spline = sortrows(New_data_spline,1);
% New_data_spline= table(New_data_spline,'VariableNames',{'a'});
% New_data_spline= splitvars(New_data_spline);
% New_data_spline.Properties.VariableNames={'Frame','Number','Ventral','VentralY','Head','2','3','4','5','6','7','8','9','10','11','12','Tail','Cross','1a','2a','3a','4a','5a','6a','7a','8a','9a','10a','11a'};
% writetable(New_data_spline,newSavePathSpline,'WriteVariableNames',true);


load_Callback(handles.load,[],handles);
% loadSpline_Callback(handles.loadSpline,[],handles)
set(handles.restoreFramerate,'Enable','on');
set(handles.reduceFramerate,'Enable','off');
set(handles.framerateOptions,'Enable','off');
set(handles.movieFPS,'Value',newFramerate,'String',num2str(newFramerate));
% set(handles.cut,'Enable','off');
% set(handles.newBeginFrame,'Enable','off');
% set(handles.newEndFrame,'Enable','off');

function restoreFramerate_Callback(hObject, eventdata, handles)
%set(handles.restoreFramerate, 'Enable', 'on');
comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end
timesPath = get(handles.timesPath,'String');
imagePath = get(handles.imagePath,'String');
% splinePath= get(handles.splinePath,'String');

beforeRFtimespath = [timesPath(1:end-4) '_before_RF.txt'];
% beforeRFsplinepath = [splinePath(1:end-4) '_before_RF.txt'];
%originalTimesPath = [timesPath(1:end-4) '_original.txt'];
removedFolder = [imagePath slash 'Removed'];
%delete timesPath;

%movefile(originalTimespath ,timesPath);
movefile(beforeRFtimespath ,timesPath);
% movefile(beforeRFsplinepath ,splinePath);


disp('Done Replacing Times File!')
if exist(removedFolder,'dir')
    
    %removedFilesList = listBmpsInFolder(removedFolder);
    filenames =dir(fullfile(removedFolder, '*jpeg'));
    removedFileList = fullfile(removedFolder,{filenames.name});
    
    
    for i=1:length(removedFileList)
        movefile(char(removedFileList(i)), imagePath);
    end
    rmdir(removedFolder);
end
%if length(framerateFactors)=1
    
%     set(handles.framerateOptions,'Enable','on');
%     set(handles.reduceFramerate,'Enable','on');

    
%else
    
    %set(handles.framerateOptions,'String',{'-'},'UserData',[],'Value',1,'Enable','off');
    %set(handles.reduceFramerate,'Enable','off');


load_Callback(handles.load,[],handles);
%loadSpline_Callback(handles.loadSpline,[],handles)
%set(handles.restoreFramerate,'Enable','off');
set(handles.reduceFramerate,'Enable','on');  
set(handles.framerateOptions,'Enable','on');
% set(handles.cut,'Enable','on');
% set(handles.newBeginFrame,'Enable','on');
% set(handles.newEndFrame,'Enable','on');

function movieBeginFrame_Callback(hObject, eventdata, handles)

drawnow

fileList =get(handles.frame,'UserData');
totalNumberOfFrames = length(fileList);

oldMovieBeginFrame = get(hObject,'Value');
input = floor(str2double(get(hObject,'String')));

% CHECK THAT BEGINNING FRAME IS INVALID
if input>totalNumberOfFrames || input<=0 || isnan(input)
    
    pause(.2)
    flashBox('r',hObject);
    set(hObject,'String',num2str(oldMovieBeginFrame));
    
% OTHERWISE SET NEW VALUE AND ENABLE EXPORTING IF LESS THAN END FRAME
else
    
    movieBeginFrame = input;
    pause(.2)
    flashBox('g',hObject);
    set(hObject,'Value',movieBeginFrame)
    
    movieEndFrame = get(handles.movieEndFrame,'Value');
    
    if movieBeginFrame>=movieEndFrame
        set(handles.exportMovie,'Enable','off');
    else
        set(handles.exportMovie,'Enable','on');
    end
    
end

function movieBeginFrame_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function movieEndFrame_Callback(hObject, eventdata, handles)

drawnow

fileList = get(handles.frame,'UserData');
totalNumberOfFrames = length(fileList);

oldMovieEndFrame = get(hObject,'Value');
input = floor(str2double(get(hObject,'String')));

% CHECK THAT END FRAME IS INVALID
if input>totalNumberOfFrames || input<=0 || isnan(input)
    
    pause(.2)
    flashBox('r',hObject);
    set(hObject,'String',num2str(oldMovieEndFrame));
    
% OTHERWISE SET NEW VALUE AND ENABLE EXPORTING IF GREATER THAN BEGINNING
% FRAME
else
    
    movieEndFrame = input;
    pause(.2)
    flashBox('g',hObject);
    set(hObject,'Value',movieEndFrame)
        
%     movieBeginFrame = get(handles.newBeginFrame,'Value');
%     
%     if movieBeginFrame>=movieEndFrame
%         set(handles.exportMovie,'Enable','off');
%     else
%         set(handles.exportMovie,'Enable','on');
%     end
        
end

function movieEndFrame_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exportMovie_Callback(hObject, eventdata, handles)

moviePath = get(hObject,'UserData');

if isnumeric(moviePath)
    [filename,pathname] = uiputfile('*.avi','Choose movie file',pwd);
else
    [filename,pathname] = uiputfile('*.avi','Choose movie file',moviePath);
end

if ~isnumeric(pathname)
    
%     SAVE MOVIE PATH IN OBJECT USERDATA FOR LATER USE
    moviePath = [pathname,filename];
    set(hObject,'UserData',moviePath);

    fileList = get(handles.frame,'UserData');
    showThresh = get(handles.showThresh,'Value');
    threshold = floor(str2double(get(handles.threshold,'String')));
    splineData = get(handles.splinePath,'UserData');
    showSplines = get(handles.showSplines,'Value');
    movieFPS = str2double(get(handles.movieFPS,'String'));
    
    movieBeginFrame = get(handles.movieBeginFrame,'Value');
    movieEndFrame = get(handles.movieEndFrame,'Value');
    
%     CREATE VIDEOWRITER OBJECT WITH DESIRED FRAMERATE
    writerObj = VideoWriter(moviePath);
    writerObj.FrameRate = movieFPS;
    open(writerObj);
    
%     CREATE INVISIBLE FIGURE WINDOW TO COPY FROM
    movieFig = figure('visible','off','NextPlot','add','Resize','off');
    movieAx = axes(movieFig);
    
    framesToCapture = movieBeginFrame:movieEndFrame;
    
    totalFrames = length(framesToCapture);
    
    for i=framesToCapture
        
        cla(movieAx)
        
        set(movieAx,'xtick',[],'ytick',[],'NextPlot','add');
        
        currentImage = imread(fileList{i});
        
        res = size(currentImage);
        
%         CREATE BINARY IMAGE IF DESIRED
        if showThresh && threshold>=0 && threshold<256
            
            currentImage(currentImage<=threshold) = 0;
            currentImage(currentImage>threshold) = 255;
            
        end
        
        imshow(currentImage,'Parent',movieAx);
        axis(movieAx,'image');
        
        hold on
        
%         LOAD SPLINES INTO AXES IF DESIRED
        if showSplines
            
            xSpline = splineData(2*i-1,:);
            ySpline = splineData(2*i,:);
            
            if ~isempty(xSpline) && mean(xSpline)
                
                plot(movieAx,xSpline,res(1)-ySpline+1,'c')
                plot(movieAx,xSpline(1),res(1)-ySpline(1)+1,'r.','MarkerSize',12)
                plot(movieAx,xSpline(end-2:end),res(1)-ySpline(end-2:end)+1,'m')
                plot(movieAx,xSpline(1:2),res(1)-ySpline(1:2)+1,'r')
                
            end
            
        end
        

        
        currentMovieFrame = getframe(movieAx);
        writeVideo(writerObj,currentMovieFrame);
        
%         UPDATED PROGRESS VALUE BETWEEN EACH FRAME PROCESSED
        progress = round(i/totalFrames*100);
        progress = ['Saving movie: ' num2str(progress) '%'];
        
        set(handles.movieMessages,'String',progress);
        
        drawnow
        
    end
    
    close(writerObj);
    
    set(handles.movieMessages,'String',['Movie saved to: ' moviePath]);
    
end

function movieFPS_Callback(hObject, eventdata, handles)

function movieFPS_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over restoreFramerate.
function restoreFramerate_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to restoreFramerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on restoreFramerate and none of its controls.
function restoreFramerate_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to restoreFramerate (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function restoreFramerate_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to restoreFramerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imagePath = get(handles.imagePath,'String');
currentFrameNumber = get(handles.currentFrameNumber,'Value');
fileList = get(handles.frame,'UserData');

framerate = get(handles.framerateOptions,'UserData');

totalNumberOfFrames = length(fileList);
count = floor(get(hObject,'Value'));
imageFile = fileList{count};
current = imread(imageFile);

low = min(min(current));
high = max(max(current));
imshow(current,[low,high],'Parent',handles.win);
currentFrameNumber = count;
updatePlaybackFrame(currentFrameNumber,handles);



% database=[];
% for ii=1:totalNumberOfFrames
%    currentfilename= char(fileList(ii));
%    currentimage = imread(currentfilename);
%    database(:,:,ii) = currentimage;
% end
% %N_images=size(database,3);
% 
% 
% count = floor(get(hObject,'Value'))
% current=database(:,:,count);
%  low = min(min(min(database)));
%  high = max(max(max(database)));
%  imshow(current,[low,high],'Parent',handles.win);

%set(0,'DefaultFigureVisible','off');
% h=struct;
% %h.f=importdata('playback_gui.fig');
% h.f= figure('Name', 'playback_gui');
% % 
% % h.f = findobj('Tag','win');
% %ax1 = axes('parent', fig1);
% h.ax=axes('Parent',h.f,...
%     'Units','Normalized',...
%     'Position',[0.029 0.079 0.486 0.814]);
% h.slider=uicontrol('Parent',h.f,...
%     'Units','Normalized',...
%    'Position',[0.032 0.022 0.482 0.032],...
%    'Style','Slider',...
%    'BackgroundColor',[1 1 1],...
%    'Min',1,'Max',N_images,'Value',1,...
%     'Callback',@sliderCallback);
% %store image database to the guidata struct as well
% h.database=database;
% guidata(h.f,h)
% %trigger a callback
% sliderCallback(h.slider)
% function sliderCallback(hObject,eventdata,handles)
% h=guidata(hObject);
% count=round(get(hObject,'Value'));
% low = min(min(min(h.database)));
% high = max(max(max(h.database)));
% current=h.database(:,:,count);
% %montage(current,'Parent',h.ax);
% %set(handles.win,'NextPlot','add');
% imshow(current,[low,high],'Parent',handles.win);



Sliderval=get(hObject,'Value'); %returns position of slider






% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% %imagePath = get(handles.imagePath,'String');
% %currentFrameNumber = get(handles.currentFrameNumber,'Value');
% fileList = get(handles.frame,'UserData');
% %currentFrameNumber = min(currentFrameNumber+1,length(fileList));
% %framerate = get(handles.framerateOptions,'UserData');
% 
% totalNumberOfFrames = length(fileList);
% database=[];
% for ii=1:totalNumberOfFrames
%    currentfilename= char(fileList(ii));
%    currentimage = imread(currentfilename);
%    database(:,:,ii) = currentimage;
% end
% N_images=size(database,3)
set(hObject,'Min',1,'Max',450);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider1.
function slider1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on slider1 and none of its controls.
function slider1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in restorecut.
% function restorecut_Callback(hObject, eventdata, handles)
% comp=computer;
% if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
%     slash='/';
% else
%     slash='\';
% end
% 
% imagePath = get(handles.imagePath,'String');
% timesPath = get(handles.timesPath,'String');
% splinePath= get(handles.splinePath,'String');
% removedFolder = [imagePath slash 'removed_CF'];
% beforeCFtimespath = [timesPath(1:end-4) '_original.txt'];
% movefile(beforeCFtimespath ,timesPath);
% beforeRFsplinepath = [splinePath(1:end-4) '_before_CF.txt'];
% movefile(beforeRFsplinepath ,splinePath);
% stagePath= regexp(imagePath,"\",'split'); % Parse File path into a 1x5 cell array
% stageFileName= stagePath{size(stagePath,2)}; % Extract the last element of the cell array
% stagePath= [imagePath slash strcat(stageFileName,'.txt')]; % Concat FileName with Full Path and Passed into importdata
% beforeCFstagepath = [stagePath(1:end-4) '_original.txt'];
% movefile(beforeCFstagepath ,stagePath);
% 
% if exist(removedFolder,'dir')
%     
%     %removedFilesList = listBmpsInFolder(removedFolder);
%     filenames =dir(fullfile(removedFolder, '*jpeg'));
%     removedFileList = fullfile(removedFolder,{filenames.name});
%     
%     
%     for i=1:length(removedFileList)
%         movefile(char(removedFileList(i)), imagePath);
%     end
%     rmdir(removedFolder);
% end
% disp('Files restored')
% load_Callback(handles.load,[],handles);
% set(handles.cut,'Enable','on');
% set(handles.newBeginFrame,'Enable','on');
% set(handles.newEndFrame,'Enable','on');
% set(handles.restorecut,'Enable','off');
% % hObject    handle to restorecut (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function win_CreateFcn(hObject, eventdata, handles)
% hObject    handle to win (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate win


% --- Executes during object creation, after setting all properties.
function totalNumberOfFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalNumberOfFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over totalNumberOfFrames.
function totalNumberOfFrames_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to totalNumberOfFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function totalNumberOfFrames_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to totalNumberOfFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
