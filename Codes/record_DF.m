function varargout = record_DF(varargin)
        
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @record_DF_OpeningFcn, ...
                   'gui_OutputFcn',  @record_DF_OutputFcn, ...
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

function record_DF_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

function varargout = record_DF_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

function connectCamera_Callback(hObject, eventdata, handles)

set(hObject,'Enable','off');

% deviceInfo = imaqhwinfo('tisimaq_r2013_64');
% deviceInfo = deviceInfo.DeviceInfo;
% deviceInfo = deviceInfo.SupportedFormats;
%
% for i=1:length(deviceInfo)
%     disp(deviceInfo{i});
% end

% THE IMAGE SOURCE CAMERA, LOWRES
%vid = videoinput('tisimaq_r2013_64',1,'RGB24 (640x480) [2x Skipping]');
exposure = findobj(0,'tag','exposure');
exposureString = get(exposure, 'String')
exposureIndex = get(exposure, 'value')
% exposureString = get(handles.exposure, 'String');
% exposureIndex = get(handles.exposure, 'value');
switch exposureString{exposureIndex}
    case '1000 ms'
        exposure = 1.0;
    case '500 ms'
        exposure = .5;
    case '250 ms'
        exposure = .4;
    case '200 ms'
        exposure = .2;
    case '100 ms'
        exposure = .1;
end
try
    
%     THE IMAGING SOURCE CAMERA, FULL RES
    %vid = videoinput('tisimaq_r2013_64',1,'RGB24 (1024x768)');
    
    % MIGHTEX CAMERA
    %vid = videoinput('winvideo',2) %Mightex Camera
    
    %HAMAMATSU CAMERA 
    cameraString = get(handles.cameraName, 'String');
    cameraIndex = get(handles.cameraName, 'value');
    switch cameraString{cameraIndex}
        case 'HAMAMATSU'
            vid = videoinput('hamamatsu', 1, 'MONO16_1024x1024_FastMode'); 
            src = getselectedsource(vid); 
            
            src.ExposureTimeControl = 'normal';
            set(src,'ExposureTime',exposure);
            
        case 'HAMAMATSU W/ IMAGE SPLITTER'
            vid = videoinput('hamamatsu', 1, 'MONO16_2048x2048_FastMode'); 
            src = getselectedsource(vid); 
            src.ExposureTimeControl = 'normal';
            %src.FrameBundleNumber = 2;
            set(src,'ExposureTime',exposure);
%         case 'TISIMAQ'
%             vid = videoinput('tisimaq_r2013_64',1,'RGB24 (1024x768)');
%             src = getselectedsource(vid); 
        case 'Choose Camera...'
            f = msgbox('Choose a camera');
    end
    
    % BRIGHTNESS CODE NOT IN USE FOR THIS CAMERA
    % brightness = round(str2double(get(handles.brightness,'String')));
    % set(src,'Brightness',brightness);
    
    % SET FPS TO 25 FOR PREVIEW -- OTHERWISE SYSTEM WILL LAG DUE TO HIGH
    % BANDWITH FROM CAMERA
   
    set(handles.connectCamera,'UserData',vid);
    
    % CREATE PREVIEW IN WINDOW FRAME
    axes(handles.win);
    hImage = imshow(getsnapshot(vid));
    preview(vid,hImage);
    
    % SIGNAL CAMERA IS CONNECTED
    set(handles.cameraStatus,'ForegroundColor','g');
    
    set(hObject,'Enable','off');
    set(handles.disconnectCamera,'Enable','on');
    
    if isempty(readyToRecord(handles))
        set(handles.start,'Enable','on');
    else
        set(handles.start,'Enable','off');
    end

    catch
        
        disp(('Failed to connect camera'));
        messages = findobj(0,'tag','messages');

        set(messages,'String',('No camera detected'));
        set(hObject,'Enable','on');
        
end

function connectStage_Callback(hObject, eventdata, handles)

stageButtons = [handles.up,handles.left,handles.right,handles.down,handles.bigup,handles.bigleft,handles.bigright,handles.bigdown,handles.centerStage];

set(hObject,'Enable','off');

% COUNTER FOR CONNECTION ATTEMPTS
attemptsRemaining = 2;

% INDICATOR IF STAGE IS CONNECTED
stageConnected = 0;


% CONNECTION CODE
comPort = ['COM',get(handles.comPort,'String')];
stage = serial(comPort,'baudrate',9600,'terminator','CR');
set(stage,'ReadAsyncMode','manual');

while attemptsRemaining>0 && ~stageConnected

    try  
        fopen(stage);
        set(handles.connectStage,'UserData',stage)
        set(handles.messages,'String','Connecting')
        
        pause(3)
        
%         TEST STAGE OUTPUT
        fprintf(stage,'$');
        out = fscanf(stage);
        
        if str2double(out)==0
            
            set(handles.messages,'String','Stage Connected');
            set(handles.stageStatus,'ForegroundColor','g');
            stageConnected = 1;
            fprintf(stage,'SMS,100');
            fprintf(stage,'SAS,100');
            
            set(hObject,'Enable','off');
            set(handles.disconnectStage,'Enable','on');
            
            if isempty(readyToRecord(handles))
                set(handles.start,'Enable','on');
            else
                set(handles.start,'Enable','off');
            end
            
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

if isempty(readyToRecord(handles))
    set(handles.start,'Enable','on');
else
    set(handles.start,'Enable','off');
end

function trackingThreshold_Callback(hObject, eventdata, handles)

function trackingThreshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function calib_Callback(hObject, eventdata, handles)

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
%CHOOSE RED OR GREEN SIDE TRACKING
if strcmp(handles.redTracker.Enable,'off')
    trackType = 'red';
elseif strcmp(handles.greenTracker.Enable,'off')
    trackType = 'green';
end
% MAKE IMAGE DIRECTORY IF NOT ALREADY EXISTENT
tifPath = get(handles.tifPath,'String');
mkdir(tifPath);

% GET TRACKING SETTINGS
calib = str2double(get(handles.calib,'String'));
trackingThreshold = str2double(get(handles.trackingThreshold,'String'));

% GET PRE-MADE VIDEO & STAGE OBJECTS
vid = get(handles.connectCamera,'UserData');
stage = get(handles.connectStage,'UserData');

src = getselectedsource(vid);

% FIND CENTER OF IMAGE FOR CENTERING STAGE
res = get(vid,'VideoResolution');
cameraString = get(handles.cameraName, 'String');
cameraIndex = get(handles.cameraName, 'Value');
   switch cameraString{cameraIndex}
       case 'HAMAMATSU W/ IMAGE SPLITTER'
           if strcmp(trackType, 'red')
               centerOfImage = [1536, 1024];
           elseif strcmp(trackType, 'green')
               centerOfImage = [512, 1024];
           end
       case 'HAMAMATSU'
           centerOfImage = [1024,1024];
       case 'TISIMAQ'
           centerOfImage = .5*res;
       case 'Choose Camera...'
           f = msgbox('Choose a camera.');
   end

   
% GET RECORDING SETTTINGS
rectime = get(handles.rectime,'String'); rectime=str2double(rectime);
framerateIndex = get(handles.framerate,'Value');
framerate = get(handles.framerate, 'Value');
framerateString = get(handles.framerate, 'String');

switch framerateString{framerateIndex}
    case '1'
        framerate = 1;
    case '2'
        framerate = 2;
    case '3'
        framerate = 3;
    case '4'
        framerate = 4;
    case '5'
        framerate = 5;
    case '-'
        m = msgbox('Choose a valid framerate');
end

% PREALLOCATE DISPLACEMENT VALUES
dx = zeros(rectime,1);
dy = zeros(rectime,1);

% PREPARE WINDOW FOR VIDEO
stoppreview(vid);

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

%GET EXPOSURE FROM USER
exposureString = get(handles.exposure, 'String');
exposureIndex = get(handles.exposure, 'value');
switch exposureString{exposureIndex}
    case '1000 ms'
        exposure = 1.0;
    case '500 ms'
        exposure = .5;
    case '250 ms'
        exposure = .4;
    case '200 ms'
        exposure = .2;
    case '100 ms'
        exposure = .1;
end
% SET VIDEO OBJECT SETTINGS FOR RECORDING
triggerconfig(vid,'manual');
set(vid,'LoggingMode','memory','TimeOut',Inf,'TriggerRepeat',rectime-1);
%frameAqc = 1/exposure;
%framegrab = frameAqc/framerate;
%vid.FramesPerTrigger = framerate;
%vid.FrameGrabInterval = framegrab;
setExpFr(vid, exposure,framerate);
cameraString = get(handles.cameraName, 'String');
cameraIndex = get(handles.cameraName, 'Value');
switch cameraString{cameraIndex}
    case 'HAMAMATSU W/ IMAGE SPLITTER'
        src.ExposureTime = exposure;
    case 'HAMAMATSU'
        src.ExposureTime = 1/framerate; 
    case 'TISIMAQ'
        set(src,'FrameRate',framerate);
end


disp('Starting video logging');

start(vid);

% BEGIN STOPWATCH FOR TIME VERIFICATION
testingTime = tic;

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
        mydaq.outputSingleScan(outputString);
        
    end
    
    trigger(vid);
    
%     CREATE BINARY FILES TO WRITE IMAGE AND TIME DATA TO
    tempFramesFile = [tifPath slash 'tempFrameFile_' num2str(i) '.bi'];
    tempFramesFile = fopen(tempFramesFile,'w');
    
    tempTimesFile = [tifPath slash 'tempTimesFile_' num2str(i) '.bi'];
    tempTimesFile = fopen(tempTimesFile,'w');
    
%     COLLECT DATA 
    [f,t] = getdata(vid);
    %disp(size(f(:,:,1,end)));
%     WRITE IMAGE AND TIME DATA
    fwrite(tempFramesFile,f,'uint16'); 
    fwrite(tempTimesFile,t,'double');
   

%     BINARIZE LAST FRAME OF COLLECTED RECORDING
     lastframe = f(:,:,1,end);
     
%     lastframe = imresize(lastframe,.5);
    lastframeBinary = imbinarize(lastframe,trackingThreshold/255);
   
    x = lastframe(1:2048, 20:2048);
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
            if strcmp(trackType,'red')
                cogValue = splitimage_red(lastframe);
               
            elseif strcmp(trackType,'green')
                
                cogValue = splitimage_green(x);
            end
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
    
%     CLOSE BINARY FILES;
end

% DO NOT REMOVE - NECESSARY TO PREVENT BINARY FILES FROM BEING LEFT OPEN ON
% LONG RECORDINGS
testingTime = toc(testingTime);
fclose('all');

% DISPLAY VERIFICATION TIME
disp(['Test time:' num2str(testingTime)]);

set(handles.messages,'String','Recording: 100% complete');

set(handles.forceStop,'Enable','off');

% IF DAQ IS CONNECTED, TURN OFF LIGHTS
if ~isempty(seqs)
    
    outputString = [0 0 0];
    mydaq.outputSingleScan(outputString);
    
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
%times = NaN([1 rectime*1]);
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
  
    currentFramesData = fread(tempFramesFile,Inf,'uint16');
    
    currentFramesData = reshape(currentFramesData,[res(2) res(1) 1 framerate]);
   % currentFramesData = reshape(currentFramesData,[res(2) res(1) 1 1]);
    currentFramesData = uint16(currentFramesData);

    
    for j=1:size(currentFramesData,4)
        
        currentImg = currentFramesData(:,:,:,j);
        currentImg = mat2gray(currentImg);
       % imshow(currentImg);
%     IF RESIZE FACTOR ~1, RESIZE EACH IMAGE FRAME
        if imageResizeFactor ~= 1
            currentImg = imresize(currentImg,.5);
        end
        
%         CREATE IMAGE NAME FROM V/D PREFIX AND FRAME NUMBER
        frameNum = (i-1)*framerate+j;
        %frameNum = (i-1)*1+j;
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
   %times((i-1)*1+1:i*1) = currentTimesData;
    
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
%timesData = [times' 1*ones([length(times) 1])];

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
if get(handles.start, 'Value')==0
    if get(handles.showThresh, 'Value') == 1
        rectime = get(handles.rectime,'String'); rectime=str2double(rectime);
    framerate = get(handles.framerate,'Value');
     vid = get(handles.connectCamera,'UserData');
    framerateIndex = get(handles.framerate,'Value');
framerateString = get(handles.framerate, 'String');

switch framerateString{framerateIndex}
    case '1'
        framerate = 1;
    case '2'
        framerate = 2;
    case '3'
        framerate = 3;
    case '4'
        framerate = 4;
    case '5'
        framerate = 5;
    case '-'
        m = msgbox('Choose a valid framerate');
end



    trackingThreshold = str2double(get(handles.trackingThreshold,'String'));

    if get(handles.showThresh,'Value')
        stoppreview(vid);
        triggerconfig(vid,'manual');
        set(vid,'LoggingMode','memory','TimeOut',Inf,'TriggerRepeat',rectime-1);
        vid.FramesPerTrigger = framerate;
        start(vid);
        while get(handles.showThresh, 'Value') 
            trigger(vid);
            [f,~] = getdata(vid);
            lastframe = f(:,:,1,end);
           
            x = lastframe(1:2048, 20:2048);
            cogValue = splitimage(x);
            imshow(lastframe)
            hold on
            plot(cogValue(1),cogValue(2),'r*');
            hold off
        end
        stop(vid);
        axes(handles.win);
        hImage = imshow(getsnapshot(vid));
        preview(vid,hImage);
    end
    end
end
% STAGE MOVEMENT FUNCTIONS
function moveRelative(s,x,y,enableStage)

if enableStage
    cmd = ['GR,' num2str(x) ',' num2str(y)];
    fprintf(s,cmd);
end

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
%
%
%
%
%
%
%
%
%
%
%
function connectdaq_Callback(hObject, eventdata, handles)

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
    
    mydaq = daq.createSession('ni');
    mydaq.addDigitalChannel('myDAQ1','port0/line7','OutputOnly');
    mydaq.addDigitalChannel('myDAQ1','port0/line6','OutputOnly');
    mydaq.addDigitalChannel('myDAQ1','port0/line5','OutputOnly');
    
    set(handles.messages,'String','Successfully connected to NI MyDAQ');
    set(handles.daqStatus,'ForegroundColor','g');
    set(hObject,'UserData',mydaq,'Enable','off');
    
    set(handles.messages,'String','NI MyDAQ Connected');
    
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

mydaq.removeChannel(1);
delete(mydaq);

set(handles.messages,'String','Disconnected MyDAQ');
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
    
    mydaq.outputSingleScan([1 1 1]);
    set(handles.lightswitch,'UserData',1);
    set(handles.useSequence,'Enable','off');
    
elseif laserState==1 && ~isempty(mydaq)
    
    mydaq.outputSingleScan([0 0 0]);
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
%isReady(3) = strcmp(get(handles.tifPath,'String'),('Directory to save .bmp images'));
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
    




% --- Executes during object creation, after setting all properties.
function sequence1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sequence1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function sequence2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sequence2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function sequence3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sequence3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function repeat1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repeat1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function repeat2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repeat2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function repeat3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repeat3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit47_CreateFcn(hObject, eventdata, handles)
function popupmenu9_CreateFcn(hObject, eventdata, handles)
function edit46_CreateFcn(hObject, eventdata, handles)
function popupmenu10_CreateFcn(hObject, eventdata, handles)
function edit48_CreateFcn(hObject, eventdata, handles)
function edit54_CreateFcn(hObject, eventdata, handles)
function edit53_CreateFcn(hObject, eventdata, handles)
function edit52_CreateFcn(hObject, eventdata, handles)
function edit51_CreateFcn(hObject, eventdata, handles)
function edit50_CreateFcn(hObject, eventdata, handles)
function edit49_CreateFcn(hObject, eventdata, handles)
function edit55_CreateFcn(hObject, eventdata, handles)
function edit45_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in centerStage.


% --- Executes on selection change in e.
function cameraName_Callback(hObject, eventdata, handles)
% hObject    handle to e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns e contents as cell array
%        contents{get(hObject,'Value')} returns selected item from e


% --- Executes during object creation, after setting all properties.
function cameraName_CreateFcn(hObject, eventdata, handles)

% hObject    handle to e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function e_CreateFcn(hObject, eventdata, handles)

% hObject    handle to e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in exposure.
function exposure_Callback(hObject, eventdata, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns exposure contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exposure
framerate = findobj(0,'tag','framerate');
framerateString = get(framerate, 'String');

%framerateString{3}
%framerateString{4}
%framerateString{5}
exposure = findobj(0,'tag','exposure');
exposureString = get(exposure, 'String')
exposureIndex = get(exposure, 'value')

switch exposureString{exposureIndex}
    case '1000 ms'
        framerateString{1} = '1';
        framerateString{2} = '-';
        framerateString{3} = '-';  
        framerateString{4} = '-';
        framerateString{5} = '-';
        framerate = findobj(0,'tag','framerate')
        set(framerate, 'String', framerateString);
        
    case '500 ms'
        framerateString{1} = '1';
        framerateString{2} = '2';
        framerateString{3} = '-';  
        framerateString{4} = '-';
        framerateString{5} = '-';
        framerate = findobj(0,'tag','framerate')
        set(framerate, 'String', framerateString);
    case '250 ms'
        framerateString{1} = '1';
        framerateString{2} = '2';
        framerateString{3} = '3';  
        framerateString{4} = '-';
        framerateString{5} = '-';
        framerate = findobj(0,'tag','framerate')
        set(framerate, 'String', framerateString);
        
    case '200 ms'
        framerateString{1} = '1';
        framerateString{2} = '2';
        framerateString{3} = '3';  
        framerateString{4} = '4';
        framerateString{5} = '-';
        framerate = findobj(0,'tag','framerate');
        set(framerate, 'String', framerateString);
        
    case '100 ms'
        framerateString{1} = '1';
        framerateString{2} = '2';
        framerateString{3} = '3';  
        framerateString{4} = '4';
        framerateString{5} = '5';
        framerate = findobj(0,'tag','framerate');
        set(framerate, 'String', framerateString);
end

% --- Executes during object creation, after setting all properties.
function exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in greenTracker.
function greenTracker_Callback(hObject, eventdata, handles)
% hObject    handle to greenTracker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.redTracker, 'Enable', 'on');
set(hObject, 'Enable', 'off');
    

% --- Executes on button press in redTracker.
function redTracker_Callback(hObject, eventdata, handles)
% hObject    handle to redTracker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.greenTracker, 'Enable', 'on');
set(hObject, 'Enable', 'off');
