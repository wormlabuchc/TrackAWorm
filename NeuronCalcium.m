function varargout = NeuronCalcium(varargin)
% NEURONCALCIUM MATLAB code for NeuronCalcium.fig
%      NEURONCALCIUM, by itself, creates a new NEURONCALCIUM or raises the existing
%      singleton*.
%
%      H = NEURONCALCIUM returns the handle to a new NEURONCALCIUM or the handle to
%      the existing singleton*.
%
%      NEURONCALCIUM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEURONCALCIUM.M with the given input arguments.
%
%      NEURONCALCIUM('Property','Value',...) creates a new NEURONCALCIUM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NeuronCalcium_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NeuronCalcium_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NeuronCalcium

% Last Modified by GUIDE v2.5 27-Apr-2023 18:35:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NeuronCalcium_OpeningFcn, ...
                   'gui_OutputFcn',  @NeuronCalcium_OutputFcn, ...
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


% --- Executes just before NeuronCalcium is made visible.
function NeuronCalcium_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NeuronCalcium (see VARARGIN)

% Choose default command line output for NeuronCalcium
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NeuronCalcium wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NeuronCalcium_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RISAnalysis.
function RISAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to RISAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gui = figure('Name','RIS Analysis','Position',[100 50 1800 750],'IntegerHandle', 'off', 'Resize', 'off','Units','pixels');
invokeRISana(gui)
function invokeRISana(gui)
       clf(gui);
       RISana(gui);

% --- Executes on button press in RISRecorder.
function RISRecorder_Callback(hObject, eventdata, handles)
% hObject    handle to RISRecorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gui = figure('Name','RIS Recorder','Position',[100 50 1800 750],'IntegerHandle', 'off', 'Resize', 'off','Units','pixels');
invokeRIS(gui)
function invokeRIS(gui)
       clf(gui);
       RISrecorder(gui);


% --- Executes on button press in back3.
function back3_Callback(hObject, eventdata, handles)
% hObject    handle to back3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wanglabintegrated
closereq()
