function varargout = brightFieldTracker(varargin)
% BRIGHTFIELDTRACKER MATLAB code for brightFieldTracker.fig
%      BRIGHTFIELDTRACKER, by itself, creates a new BRIGHTFIELDTRACKER or raises the existing
%      singleton*.%
%      H = BRIGHTFIELDTRACKER returns the handle to a new BRIGHTFIELDTRACKER or the handle to
%      the existing singleton*.
%
%      BRIGHTFIELDTRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRIGHTFIELDTRACKER.M with the given input arguments.
%
%      BRIGHTFIELDTRACKER('Property','Value',...) creates a new BRIGHTFIELDTRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before brightFieldTracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to brightFieldTracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help brightFieldTracker

% Last Modified by GUIDE v2.5 31-May-2019 14:09:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @brightFieldTracker_OpeningFcn, ...
                   'gui_OutputFcn',  @brightFieldTracker_OutputFcn, ...
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


% --- Executes just before brightFieldTracker is made visible.
function brightFieldTracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to brightFieldTracker (see VARARGIN)

% Choose default command line output for brightFieldTracker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes brightFieldTracker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = brightFieldTracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in b_calibrate.
function b_calibrate_Callback(hObject, eventdata, handles)
% hObject    handle to b_calibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
calibration_gui

% --- Executes on button press in b_record.
function b_record_Callback(hObject, eventdata, handles)
% hObject    handle to b_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
launch

% --- Executes on button press in b_playback.
function b_playback_Callback(hObject, eventdata, handles)
% hObject    handle to b_playback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
playback_gui

% --- Executes on button press in b_analyze.
function b_analyze_Callback(hObject, eventdata, handles)
% hObject    handle to b_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
analysis_gui

% --- Executes on button press in b_batchSpline.
function b_batchSpline_Callback(hObject, eventdata, handles)
% hObject    handle to b_batchSpline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batchSpline_gui

% --- Executes on button press in b_batchAnalyze.
function b_batchAnalyze_Callback(hObject, eventdata, handles)
% hObject    handle to b_batchAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batchAnalyze_gui

% --- Executes on button press in b_fitSpline.
function b_fitSpline_Callback(hObject, eventdata, handles)
% hObject    handle to b_fitSpline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)x
batchTrack_gui

% --- Executes on button press in b_curveAnalyzer.
function b_curveAnalyzer_Callback(hObject, eventdata, handles)
% hObject    handle to b_curveAnalyzer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curveAnalyzer
