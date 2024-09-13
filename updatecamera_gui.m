function varargout = updatecamera_gui(varargin)
% Begin initialization code - DO NOT EDIT
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
% End initialization code - DO NOT EDIT

function camera_gui_OpeningFcn(hObject, eventdata, handles, varargin)
global xDisplacement yDisplacement
handles.output = hObject;
guidata(hObject, handles);

function varargout = camera_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function connectCamera_Callback(hObject, eventdata, handles)
vid = videoinput('tisimaq_r2013_64',1,'RGB24 (1024x768)');
src=getselectedsource(vid);
triggerconfig(vid,'manual');
set(vid,'LoggingMode','memory')
set(src,'FrameRate','15')
set(vid,'TimeOut',30)
set(handles.connectCamera,'UserData',vid);
brightness=round(str2double(get(handles.brightness,'String')));
exposure=round(str2double(get(handles.exposure,'String')));
framerate=get(handles.fps,'Value');
switch framerate
    case 1
        FrameGrabInterval=1;
        FramesPerTrigger=15;
    case 2
        FrameGrabInterval=3;
        FramesPerTrigger=5;
    case 3
        FrameGrabInterval=5;
        FramesPerTrigger=3;
    case 4
        FrameGrabInterval=15;
        FramesPerTrigger=1;
end
set(src,'Brightness',brightness);
set(src,'AutoExposure',exposure);
set(src,'FrameRate','15');
set(vid,'FrameGrabInterval',FrameGrabInterval)
set(vid,'FramesPerTrigger',FramesPerTrigger)
axes(handles.win);
hImage=image;
preview(vid,hImage);
set(handles.cameraStatus,'ForegroundColor','g')

function connectStage_Callback(hObject, eventdata, handles)
try
    stage=serial('COM3','baudrate',9600,'terminator','CR');
    stage.ReadAsyncMode='manual';    %create the serial port
    fopen(stage);
    set(handles.connectStage,'UserData',stage)
    set(handles.messages,'String','Connecting')
    pause(3)    %pause for 3 seconds because the stage needs a second to start up
    fprintf(stage,'$'); out=fscanf(stage); %test the stage output
    if str2double(out)==0
        set(handles.messages,'String','Stage Connected')
        set(handles.stageStatus,'ForegroundColor','g')
        fprintf(stage,'SMS,100');
        fprintf(stage,'SAS,100');
    else
        msgbox('Please Check Connections--Stage Not Detected.  See Matlab Command Window for Debug.');
        stage
        disp('Stage output mismatch.  Try again.')
    end
catch
    msgbox('Please Check Connections--Stage Not Detected.  See Matlab Command Window for Debug.');
    stage
    disp('Crash during connection phase detected.')
end

function start_Callback(hObject, eventdata, handles)
global xDisplacement yDisplacement  %I don't think these need to be global anymore.
set(handles.forceStop,'UserData',[])
calibx=str2double(get(handles.calibx,'String'));
caliby=str2double(get(handles.caliby,'String'));
vid=get(handles.connectCamera,'UserData');
% filelist=get(handles.mainpanel,'UserData');
stage=get(handles.connectStage,'UserData');
xDisplacement=0; yDisplacement=0;
% setPos(handles,[xDisplacement yDisplacement])
rectime=get(handles.rectime,'String'); rectime=str2double(rectime);
dx=zeros(rectime,1);
dy=zeros(rectime,1);
% dx(1)=0;dy(1)=0;
stoppreview(vid)
set(vid,'TriggerRepeat',rectime)
set(handles.messages,'String','Tracking and Acquiring')
axes(handles.win);
start(vid)
pause(4)
for i=1:rectime
    trigger(vid);
    wait(vid,30,'logging')
    [f,t]=getdata(vid);
    eval(['f' num2str(i) '=f;']);
    eval(['t' num2str(i) '=t;']);
    lastframe=f(:,:,1,end); %find cog with a quarter of the resolution for speed
    imshow(lastframe)
    lastframe(lastframe>80)=255;    %threshold at 80 for a simple contrast enhancement
    lastframe(lastframe<=80)=0;
%     lastframe=lastframe<120;
%     figure;imshow(lastframe);
    [cogX,cogY]=cog(lastframe);
    [xDisplacement,yDisplacement]=centerWorm(stage,cogX,cogY,calibx,caliby);    %we are going to center the image based on um, not pixels
    dx(i)=xDisplacement;
    dy(i)=yDisplacement;
    stop=checkStopButton(handles.forceStop);
    if stop        
        set(handles.messages,'String','Cancelling... Please Wait')
        pause(2)
        disconnectCamera_Callback(hObject, eventdata, handles);
        set(handles.messages,'String','Cancelled.')
        return
    end
end
% stop(vid)
set(handles.messages,'String','Saving to bmps')
pause(.5)
m=1;
tifPath=get(handles.tifPath,'String');
mkdir(tifPath);
for i=1:rectime %from 1 to recording time
    for j=1:length(f1(1,1,1,:)) %from 1 to the total frames in each trigger
        if m<10
            number=['00' num2str(m)];
        elseif m>=10 && m<100
            number=['0' num2str(m)];
        elseif m>=100
            number=[num2str(m)];
        end
        name=[tifPath '\img' number '.bmp'];
        eval(['currImg=f' num2str(i) '(:,:,:,j);']);
        imwrite(currImg,name,'bmp');
        m=m+1;
    end
end

set(handles.messages,'String','Saving coordinate data')

labels=[{'%%delta-x'} {'%%delta-y'}];
savePath=get(handles.exportPath,'String');
dx(isnan(dx))=0;  dy(isnan(dy))=0;
dx=num2cell(dx); dy=num2cell(-dy);  
%dy should be flipped, since the convention for dy is different in the 
%"normal" coordinate system compared to the image system
data=[dx dy];
data=[{0} {0};data];
saveDataMatrix(labels,data,savePath);
set(handles.messages,'String','Saving Complete')

function apply_Callback(hObject, eventdata, handles)
vid=get(handles.connectCamera,'UserData');
src=getselectedsource(vid);
brightness=round(str2double(get(handles.brightness,'String')));
exposure=round(str2double(get(handles.exposure,'String')));
framerate=get(handles.fps,'Value');
switch framerate
    case 1
        FrameGrabInterval=1;
        FramesPerTrigger=15;
    case 2
        FrameGrabInterval=3;
        FramesPerTrigger=5;
    case 3
        FrameGrabInterval=5;
        FramesPerTrigger=3;
    case 4
        FrameGrabInterval=15;
        FramesPerTrigger=1;
end
set(src,'Brightness',brightness);
set(src,'AutoExposure',exposure);
set(src,'FrameRate','15');
set(vid,'FrameGrabInterval',FrameGrabInterval)
set(vid,'FramesPerTrigger',FramesPerTrigger)    

function fps_Callback(hObject, eventdata, handles)

function fps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rectime_Callback(hObject, eventdata, handles)

function rectime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function adjust_Callback(hObject, eventdata, handles)
showFrame(1,handles);

function tifPath_Callback(hObject, eventdata, handles)

function tifPath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browse_Callback(hObject, eventdata, handles)
pathname=uigetdir();
if ~isnumeric(pathname)
    set(handles.tifPath,'String',pathname)
    lastSlash=find(pathname=='\');
    lastSlash=lastSlash(end);
    stageName=[pathname '\' pathname(lastSlash+1:end) '.txt'];
    set(handles.exportPath,'String',stageName);
end

function caliby_Callback(hObject, eventdata, handles)

function caliby_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function calibx_Callback(hObject, eventdata, handles)

function calibx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function disconnectCamera_Callback(hObject, eventdata, handles)
vid=get(handles.connectCamera,'UserData');
stop(vid)
stoppreview(vid)
set(handles.cameraStatus,'ForegroundColor','r')
set(handles.messages,'String','Camera Disconnected')
clear vid

function disconnectStage_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fclose(stage)
status=stage.Status;
if strcmp(status,'closed')
    set(handles.messages,'String','Stage Disconnected')
    set(handles.stageStatus,'ForegroundColor','r')
else
    msgbox('Could Not Disconnect.  See Matlab Command Window for Debug.')
    stage
end

function exportPath_Callback(hObject, eventdata, handles)


function exportPath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exportBrowse_Callback(hObject, eventdata, handles)
[filename pathname]=uiputfile('*.txt','Save Export File');
if ~isnumeric(filename) && ~isnumeric(pathname)
    set(handles.exportPath,'String',[pathname filename]);
end

%---------------------------Helper Functions-------------------------------

function filelist=listTifsInFolder(path)
%this function will make a cell array of the Tif files in a folder.
list=dir([path '\*.Tif']);
filelist=[];
for i=1:length(list)
    filelist=[filelist; {[path '\' list(i).name]}];
end

function showFrame(number,handles)
filelist=get(handles.mainpanel,'UserData');

clow=get(handles.clow,'String');    clow=str2double(clow);
chigh=get(handles.chigh,'String');  chigh=str2double(chigh);

imgContrast=prepImage(filelist{number},clow,chigh);
axes(handles.win)
imshow(imgContrast);
set(handles.win,'UserData',imgContrast);

function setPos(handles,position)
set(handles.X,'String',num2str(position(1)));
set(handles.Y,'String',num2str(position(2)));
set(handles.X,'UserData',position(1));
set(handles.Y,'UserData',position(2));

function [x,y]=getPos(handles)
x=get(handles.X,'UserData');
y=get(handles.Y,'UserData');

function [x,y]=cog(img)
img=double(img);
img=255-img;
img=img/max(max(img));
s=sum(sum(img));
xt=zeros(1,length(img(1,:)));
for i=1:length(img(1,:))
    xt(i)=sum(img(:,i))*i;
end
x=sum(xt)/s;
yt=zeros(1,length(img(:,1)));
for i=1:length(img(:,1))
    yt(i)=sum(img(i,:))*i;
end
y=sum(yt)/s;

%-----------------------Stage driver functions-----------------------------
function [xDisplacement,yDisplacement]=centerWorm(stage,cogX,cogY,calibx,caliby)
centerOfImageX=320; centerOfImageY=240; %since resolution is 640x480
xMove=calibx*(centerOfImageX-cogX);  %if <0, move left; if >0, move right.  xMove is in micrometers, not pixels
yMove=caliby*(centerOfImageY-cogY);  %if <0, move down; if >0, move up.  yMove is in um.
disp(['Moved ' num2str(xMove) ',' num2str(yMove)]);
xDisplacement=-xMove; yDisplacement=-yMove;  
%the signs are reversed to reflect movement of the coordinate system, not camera.
moveRelative(stage,xMove,yMove);

function moveLeft(s,n)
cmd=['L,' num2str(n)];
fprintf(s,cmd);

function moveRight(s,n)
cmd=['R,' num2str(n)];
fprintf(s,cmd);

function moveUp(s,n)
cmd=['F,' num2str(n)];
fprintf(s,cmd);

function moveDown(s,n)
cmd=['B,' num2str(n)];
fprintf(s,cmd);

function moveRelative(s,x,y)
cmd=['GR,' num2str(x) ',' num2str(y)];
fprintf(s,cmd);
%----------------------End Stage Driver Functions--------------------------

%----------------Camera Adjustment Functions-------------------------------
function up_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'F,10');

function left_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'L,10');

function right_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'R,10');

function down_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'B,10');

function bigup_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'F,100');

function bigdown_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'B,100');

function bigright_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'R,100');

function bigleft_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'L,100');

function centerStage_Callback(hObject, eventdata, handles)
stage=get(handles.connectStage,'UserData');
fprintf(stage,'G,0,0');

%------------End Camera Adjustment Functions-------------------------------



function brightness_Callback(hObject, eventdata, handles)

function brightness_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function exposure_Callback(hObject, eventdata, handles)

function exposure_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tifPath_KeyPressFcn(hObject, eventdata, handles)
if strcmp(eventdata.Key,'return')
    pause(.5)
    flashBox(handles.exportPath)
    pathname=get(handles.tifPath,'String');
    lastSlash=find(pathname=='\');
    lastSlash=lastSlash(end);
    stageName=[pathname '\' pathname(lastSlash+1:end) '.txt'];
    set(handles.exportPath,'String',stageName);
end


function forceStop_Callback(hObject, eventdata, handles)
set(handles.forceStop,'UserData',1);

function stop=checkStopButton(stopButton)
stop=get(stopButton,'UserData');
if stop==1
    stop=1;
else
    stop=0;
end
