function varargout = cutFrames_gui(varargin)
% CUTFRAMES_GUI M-file for cutFrames_gui.fig
%      CUTFRAMES_GUI, by itself, creates a new CUTFRAMES_GUI or raises the existing
%      singleton*.
%
%      H = CUTFRAMES_GUI returns the handle to a new CUTFRAMES_GUI or the handle to
%      the existing singleton*.
%
%      CUTFRAMES_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CUTFRAMES_GUI.M with the given input arguments.
%
%      CUTFRAMES_GUI('Property','Value',...) creates a new CUTFRAMES_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cutFrames_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cutFrames_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cutFrames_gui

% Last Modified by GUIDE v2.5 28-Jul-2010 15:06:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cutFrames_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @cutFrames_gui_OutputFcn, ...
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


% --- Executes just before cutFrames_gui is made visible.
function cutFrames_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cutFrames_gui (see VARARGIN)

% Choose default command line output for cutFrames_gui
if ~isempty(varargin)
    set(handles.tifPath,'String',varargin{1})
end
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cutFrames_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cutFrames_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function tifPath_Callback(hObject, eventdata, handles)
% hObject    handle to tifPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tifPath as text
%        str2double(get(hObject,'String')) returns contents of tifPath as a double


% --- Executes during object creation, after setting all properties.
function tifPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tifPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname=uigetdir();
if ~isnumeric(pathname)
    set(handles.tifPath,'String',pathname)
end

% --- Executes on button press in cut3.
function cut3_Callback(hObject, eventdata, handles)
% hObject    handle to cut3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname=get(handles.tifPath,'String');
mkdir([pathname '\removed']);
filelist=dir([pathname '\*.bmp']);
for i=1:length(filelist)
    if mod(i-1,5)~=0
        movefile([pathname '\' filelist(i).name],[pathname '\removed'])
    end
end
disp('Done')

% --- Executes on button press in cut1.
function cut1_Callback(hObject, eventdata, handles)
% hObject    handle to cut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname=get(handles.tifPath,'String');
mkdir([pathname '\removed']);
filelist=dir([pathname '\*.bmp']);
for i=1:length(filelist)
    if mod(i-1,15)~=0
        movefile([pathname '\' filelist(i).name],[pathname '\removed'])
    end
end
disp('Done')