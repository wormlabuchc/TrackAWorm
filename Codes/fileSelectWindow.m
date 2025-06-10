function varargout = fileSelectWindow(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fileSelectWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @fileSelectWindow_OutputFcn, ...
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

function fileSelectWindow_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
if ~isempty(varargin)
    set(handles.splinePath,'String',varargin{1});
    set(handles.stagePath,'String',varargin{2});
    set(handles.frameSelection,'String',varargin{3});
end
guidata(hObject, handles);
uiwait

function varargout = fileSelectWindow_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output.splinePath;
varargout{2} = handles.output.stagePath;
varargout{3} = handles.output.frameSelection;
delete(gcf)


function splinePath_Callback(hObject, eventdata, handles)

function splinePath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stagePath_Callback(hObject, eventdata, handles)

function stagePath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function browseSpline_Callback(hObject, eventdata, handles)
persistent pathname
if isempty(pathname)
    [filename pathname]=uigetfile('*.txt','Open Spline File');
else
    [filename pathname]=uigetfile('*.txt','Open Spline File',pathname);
end
if ~isnumeric(filename) && ~isnumeric(pathname)
    set(handles.splinePath,'String',[pathname filename]);
    wormName=filename(1:end-16);
    stageName=[pathname wormName '\' wormName '.txt'];
    set(handles.stagePath,'String',stageName);
end

function browseStage_Callback(hObject, eventdata, handles)
[filename pathname]=uigetfile('*.txt','Open Stage File');
if ~isnumeric(filename) && ~isnumeric(pathname)
    set(handles.stagePath,'String',[pathname filename]);
end

function frameSelection_Callback(hObject, eventdata, handles)

function frameSelection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function done_Callback(hObject, eventdata, handles)
splinePath=get(handles.splinePath,'String');
stagePath=get(handles.stagePath,'String');
frameSelection=get(handles.frameSelection,'String');
if ~isempty(str2num(frameSelection))
    frameSelection=str2num(frameSelection);
end
handles.output.splinePath=splinePath;
handles.output.stagePath=stagePath;
handles.output.frameSelection=frameSelection;
guidata(hObject,handles);
uiresume


function splinePath_KeyPressFcn(hObject, eventdata, handles)
if strcmp(eventdata.Key,'return')
    pause(.5)
    flashBox(handles.stagePath);
    pathname=get(handles.splinePath,'String');
    lastSlash=find(pathname=='\');
    lastSlash=lastSlash(end);
    wormName=pathname(lastSlash+1:end-16);
    stageName=[pathname(1:lastSlash) wormName '\' wormName '.txt'];
    set(handles.stagePath,'String',stageName);
end
