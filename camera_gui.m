function varargout = camera_gui(varargin)
 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @camera_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @camera_gui_OutputFcn, ...
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
 
function camera_gui_OpeningFcn(hObject, eventdata, handles, varargin)
 
handles.output = hObject;
guidata(hObject, handles);
 
function varargout = camera_gui_OutputFcn(hObject, eventdata, handles)
 
varargout{1} = handles.output;
 
function connectCamera_Callback(hObject, eventdata, handles)
 
set(hObject,'Enable','off');
set(handles.messages,'String',('Connecting'));
 
% deviceInfo = imaqhwinfo('tisimaq_r2013_64');
% deviceInfo = deviceInfo.DeviceInfo;
% deviceInfo = deviceInfo.SupportedFormats;
%
% for i=1:length(deviceInfo)
%     disp(deviceInfo{i});
% end
 
% THE IMAGE SOURCE CAMERA, LOWRES
%vid = videoinput('tisimaq_r2013_64',1,'RGB24 (640x480) [2x Skipping]');
 
try
%     
%     THE IMAGING SOURCE CAMERA, FULL RES
    cameraString = get(handles.cameraName, 'String');
    cameraIndex = get(handles.cameraName, 'Value');
    switch cameraString{cameraIndex}
        case 'ALLIED VISION'
            disp('yes')
            vid = videoinput('gige', 1, 'Mono8');
            src = getselectedsource(vid);
            src.ExposureAuto = 'Off';
            
            expoSet= get(handles.expoSet,'String'); 
            src.ExposureTimeAbs = str2double(expoSet)*1000;
            %src.GainAuto = Off;
            src.Gain=0;
            src.AcquisitionFrameRateAbs = 15;
            %src.Gain = 25;
    
        case 'HAMAMATSU W/ IMAGE SPLITTER'
            vid = videoinput('hamamatsu', 1, 'MONO16_2048x2048_FastMode');
            src = getselectedsource(vid);
           % set(src, 'ExposureTime' , 1/30);
        case 'HAMAMATSU'
            vid = videoinput('hamamatsu', 1, 'MONO16_2048x2048_FastMode'); 
            src = getselectedsource(vid); 
            src.ExposureTimeControl = 'normal';
            set(src,'ExposureTime',1/25);
%         case 'TISIMAQ'
%             vid = videoinput('tisimaq_r2013_64',1,'RGB24 (1024x768)');
%             src = getselectedsource(vid); 
%             set(src,'FrameRate',25);
%             set(src, 'ExposureAuto', 'Off');
        case 'Choose Camera...'
            msg = msgbox('Choose a camera.');
    end
   
     
    % BRIGHTNESS CODE NOT IN USE FOR THIS CAMERA
    % brightness = round(str2double(get(handles.brightness,'String')));
    % set(src,'Brightness',brightness);
% % ADDED THIS PART
% triggerconfig(vid,'manual');
% set(vid,'LoggingMode','memory')
% set(src,'FrameRate',15)
% set(vid,'TimeOut',30)
% set(handles.connectCamera,'UserData',vid);
% brightness=round(str2double(get(handles.brightness,'String')));
% exposure=round(str2double(get(handles.exposure,'String')));
% framerate=get(handles.fps,'Value');
% switch framerate
%     case 1
%         FrameGrabInterval=1;
%         FramesPerTrigger=15;
%     case 2
%         FrameGrabInterval=3;
%         FramesPerTrigger=5;
%     case 3
%         FrameGrabInterval=5;
%         FramesPerTrigger=3;
%     case 4
%         FrameGrabInterval=15;
%         FramesPerTrigger=1;
% end
% set(src,'Brightness',brightness);
% set(src,'AutoExposure',exposure);
% set(src,'FrameRate','15');
% set(vid,'FrameGrabInterval',FrameGrabInterval)
% set(vid,'FramesPerTrigger',FramesPerTrigger)
% % END ADDED PART 8/27/2019
    % SET FPS TO 25 FOR PREVIEW -- OTHERWISE SYSTEM WILL LAG DUE TO HIGH
    % BANDWITH FROM CAMERA
    if cameraString{cameraIndex} == "ALLIED VISION"
        set(src,'AcquisitionFrameRateAbs', 25);
    else
        set(src,'FrameRate',25);
    end
    set(handles.connectCamera,'UserData',vid);
    
    % CREATE PREVIEW IN WINDOW FRAME
    axes(handles.win);
    hImage = imshow(getsnapshot(vid));
    preview(vid,hImage);
     
    % SIGNAL CAMERA IS CONNECTED
    set(handles.cameraStatus,'ForegroundColor','g');
    set(handles.messages,'String',('Camera Connected'));
     
    set(hObject,'Enable','off');
    set(handles.disconnectCamera,'Enable','on');
     
    % if isempty(readyToRecord(handles))
    %     set(handles.start,'Enable','on');
    % else
    %     set(handles.start,'Enable','off');
    % end
 
catch
     
    disp(('Failed to connect camera'));
    set(handles.messages,'String',('No camera detected'));
    set(hObject,'Enable','on');
     
end
 
function connectStage_Callback(hObject, eventdata, handles)
 
stageButtons = [handles.up,handles.left,handles.right,handles.down,handles.bigup,handles.bigleft,handles.bigright,handles.bigdown,handles.centerStage];
 
set(hObject,'Enable','off');
 
% COUNTER FOR CONNECTION ATTEMPTS
attemptsRemaining = 3;
 
% INDICATOR IF STAGE IS CONNECTED
stageConnected = 0;
 
% CONNECTION CODE

% if isempty(ports)
%     %warndlg('No stage is connected','Stage connection','modal');
%     obj.serial_com.String = 'NO COM';
% else
%     obj.serial_com.String = ports;
%     obj.serial_com.Value = 2;
% end
comPort = ['COM',get(handles.comPort,'String')];
stage = serial(comPort, 'BaudRate', 9600, 'Terminator', 'CR');
set(stage, 'ReadAsyncMode', 'manual');

%% niu
try
    fopen(stage);
    set(handles.connectStage,'UserData',stage);
    set(handles.messages,'String','Connecting');
    set(handles.messages,'String','Stage Connected');
    set(handles.stageStatus,'ForegroundColor','g');
    stageConnected = 1;
    % fprintf(stage,'SMS,100');
    % fprintf(stage,'SAS,100');
    fprintf(stage,'SMS,20');
    fprintf(stage,'BLZH,0');
    set(hObject,'Enable','off');
    set(handles.disconnectStage,'Enable','on');
    
    for i=1:length(stageButtons)
        set(stageButtons(i),'Enable','on');
    end
catch ME
    % Catch the error if fopen() fails and display the message in a msgbox
    %errorMessage = ME.message;  % Extract the error message
    %msgbox(errorMessage, 'COM Port Error', 'error');  % Show error in a message box
end
             
     
 
%{
while attemptsRemaining>0 && ~stageConnected
 
    try 
        
        fopen(stage);
        
        set(handles.connectStage,'UserData',stage)
        set(handles.messages,'String','Connecting')
         
        pause(3)
         
%         TEST STAGE OUTPUT
        fprintf(stage,'$');
        out = fscanf(stage);
         
        %if str2double(out)==0
         if isempty(out)     
            set(handles.messages,'String','Stage Connected');
            set(handles.stageStatus,'ForegroundColor','g');
            stageConnected = 1;
            % fprintf(stage,'SMS,100');
            % fprintf(stage,'SAS,100');
            fprintf(stage,'SMS,20');
            fprintf(stage,'BLZH,0');
            set(hObject,'Enable','off');
            set(handles.disconnectStage,'Enable','on');
             
            % if isempty(readyToRecord(handles))
            %     set(handles.start,'Enable','on');
            % else
            %     set(handles.start,'Enable','off');
            % end
             
            for i=1:length(stageButtons)
                set(stageButtons(i),'Enable','on');
            end
             
            drawnow
 
        elseif attemptsRemaining>0
             
            disp('Stage output mismatch. Reattempting connection...')
            attemptsRemaining = attemptsRemaining-1;
             
        else
             
            disp('Stage output mismatch');
            attemptsRemaining = attemptsRemaining-1;
             
        end
         
    catch
 
        disp('Crash during connection phase detected.')
        attemptsRemaining = attemptsRemaining-1;
         
    end
     
end 
%}
new = get(handles.connectStage,'UserData');
if ~stageConnected
     
%     ATTEMPT TO CLOSE ANY COM PORTS
    try  
        fclose(instrfind);
    catch
    end
         
    clear stage
     
    set(hObject,'Enable','on');
     
    msgbox('Please Check Connections--Stage Not Detected.  See Matlab Command Window for Debug.');
    set(handles.messages,'String','Stage not connected');
     
end
% calib = str2double(get(handles.calib,'String'));
% if isempty(calib)
%      
%     pause(.5);
%     flashBox('g',handles.calib);
%      
%     if isempty(readyToRecord(handles))
%         set(handles.start,'Enable','on');
%     else
%         set(handles.start,'Enable','off');
%     end
     
% else
%      
%     pause(.5);
%     flashBox('r',handles.calib);
%      
%     set(handles.start,'Enable','off');
%      
% end 
 
function disconnectCamera_Callback(hObject, eventdata, handles)
 
vid = get(handles.connectCamera,'UserData');
 
stop(vid)
stoppreview(vid)
 
clear vid
 
set(handles.connectCamera,'UserData',[]);
 
set(handles.cameraStatus,'ForegroundColor','r')
set(handles.messages,'String','Camera Disconnected')
 
set(hObject,'Enable','off');
set(handles.connectCamera,'Enable','on');
 
set(handles.start,'Enable','off');
 
function disconnectStage_Callback(hObject, eventdata, handles)
 
stageButtons = [handles.up,handles.left,handles.right,handles.down,handles.bigup,handles.bigleft,handles.bigright,handles.bigdown,handles.centerStage];
 
stage = get(handles.connectStage,'UserData');
 
fclose(stage);
status = stage.Status;
 
if strcmp(status,'closed')
     
    clear stage
     
    set(handles.connectStage,'UserData',[]);
     
    set(handles.messages,'String','Stage Disconnected')
    set(handles.stageStatus,'ForegroundColor','r')
     
    set(hObject,'Enable','off');
    set(handles.connectStage,'Enable','on');
     
    set(handles.start,'Enable','off');
     
    for i=1:length(stageButtons)
        set(stageButtons(i),'Enable','off');
    end
     
    drawnow
     
else
     
    msgbox('Could Not Disconnect.  See MATLAB Command Window for Debug.')
     
end
 
function comPort_Callback(hObject, eventdata, handles)
 
function comPort_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function framerate_Callback(hObject, eventdata, handles)
r=get(handles.framerate,'value');
setappdata(0,'rate',r)

 
function framerate_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function rectime_Callback(hObject, eventdata, handles)
 
function rectime_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function noVentral_Callback(hObject, eventdata, handles)
 
val=get(hObject,'Value');
 
if val==1
    set(handles.ventralLeft,'Value',0);
    set(handles.ventralRight,'Value',0);
elseif val==0
    set(handles.noVentral,'Value',1);
end
 
function ventralLeft_Callback(hObject, eventdata, handles)
 
val=get(hObject,'Value');
 
if val==1
    set(handles.ventralRight,'Value',0);
    set(handles.noVentral,'Value',0);
elseif val==0
    set(handles.noVentral,'Value',1);
end
 
function ventralRight_Callback(hObject, eventdata, handles)
 
val=get(hObject,'Value');
 
if val==1
    set(handles.ventralLeft,'Value',0);
    set(handles.noVentral,'Value',0);
elseif val==0
    set(handles.noVentral,'Value',1);
end
 
function enableStage_Callback(hObject, eventdata, handles)
 
function tifPath_Callback(hObject, eventdata, handles)
 
tifPath = get(hObject,'String');
 
if ~isempty(tifPath)
     
    pause(.5);
    flashBox('g',handles.tifPath);
     
    if isempty(readyToRecord(handles))
        set(handles.start,'Enable','on');
    else
        set(handles.start,'Enable','off');
    end
     
else
     
    pause(.5);
    flashBox('r',handles.tifPath);
     
    set(handles.start,'Enable','off');
     
end
 
function tifPath_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function browse_Callback(hObject, eventdata, handles)
set(handles.start,'Enable','on');
comp=computer;
 
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end
 
persistent lastPathname
 
if ~isnumeric(lastPathname)
    pathname = uigetdir(lastPathname);
else
    pathname = uigetdir();
end
 
if ~isnumeric(pathname)
     
    set(handles.tifPath,'String',pathname)
    lastPathname = pathname;
     
end
% calib = str2double(get(handles.calib,'String'));
% if isempty(calib)
%      
%     pause(.5);
%     flashBox('g',handles.calib);
%      
%     if isempty(readyToRecord(handles))
%         set(handles.start,'Enable','on');
%     else
%         set(handles.start,'Enable','off');
%     end
     
% else
%      
%     pause(.5);
%     flashBox('r',handles.calib);
%      
%     set(handles.start,'Enable','off');
%      
% end 
% if isempty(readyToRecord(handles))
%     set(handles.start,'Enable','on');
% else
%     set(handles.start,'Enable','off');
% end
 
function trackingThreshold_Callback(hObject, eventdata, handles)
 
function trackingThreshold_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function calib_Callback(hObject, eventdata, handles)
calib = str2double(get(handles.calib,'String')); 
if isnan(calib)
        flashBox('r',handles.calib);
        set(handles.start,'Enable','off');
%         set(handles.forceStop,'Enable','on');
elseif ~isnan(calib)
        flashBox('g',handles.calib);
        set(handles.start,'Enable','on');
%         set(handles.forceStop,'Enable','off');
end


% if isempty(calib)
%      
%     pause(.5);
%     flashBox('g',handles.calib);
%      
%     if isempty(readyToRecord(handles))
%         set(handles.start,'Enable','on');
%     else
%         set(handles.start,'Enable','off');
%     end
%      
% else
%      
%     pause(.5);
%     flashBox('r',handles.calib);
%      
%     set(handles.start,'Enable','off');
%      
% end

% if ~isempty(calib)
%      
%     pause(.5);
%     flashBox('g',handles.calib);
%      
%     if isempty(readyToRecord(handles))
%         set(handles.start,'Enable','on');
%     else
%         set(handles.start,'Enable','off');
%     end
%      
% else
%      
%     pause(.5);
%     flashBox('r',handles.calib);
%      
%     set(handles.start,'Enable','off');
%      
% end
 
function calib_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function start_Callback(hObject, eventdata, handles)
 
set(hObject,'Enable','off');
set(handles.forceStop,'Enable','on');
 
comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end
 
set(handles.forceStop,'UserData',[]);

% MAKE IMAGE DIRECTORY IF NOT ALREADY EXISTENT
tifPath = get(handles.tifPath,'String');
mkdir(tifPath);
 
% GET TRACKING SETTINGS
calib = str2double(get(handles.calib,'String'));

if isnan(calib)
        msgbox('Enter a calibration value.');
        return;

%         set(handles.forceStop,'Enable','on');
% elseif ~isempty(calib) && ~isnan(calib)
%         set(handles.start,'Enable','on');
%         set(handles.forceStop,'Enable','off');
end
% if isempty(calib)
%      
%     pause(.5);
%     flashBox('g',handles.calib);
%      
%     if isempty(readyToRecord(handles))
%         set(handles.start,'Enable','on');
%     else
%         set(handles.start,'Enable','off');
%     end
%      
% else
%      
%     pause(.5);
%     flashBox('r',handles.calib);
%      
%     set(handles.start,'Enable','off');
%      
% end
%if isempty(calib)
    %mes=msgbox('Enter Calibration.');
    %set(handles.forceStop,'Enable','off'); 
%end
    %set(handles.forceStop,'Enable','on');
trackingThreshold = str2double(get(handles.trackingThreshold,'String'));
 
% GET PRE-MADE VIDEO & STAGE OBJECTS
vid = get(handles.connectCamera,'UserData');
stage = get(handles.connectStage,'UserData');
 
src = getselectedsource(vid);
 
% FIND CENTER OF IMAGE FOR CENTERING STAGE
try
    res = get(vid,'VideoResolution');
catch 
    res = [728, 544];
end
cameraString = get(handles.cameraName, 'String');
cameraIndex = get(handles.cameraName, 'Value');
   switch cameraString{cameraIndex}
       case 'HAMAMATSU W/ IMAGE SPLITTER'
           centerOfImage = [1536, 1024];
       case 'HAMAMATSU'
           centerOfImage = [1024,1024];
       case 'TISIMAQ'
           centerOfImage = .5*res;
       case 'ALLIED VISION'
           centerOfImage  = .5*res;
       case 'Choose Camera...'
           mes = msgbox('Choose a camera.');
    end
% GET RECORDING SETTTINGS
rectime = get(handles.rectime,'String'); rectime=str2double(rectime);
framerate = get(handles.framerate,'Value');
 
switch framerate
     
    case 1
        framerate = 15;
    case 2
        framerate = 5;
    case 3
        framerate = 3;
    case 4
        framerate = 1;
end
 
% PREALLOCATE DISPLACEMENT VALUES
dx = zeros(rectime,1);
dy = zeros(rectime,1);
 
% PREPARE WINDOW FOR VIDEO
try
    stoppreview(vid);
catch
    closePreview(vid);
end
axes(handles.win);
 
% CHOOSE APPROPRIATE TIME INTERVAL FOR UPDATING PROGRESS BAR
if rectime>=60
    progressIncrement = rectime/20;
elseif rectime<10
    progressIncrement = rectime/5;
else
    progressIncrement = rectime/10;
end
 
nextProgressMark = progressIncrement;
 
% GET DAQ SEQUENCES
useSequence = get(handles.useSequence,'Value');
mydaq = get(handles.connectdaq,'UserData');
 
% CODE FOR PREPARING DAQ SEQUENCE
if ~isempty(mydaq) && useSequence
     
    ch1 = get(handles.ch1,'Value');
    ch2 = get(handles.ch2,'Value');
    ch3 = get(handles.ch3,'Value');
     
    seq1 = get(handles.sequence1,'UserData');
    seq2 = get(handles.sequence2,'UserData');
    seq3 = get(handles.sequence3,'UserData');
     
    rpt1 = str2double(get(handles.repeat1,'String'));
    rpt2 = str2double(get(handles.repeat2,'String'));
    rpt3 = str2double(get(handles.repeat3,'String'));
 
    if ch1
        seq1 = processSequence(seq1,rpt1,rectime);
    else
        seq1 = processSequence('0',1,rectime);
    end
     
    if ch2
        seq2 = processSequence(seq2,rpt2,rectime);
    else
        seq2 = processSequence('0',1,rectime);
    end
 
    if ch3
        seq3 = processSequence(seq3,rpt3,rectime);
    else
        seq3 = processSequence('0',1,rectime);
    end
 
    seqs = [{seq1};{seq2};{seq3}];
     
else
    seqs = [];
end
 
% DISABLE STAGE IF IN TESTING MODE
enableStage = get(handles.enableStage,'Value');
 
set(handles.messages,'String','Recording: 0% complete');
 
% SET VIDEO OBJECT SETTINGS FOR RECORDING
triggerconfig(vid,'manual');
set(vid, 'LoggingMode', 'memory', 'TimeOut', Inf, 'TriggerRepeat', rectime-1);
vid.FramesPerTrigger = framerate;
cameraString = get(handles.cameraName, 'String');
cameraIndex = get(handles.cameraName, 'Value');
switch cameraString{cameraIndex}
    case 'HAMAMATSU W/ IMAGE SPLITTER'
        src.ExposureTime = 1/framerate;
    case 'HAMAMATSU'
        src.ExposureTime = 1/framerate; 
    case 'TISIMAQ'
        set(src,'FrameRate',framerate);
    case 'ALLIED VISION'
        src.AcquisitionFrameRateAbs = framerate;
end
disp('Starting video logging');
 
start(vid);
 
% BEGIN STOPWATCH FOR TIME VERIFICATION
%testingTime = tic;
 
for i=1:rectime
     
%     UPDATE PROGRESS MESSAGE IF NEXT INTERVAL IS REACHED
    if i>=nextProgressMark
         
        set(handles.messages,'String',['Recording: ' num2str(round(nextProgressMark/rectime*100)) '% complete']);
        nextProgressMark = nextProgressMark+progressIncrement;
         
    end
     
%     OUTPUT SEQUENCE IF DAQ IS SET UP
    if ~isempty(seqs)
         
        state1 = str2double(seqs{1}(i));
        state2 = str2double(seqs{2}(i));
        state3 = str2double(seqs{3}(i));
        outputString = [state1 state2 state3];
        mydaq.write(outputString);
         
    end
    
    
    trigger(vid);
    
    

    % wait(vid,30,'logging')
%     CREATE BINARY FILES TO WRITE IMAGE AND TIME DATA TO
    tempFramesFile = [tifPath slash 'tempFrameFile_' num2str(i) '.bi'];
    tempFramesFile = fopen(tempFramesFile,'w');
    
    tempTimesFile = [tifPath slash 'tempTimesFile_' num2str(i) '.bi'];
    tempTimesFile = fopen(tempTimesFile,'w');
%     COLLECT DATA 
    [f,t] = getdata(vid);
    %disp(size(f(:,:,1,end)));
%     WRITE IMAGE AND TIME DATA
    fwrite(tempFramesFile,f,'uint8'); fwrite(tempTimesFile,t,'double');
    %disp(tempFramesFile);
%     BINARIZE LAST FRAME OF COLLECTED RECORDING
     lastframe = f(:,:,1,end);
%     figure;
%     imshow(lastframe);
%     lastframe = imresize(lastframe,.5);
    lastframeBinary = imbinarize(lastframe,trackingThreshold/255);
     %   x = lastframe(1:2048, 800:2048);
   %     FIND CENTROID OF BINARIZED IMAGE (IF REGIONS EXIST)
   switch cameraString{cameraIndex}
        case 'TISIMAQ'
            cogValue = regionprops(1-lastframeBinary,lastframe,'WeightedCentroid');
  
            try
                cogValue = cogValue.WeightedCentroid;
            catch
                cogValue = centerOfImage;
            end
             
  
        %     SHOW LAST FRAME, BINARIZED IF SELECTED
            if get(handles.showThresh,'Value')
  
                imshow(lastframeBinary)
                hold on
                plot(cogValue(1),cogValue(2),'r*');
                hold off
  
            else
  
                imshow(f(:,:,1,end))
  
            end
            displacement = -calib*(centerOfImage-cogValue);
       case 'HAMAMATSU'
            cogValue = regionprops(1-lastframeBinary,lastframe,'WeightedCentroid');
  
            try
                cogValue = cogValue.WeightedCentroid;
            catch
                cogValue = centerOfImage;
            end
             
  
        %     SHOW LAST FRAME, BINARIZED IF SELECTED
            if get(handles.showThresh,'Value')
  
                imshow(lastframeBinary)
                hold on
                plot(cogValue(1),cogValue(2),'r*');
                hold off
  
            else
  
                imshow(f(:,:,1,end))
  
            end
            displacement = -calib*(centerOfImage-cogValue);
        case 'HAMAMATSU W/ IMAGE SPLITTER'
             
            cogValue = splitimage(x);
            if get(handles.showThresh,'Value')
  
                imshow(lastframeBinary)
                hold on
                plot(cogValue(1),cogValue(2),'r*');
                hold off
  
            else
  
                imshow(f(:,:,1,end))
  
            end
            displacement = calib*(centerOfImage-cogValue);
        case 'ALLIED VISION'
           cogValue = regionprops(1-lastframeBinary,lastframe,'WeightedCentroid');
  
            try
                cogValue = cogValue.WeightedCentroid;
            catch
                cogValue = centerOfImage;
            end
             
  
        %     SHOW LAST FRAME, BINARIZED IF SELECTED
            if get(handles.showThresh,'Value')
  
                imshow(lastframeBinary)
                hold on
                plot(cogValue(1),cogValue(2),'r*');
                hold off
  
            else
  
                imshow(f(:,:,1,end))
  
            end
            displacement = -calib*(centerOfImage-cogValue);
    end
%     FIND DISPLACEMENT IN px, CONVERT TO um
%     IF X<0, MOVE LEFT; >0, MOVE RIGHT
%     IF Y<0, MOVE DOWN; >0, MOVE UP
 %   displacement = calib*(centerOfImage-cogValue);
 
%     MOVE STAGE BY DISPLACEMENT AND SAVE VALUES
    moveRelative(stage,-displacement(1),-displacement(2),enableStage);
    disp(['Moved ' num2str(displacement(1)) ',' num2str(displacement(2))]);
    dx(i)=displacement(1);
    dy(i)=displacement(2);
     
%     IF STOP HAS BEEN PUSHED, END RECORDING
    stop = get(handles.forceStop,'UserData');
     
    if stop
         
        set(handles.messages,'String','Cancelling... Please Wait');
        pause(2);
        disconnectCamera_Callback(handles.disconnectCamera,[],handles);
        set(handles.messages,'String','Cancelled.');
         
        set(hObject,'Enable','on')
        set(handles.forceStop,'Enable','off');
         
        return
         
    end
    if i==1
        tic;
    end
    if i==rectime
        toc;
    end
    
%     CLOSE BINARY FILES;
  fclose(tempFramesFile); fclose(tempTimesFile);
    
end

%testingTime = toc(testingTime);
% DO NOT REMOVE - NECESSARY TO PREVENT BINARY FILES FROM BEING LEFT OPEN ON
% LONG RECORDINGS

fclose('all');
 
% DISPLAY VERIFICATION TIME
%testingTime = toc(testingTime); 
set(handles.messages,'String','Recording: 100% complete');
 
set(handles.forceStop,'Enable','off');
 
% IF DAQ IS CONNECTED, TURN OFF LIGHTS
if ~isempty(seqs)
     
    outputString = [0 0 0];
    mydaq.write(outputString);
     
end
             
pause(1)
 
% FIND SELECTED VENTRAL SIDE, AND FIND CORRESPONDING FILE NAME PREFIX
vd=[0 0 0];
vd(1)=get(handles.ventralRight,'Value');
vd(2)=get(handles.ventralLeft,'Value');
vd(3)=get(handles.noVentral,'Value');
 
if vd(1)
    ventralDir='R_';
elseif vd(2)
    ventralDir='L_';
elseif vd(3)
    ventralDir='';
end
 
% GET FACTOR TO RESIZE IMAGES, IN DECIMAL FORM
imageResizeFactor = get(handles.imageScale,'Value');
imageResizeString = get(handles.imageScale,'String');
imageResizeFactor = imageResizeString{imageResizeFactor};
switch imageResizeFactor
     
    case '100%'
        imageResizeFactor = 1;
    case '50%'
        imageResizeFactor = .5;
    case '25%'
        imageResizeFactor = .25;
end
 
% RESET PROGRESS MESSAGE (FOR SAVING)
nextProgressMark = progressIncrement;
 
set(handles.messages,'String','Saving images: 0% complete');
 
% SAVING USUALLY IS FASTER, drawnow COMMAND NEEDED TO ENSURE THAT TEXT
% FIELD FOR PROGRESS IS CONTRINUOUSLY UPDATED
drawnow
 
times = NaN([1 rectime*framerate]);
 
for i=1:rectime
     
%     UPDATE PROGRESS MESSAGE IF NEXT INTERVAL IS REACHED
    if i>ceil(nextProgressMark)
         
        set(handles.messages,'String',['Saving images: ' num2str(round(nextProgressMark/rectime*100)) '% complete']);
        nextProgressMark = nextProgressMark+progressIncrement;
         
        drawnow
         
    end
     
%     FIND NAME OF EXISTENT FRAME BINARY FILE AND OPEN IT
    tempFramesFileName = [tifPath slash 'tempFrameFile_' num2str(i) '.bi'];
    tempFramesFile = fopen(tempFramesFileName);
%     RESHAPE DATA INTO IMAGE SIZE (DATA IS READ AS A COLUMN VECTOR)
   
    currentFramesData = fread(tempFramesFile,Inf,'uint8');
   
    try
        currentFramesData = reshape(currentFramesData,[res(2) res(1) 3 framerate]);
    catch
        currentFramesData = reshape(currentFramesData, [res(2) res(1) 1 framerate]);
    end
    currentFramesData = uint8(currentFramesData);
 
     
    for j=1:size(currentFramesData,4)
         
        currentImg = currentFramesData(:,:,:,j);
        currentImg = mat2gray(currentImg);
%     IF RESIZE FACTOR ~1, RESIZE EACH IMAGE FRAME
        if imageResizeFactor ~= 1
            currentImg = imresize(currentImg,imageResizeFactor);
        end
         
%         CREATE IMAGE NAME FROM V/D PREFIX AND FRAME NUMBER
        frameNum = (i-1)*framerate+j;
        frameNum = pad(num2str(frameNum),5,'left','0');
        imagePath = [tifPath slash ventralDir 'img' frameNum '.jpeg'];
         
         
%         SAVE IMAGE AS jpeg
        imwrite(currentImg,imagePath,'jpeg');        
    end
     
%     CLOSE BIANRY FRAMES FILE, AND DELETE IT
    fclose(tempFramesFile);
    delete(tempFramesFileName);
     
%     FIND NAME OF EXISTENT TIMES BINARY FILE AND OPEN IT
    tempTimesFileName = [tifPath slash 'tempTimesFile_' num2str(i) '.bi'];
    tempTimesFile = fopen(tempTimesFileName);
     
%     READ BINARY DATA AS A COLUMN VECTOR
    currentTimesData = fread(tempTimesFile,15,'double');
     
%     ADD CURRENT BIANRY FILE'S TIME DATA TO LARGE times ARRAY
    times((i-1)*framerate+1:i*framerate) = currentTimesData;
     
%     CLOSE BINARY TIMES FILE, AND DELETE IT
    fclose(tempTimesFile);
    delete(tempTimesFileName);
     
end
 
set(handles.messages,'String','Saving images: 100% complete');
     
set(handles.messages,'String','Saving coordinate data')
 
% GENERATE NAMES OF STAGE AND TIMES FILE, USING DIRECTORY NAME
lastSlash = find(tifPath==slash);
lastSlash = lastSlash(end);
stageName = [tifPath slash tifPath(lastSlash+1:end) '.txt'];
timesName = [tifPath slash tifPath(lastSlash+1:end) '_times.txt'];
 
stageLabels=[{'%%delta-x'} {'%%delta-y'} {'%%calib-factor'}];
timesLabels =[{'%%current-t'} {'%%framerate'}];
 
% FLIP dy DATA (FROM STAGE COORDINATE SYSTEM TO IMAGE COORDINATE SYSTEM)
dx(isnan(dx)) = 0;  dy(isnan(dy)) = 0;
dx = num2cell(dx); dy = num2cell(-dy);
 
% CREATE FILLER COLUMN OF calib VALUES
calib = calib/imageResizeFactor;
calibData = cell(size(dx));
calibData(:) = {calib};
 
% CREATE CELL ARRAY CONTAINING STAGE DATA
stageData = [dx dy calibData];
stageData = [{0} {0} {calib};stageData];
 
% CREATE CELL ARRAY CONTAING TIME STAMPS AND A FRAMERATE FILLER COLUMN
timesData = [times' framerate*ones([length(times) 1])];
 
% SAVE BOOTH CELL ARRAYS
saveDataMatrix(stageLabels,stageData,stageName);
saveDataMatrix(timesLabels,timesData,timesName);
 
set(handles.messages,'String','Saving Complete');
 
% RESET VIDEO PREVIEW
hImage = imshow(getsnapshot(vid));
preview(vid,hImage);
 
set(hObject,'Enable','on');
 
function forceStop_Callback(hObject, eventdata, handles)
set(handles.forceStop,'UserData',1);
 
function imageScale_Callback(hObject, eventdata, handles)
 
function imageScale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function showThresh_Callback(hObject, eventdata, handles)
% if get(handles.start, 'Value')==0
%     if get(handles.showThresh, 'Value') == 1
%         rectime = get(handles.rectime,'String'); rectime=str2double(rectime);
%     framerate = get(handles.framerate,'Value');
%      vid = get(handles.connectCamera,'UserData');
%     switch framerate
% 
%         case 1
%             framerate = 15;
%         case 2
%             framerate = 5;
%         case 3
%             framerate = 3;
%         case 4
%             framerate = 1;
%     end
% 
%     trackingThreshold = str2double(get(handles.trackingThreshold,'String'));
% 
%     if get(handles.showThresh,'Value')
%         stoppreview(vid);
%         triggerconfig(vid,'manual');
%         set(vid,'LoggingMode','memory','TimeOut',Inf,'TriggerRepeat',rectime-1);
%         vid.FramesPerTrigger = framerate;
%         start(vid);
%         while get(handles.showThresh, 'Value') 
%             trigger(vid);
%             [f,t] = getdata(vid);
%             lastframe = f(:,:,1,end);
%             lastframeBinary = imbinarize(lastframe,trackingThreshold/255);
%             x = lastframe(1:2048, 20:2048);
%             cogValue = splitimage(x);
%             imshow(lastframe)
%             hold on
%             plot(cogValue(1),cogValue(2),'r*');
%             hold off
%         end
%         stop(vid);
%         axes(handles.win);
%         hImage = imshow(getsnapshot(vid));
%         preview(vid,hImage);
%     end
%     end
% end
 
% STAGE MOVEMENT FUNCTIONS
function moveRelative(s,x,y,enableStage)
 
if enableStage
    cmd = ['GR,' num2str(x) ',' num2str(y)];
    fprintf(s,cmd);
    
end
% dis = sqrt((x*x)+ (y*y));
% z = dis/8000;
% pause(z);
 
function up_Callback(hObject, eventdata, handles)
stage = get(handles.connectStage,'UserData');
fprintf(stage,'F,10');
 
function left_Callback(hObject, eventdata, handles)
stage = get(handles.connectStage,'UserData');
fprintf(stage,'L,10');
 
function right_Callback(hObject, eventdata, handles)
stage = get(handles.connectStage,'UserData');
fprintf(stage,'R,10');
 
function down_Callback(hObject, eventdata, handles)
stage = get(handles.connectStage,'UserData');
fprintf(stage,'B,10');
 
function bigup_Callback(hObject, eventdata, handles)
stage = get(handles.connectStage,'UserData');
fprintf(stage,'F,100');
 
function bigdown_Callback(hObject, eventdata, handles)
stage = get(handles.connectStage,'UserData');
fprintf(stage,'B,100');
 
function bigright_Callback(hObject, eventdata, handles)
stage = get(handles.connectStage,'UserData');
fprintf(stage,'R,100');
 
function bigleft_Callback(hObject, eventdata, handles)
stage = get(handles.connectStage,'UserData');
fprintf(stage,'L,100');
 
function centerStage_Callback(hObject, eventdata, handles)

stage = get(handles.connectStage,'UserData');
fprintf(stage,'G,0,0');
 
% MyDAQ FUNCTIONS

function connectdaq_Callback(hObject, eventdata, handles)
set(handles.messages,'String','Connecting');
 
% daqButtonHandles = [handles.disconnectdaq,handles.lightswitch,handles.useSequence,handles.showSequenceGraph];
% daqTickHandles = [handles.useSequence,handles.ch1,handles.ch2,handles.ch3];
% sequenceHandles = [handles.sequence1,handles.sequence2,handles.sequence3];
% repeatHandles = [handles.repeat1,handles.repeat2,handles.repeat3];
 
daqHandles = [handles.disconnectdaq,handles.lightswitch,handles.useSequence];
 
% allDaqHandles = [daqButtonHandles,daqTickHandles,sequenceHandles,repeatHandles];
 
for i=1:length(daqHandles)
    set(daqHandles(i),'Enable','on');
end
 
try
     
    mydaq = daq("ni");
    mydaq.addoutput('myDAQ1','port0/line5','Digital');
    mydaq.addoutput('myDAQ1','port0/line6','Digital');
    mydaq.addoutput('myDAQ1','port0/line7','Digital');
     
    
    set(handles.daqStatus,'ForegroundColor','g');
    set(hObject,'UserData',mydaq,'Enable','off');
     
    set(handles.messages,'String','External Device Connected');
     
    set(handles.disconnectdaq,'Enable','on');
     
catch
     
    set(handles.messages,'String','Error connecting NI MyDAQ')
     
end
 
 
function connectdaq_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function disconnectdaq_Callback(hObject, eventdata, handles)
 
daqHandles = [handles.disconnectdaq,handles.lightswitch,handles.useSequence];
 
% daqButtonHandles = [handles.disconnectdaq,handles.lightswitch,handles.useSequence,handles.showSequenceGraph];
% daqTickHandles = [handles.ch1,handles.ch2,handles.ch3];
% sequenceHandles = [handles.sequence1,handles.sequence2,handles.sequence3];
% repeatHandles = [handles.repeat1,handles.repeat2,handles.repeat3];
 
mydaq = get(handles.connectdaq,'UserData');
 
mydaq.removechannel(1);
delete(mydaq);
 
set(handles.messages,'String','External Device Disconnected');
set(handles.daqStatus,'ForegroundColor','r');
set(handles.connectdaq,'Enable','on','UserData',[]);
 
for i=1:length(daqHandles)
    set(daqHandles(i),'Enable','off');
end
 
set(handles.useSequence,'Value',0);
 
function disconnectdaq_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function lightswitch_Callback(hObject, eventdata, handles)
 
mydaq = get(handles.connectdaq,'UserData');
laserState = get(handles.lightswitch,'UserData');

 
if isempty(laserState)   
    laserState = 0;
end
 
if laserState==0 && ~isempty(mydaq)
     
    mydaq.write([1 1 1]);
    set(handles.lightswitch,'UserData',1);
    set(handles.useSequence,'Enable','off');
     
elseif laserState==1 && ~isempty(mydaq)
     
    mydaq.write([0 0 0]);
    set(handles.lightswitch,'UserData',0);
    set(handles.useSequence,'Enable','on');
     
end
 
function lightswitch_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function useSequence_Callback(hObject, eventdata, handles)
 
value = get(hObject,'Value');
 
switch value
     
    case 1
         
        set(handles.lightswitch,'Enable','off');
        set(handles.sequence1,'Enable','on','String',('0 = OFF, 1 = ON'));
        set(handles.sequence2,'Enable','on','String',('0 = OFF, 1 = ON'));
        set(handles.sequence3,'Enable','on','String',('0 = OFF, 1 = ON'));
        set(handles.ch1,'Enable','on','Value',0);
        set(handles.ch2,'Enable','on','Value',0);
        set(handles.ch3,'Enable','on','Value',0);
        set(handles.showSequenceGraph,'Enable','on');
        set(handles.repeat1,'Enable','on','Value',1);
        set(handles.repeat2,'Enable','on','Value',1);
        set(handles.repeat3,'Enable','on','Value',1);
         
    case 0
         
        set(handles.lightswitch,'Enable','on');
        set(handles.sequence1,'Enable','off','String',('0 = OFF, 1 = ON'));
        set(handles.sequence2,'Enable','off','String',('0 = OFF, 1 = ON'));
        set(handles.sequence3,'Enable','off','String',('0 = OFF, 1 = ON'));
        set(handles.ch1,'Enable','off','Value',0);
        set(handles.ch2,'Enable','off','Value',0);
        set(handles.ch3,'Enable','off','Value',0);
        set(handles.showSequenceGraph,'Enable','off');
        set(handles.repeat1,'Enable','off','Value',1);
        set(handles.repeat2,'Enable','off','Value',1);
        set(handles.repeat3,'Enable','off','Value',1);
         
end
 
function ch_Callback(hObject, eventdata, handles)
 
allSeqLength = [0 0 0];
allSeqLength(1) = length(get(handles.sequence1,'Value'))*get(handles.ch1,'Value');
allSeqLength(2) = length(get(handles.sequence2,'Value'))*get(handles.ch2,'Value');
allSeqLength(3) = length(get(handles.sequence3,'Value'))*get(handles.ch3,'Value');
allSeqLength = max(allSeqLength);
 
set(handles.seqLength,'String',num2str(allSeqLength),'Value',allSeqLength);
 
function sequence_Callback(hObject, eventdata, handles)
 
sequenceHandles = [handles.sequence1,handles.sequence2,handles.sequence3];
repeatHandles = [handles.repeat1,handles.repeat2,handles.repeat3];
 
drawnow
 
seq = get(hObject,'String');
oldSeq = get(hObject,'UserData');
 
if isempty(oldSeq)
    oldSeq = '0 = OFF, 1 = ON';
end
 
if isempty(seq(~(seq==' ' | seq=='*' | seq==',' | seq=='*')))
     
    flashBox('r',hObject);
    set(hObject,'String',oldSeq);
     
else
     
    processedSeq = processSequence(seq,get(repeatHandles(sequenceHandles==hObject),'Value'));
    processedSeqNum = NaN([1,length(processedSeq)]);
     
    if ~isempty(processedSeq(~(processedSeq=='0' | processedSeq=='1')))
         
        flashBox('r',hObject);
        set(hObject,'String',oldSeq);
         
         
    else
         
        flashBox('g',hObject);
         
        for i=1:length(processedSeq)
            processedSeqNum(i) = str2double(processedSeq(i));
        end
         
        set(hObject,'String',seq,'UserData',seq,'Value',processedSeqNum);
         
        allSeqLength = [0 0 0];
        allSeqLength(1) = length(get(handles.sequence1,'Value'))*get(handles.ch1,'Value');
        allSeqLength(2) = length(get(handles.sequence2,'Value'))*get(handles.ch2,'Value');
        allSeqLength(3) = length(get(handles.sequence3,'Value'))*get(handles.ch3,'Value');
        allSeqLength = max(allSeqLength);
         
        set(handles.seqLength,'String',num2str(allSeqLength),'Value',allSeqLength);
         
    end
     
end
 
function sequence_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function repeat_Callback(hObject, eventdata, handles)
 
sequenceHandles = [handles.sequence1,handles.sequence2,handles.sequence3];
repeatHandles = [handles.repeat1,handles.repeat2,handles.repeat3];
 
oldRepeat = get(hObject,'Value');
 
repeat = get(hObject,'String');
repeat = str2double(repeat);
 
if ~isnan(repeat) && floor(repeat)==repeat && repeat>=1
     
    flashBox('g',hObject);
    set(hObject,'Value',repeat,'String',num2str(repeat));
     
    processedSeq = processSequence(get(handles.sequence1,'UserData'),repeat);
    processedSeqNum = NaN([1,length(processedSeq)]);
     
    for i=1:length(processedSeq)
        processedSeqNum(i) = str2double(processedSeq(i));
    end
     
    set(sequenceHandles(repeatHandles==hObject),'Value',processedSeqNum);
     
    allSeqLength = [0 0 0];
    allSeqLength(1) = length(get(handles.sequence1,'Value'))*get(handles.ch1,'Value');
    allSeqLength(2) = length(get(handles.sequence2,'Value'))*get(handles.ch2,'Value');
    allSeqLength(3) = length(get(handles.sequence3,'Value'))*get(handles.ch3,'Value');
    allSeqLength = max(allSeqLength);
     
    set(handles.seqLength,'String',num2str(allSeqLength),'Value',allSeqLength);
     
else
     
    flashBox('r',hObject);
    set(hObject,'String',num2str(oldRepeat));
     
end
 
allSeqLength = [0 0 0];
allSeqLength(1) = length(get(handles.sequence1,'Value'))*get(handles.ch1,'Value');
allSeqLength(2) = length(get(handles.sequence2,'Value'))*get(handles.ch2,'Value');
allSeqLength(3) = length(get(handles.sequence3,'Value'))*get(handles.ch3,'Value');
allSeqLength = max(allSeqLength);
 
set(handles.seqLength,'String',num2str(allSeqLength),'Value',allSeqLength);
 
function repeat_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function showSequenceGraph_Callback(hObject, eventdata, handles)
 
sequences = cell([1,3]);
 
sequenceHandles = [handles.sequence1,handles.sequence2,handles.sequence3];
repeatHandles = [handles.repeat1,handles.repeat2,handles.repeat3];
channelHandles = [handles.ch1,handles.ch2,handles.ch3];
 
rectime = str2double(get(handles.rectime,'String'));
 
if isempty(rectime)
    rectime = get(handles.seqLength,'Value');
end
 
for i=1:3
    if get(channelHandles(i),'Value')
        sequences{i} = processSequence(get(sequenceHandles(i),'String'),get(repeatHandles(i),'Value'),rectime);
    else
        sequences{i} = zeros([1,max(get(handles.seqLength,'Value'),rectime)]);
    end
end
 
stimGraph(sequences{1},sequences{2},sequences{3});
 
function isReady = readyToRecord(handles)
 
isReady = [0 0 0];
 
isReady(1) = isempty(get(handles.connectCamera,'UserData'));
isReady(2) = isempty(get(handles.connectStage,'UserData'));
%isReady(3) = strcmp(get(handles.tifPath,'String'),('Directory to save .jpeg images'));
isReady(3) = strcmp(get(handles.tifPath, 'String'), ('Directory to save .jpeg images'));
 
isReady = find(isReady);
 
%---------------------------Helper Functions-------------------------------
 
 
% function fileList = listTifsInFolder(path)
% 
% comp=computer;
% if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
%     slash='/';
% else
%     slash='\';
% end
% 
% % CREATE LIST OF .tif FILES IN DIRECTORY
% list = dir([path slash '*.Tif']);
% fileList = NaN(size(list));
% 
% for i=1:length(list)
%     
%     fileList(i) = {[path slash list(i).name]};
%     
% end
 
% function showFrame(number,handles)
% 
% filelist=get(handles.mainpanel,'UserData');
% 
% clow=get(handles.clow,'String');    clow=str2double(clow);
% chigh=get(handles.chigh,'String');  chigh=str2double(chigh);
% 
% imgContrast=prepImage(filelist{number},clow,chigh);
% axes(handles.win)
% imshow(imgContrast);
% set(handles.win,'UserData',imgContrast);
 
% function setPos(handles,position)
% set(handles.X,'String',num2str(position(1)));
% set(handles.Y,'String',num2str(position(2)));
% set(handles.X,'UserData',position(1));
% set(handles.Y,'UserData',position(2));
 
% function [x,y]=getPos(handles)
% x=get(handles.X,'UserData');
% y=get(handles.Y,'UserData');
 
% function [x,y]=cog(img)
% img=double(img);
% img=255-img;
% img=img/max(max(img));
% s=sum(sum(img));
% xt=zeros(1,length(img(1,:)));
% for i=1:length(img(1,:))
%     xt(i)=sum(img(:,i))*i;
% end
% x=sum(xt)/s;
% yt=zeros(1,length(img(:,1)));
% for i=1:length(img(:,1))
%     yt(i)=sum(img(i,:))*i;
% end
% y=sum(yt)/s;
 
% function [xDisplacement,yDisplacement]=centerWorm(stage,cogX,cogY,calib,res)
% centerOfImageX = 0.5 * res(1); centerOfImageY = 0.5 * res(2);
% xMove = calib*(centerOfImageX-cogX);  %if <0, move left; if >0, move right.  xMove is in micrometers, not pixels
% yMove = calib*(centerOfImageY-cogY);  %if <0, move down; if >0, move up.  yMove is in um.
% disp(['Moved ' num2str(xMove) ',' num2str(yMove)]);
% xDisplacement = -xMove; yDisplacement = -yMove;  
% %the signs are reversed to reflect movement of the coordinate system, not camera.
% moveRelative(stage,xMove,yMove,1);
 
% function moveLeft(s,n)
% cmd=['L,' num2str(n)];
% fprintf(s,cmd);
% 
% function moveRight(s,n)
% cmd=['R,' num2str(n)];
% fprintf(s,cmd);
% 
% function moveUp(s,n)
% cmd=['F,' num2str(n)];
% fprintf(s,cmd);
% 
% function moveDown(s,n)
% cmd=['B,' num2str(n)];
% fprintf(s,cmd);
 
% function apply_Callback(hObject, eventdata, handles)
% 
% vid = get(handles.connectCamera,'UserData');
% src = getselectedsource(vid);
% 
% brightness = round(str2double(get(handles.brightness,'String')));
% 
% set(src,'Brightness',brightness);
 
% function adjust_Callback(hObject, eventdata, handles)
% 
% showFrame(1,handles);
 
 
% function tifPath_KeyPressFcn(hObject, eventdata, handles)
% 
% comp=computer;
% if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
%     slash='/';
% else
%     slash='\';
% end
% 
% if strcmp(eventdata.Key,'return')
%     
%     pause(.5)
%     flashBox('g',handles.tifPath);
%     
%     if isempty(readyToRecord(handles))
%         set(handles.start,'Enable','on');
%     else
%         set(handles.start,'Enable','off');
%     end
%     
% end
 
 
% function stop=checkStopButton(stopButton)
% 
% stop = get(stopButton,'UserData');
% 
% if stop==1
%     stop=1;
% else
%     stop=0;
% end
     
 
 
% --- Executes on selection change in cameraName.
function cameraName_Callback(hObject, eventdata, handles)
% hObject    handle to cameraName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = cellstr(get(hObject,'String')) returns cameraName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cameraName
 
 
% --- Executes during object creation, after setting all properties.
function cameraName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cameraName.
function cameraName_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to cameraName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function messages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to messages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function exposure_Callback(hObject, eventdata, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposure as text
%        str2double(get(hObject,'String')) returns contents of exposure as a double


% --- Executes during object creation, after setting all properties.
function exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function expoSet_Callback(hObject, eventdata, handles)
% hObject    handle to expoSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expoSet as text
%        str2double(get(hObject,'String')) returns contents of expoSet as a double
flashBox('g',handles.expoSet);
vid = get(handles.connectCamera,'UserData');
 
stop(vid)
stoppreview(vid)
 
clear vid
set(handles.connectCamera, 'Enable','on');
set(handles.disconnectCamera,'Enable','off');

% --- Executes during object creation, after setting all properties.
function expoSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expoSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
