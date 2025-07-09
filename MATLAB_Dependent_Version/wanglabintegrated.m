function varargout = wanglabintegrated(varargin)
% WANGLABINTEGRATED MATLAB code for wanglabintegrated.fig
%      WANGLABINTEGRATED, by itself, creates a new WANGLABINTEGRATED or raises the existing
%      singleton*.
%
%      H = WANGLABINTEGRATED returns the handle to a new WANGLABINTEGRATED or the handle to
%      the existing singleton*.
%
%      WANGLABINTEGRATED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WANGLABINTEGRATED.M with the given input arguments.
%
%      WANGLABINTEGRATED('Property','Value',...) creates a new WANGLABINTEGRATED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wanglabintegrated_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wanglabintegrated_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wanglabintegrated

% Last Modified by GUIDE v2.5 24-May-2023 09:48:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wanglabintegrated_OpeningFcn, ...
                   'gui_OutputFcn',  @wanglabintegrated_OutputFcn, ...
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


% --- Executes just before wanglabintegrated is made visible.
function wanglabintegrated_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wanglabintegrated (see VARARGIN)

% Choose default command line output for wanglabintegrated
handles.output = hObject;

% Load the background image
backgroundImage = imread('Wormtracker_logo.tif'); % Replace 'your_image.jpg' with the path to your image file
backgroundImageAP=imread('APAnalyzer_logo.tif');
backgroundImageSleep=imread('Sleeptracker_logo.tif');

handles.Wormtracker.Units='pixels';
handles.APanalyzer.Units='pixels';
handles.sleeptracker.Units='pixels';
backgroundImage = imresize(backgroundImage,fliplr(handles.Wormtracker.Position(1,3:4)));
backgroundImageAP = imresize(backgroundImageAP,fliplr(handles.APanalyzer.Position(1,3:4)));
backgroundImageSleep= imresize(backgroundImageSleep,fliplr(handles.sleeptracker.Position(1,3:4)));
handles.Wormtracker.Units='normalized';
handles.APanalyzer.Units='normalized';
handles.sleeptracker.Units='normalized';
handles.Wormtracker.CData=backgroundImage;
handles.APanalyzer.CData=backgroundImageAP;
handles.sleeptracker.CData=backgroundImageSleep;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wanglabintegrated wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = wanglabintegrated_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Wormtracker.
function Wormtracker_Callback(hObject, eventdata, handles)
% hObject    handle to Wormtracker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wormTrackMenu


% --- Executes on button press in sleeptracker.
function sleeptracker_Callback(hObject, eventdata, handles)
% hObject    handle to sleeptracker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SleepTracker


% --- Executes on button press in APanalyzer.
function APanalyzer_Callback(hObject, eventdata, handles)
% hObject    handle to APanalyzer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
APana


% --- Executes during object creation, after setting all properties.
function Wormtracker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Wormtracker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
