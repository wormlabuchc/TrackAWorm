function varargout = darkFieldTracker(varargin)
% DARKFIELDTRACKER MATLAB code for darkFieldTracker.fig
%      DARKFIELDTRACKER, by itself, creates a new DARKFIELDTRACKER or raises the existing
%      singleton*.
%
%      H = DARKFIELDTRACKER returns the handle to a new DARKFIELDTRACKER or the handle to
%      the existing singleton*.
%
%      DARKFIELDTRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DARKFIELDTRACKER.M with the given input arguments.
%
%      DARKFIELDTRACKER('Property','Value',...) creates a new DARKFIELDTRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before darkFieldTracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to darkFieldTracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help darkFieldTracker

% Last Modified by GUIDE v2.5 12-Jun-2019 15:45:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @darkFieldTracker_OpeningFcn, ...
                   'gui_OutputFcn',  @darkFieldTracker_OutputFcn, ...
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


% --- Executes just before darkFieldTracker is made visible.
function darkFieldTracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to darkFieldTracker (see VARARGIN)

% Choose default command line output for darkFieldTracker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes darkFieldTracker wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = darkFieldTracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in d_calibrate.
function d_calibrate_Callback(hObject, eventdata, handles)
% hObject    handle to d_calibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
calibration_DF


% --- Executes on button press in d_record.
function d_record_Callback(hObject, eventdata, handles)
% hObject    handle to d_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
record_DF



% --- Executes on button press in d_playback.
function d_playback_Callback(hObject, eventdata, handles)
% hObject    handle to d_playback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
playback_gui


% --- Executes on button press in analysis.
function analysis_Callback(hObject, eventdata, handles)
% hObject    handle to analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
analysis_DF


% --- Executes on button press in fitRegion.
function fitRegion_Callback(hObject, eventdata, handles)
% hObject    handle to fitRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
fitRegion


% --------------------------------------------------------------------
function test_Callback(hObject, eventdata, handles)
% hObject    handle to test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
