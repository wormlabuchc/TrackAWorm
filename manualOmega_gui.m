function varargout = manualOmega_gui(varargin)
% MANUALOMEGA_GUI MATLAB code for manualOmega_gui.fig
%      MANUALOMEGA_GUI, by itself, creates a new MANUALOMEGA_GUI or raises the existing
%      singleton*.
%
%      H = MANUALOMEGA_GUI returns the handle to a new MANUALOMEGA_GUI or the handle to
%      the existing singleton*.
%
%      MANUALOMEGA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALOMEGA_GUI.M with the given input arguments.
%
%      MANUALOMEGA_GUI('Property','Value',...) creates a new MANUALOMEGA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manualOmega_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manualOmega_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manualOmega_gui

% Last Modified by GUIDE v2.5 22-Aug-2024 12:38:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manualOmega_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @manualOmega_gui_OutputFcn, ...
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


% --- Executes just before manualOmega_gui is made visible.
function manualOmega_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manualOmega_gui (see VARARGIN)

% Choose default command line output for manualOmega_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
file = varargin{2};
img = imread(file);
img = img(1:end,1:end,1);
axes(handles.axes);
h = imshow(img);

set(handles.omegaFit,'UserData',h);

set(handles.manualOmegaText,'UserData',varargin{2});



% UIWAIT makes manualOmega_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
uiwait

% --- Outputs from this function are returned to the command line.
function varargout = manualOmega_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;







% --- Executes on button press in omegaFit.
function omegaFit_Callback(hObject, eventdata, handles)
global temp;
a=temp;
% hObject    handle to omegaFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file = get(handles.manualOmegaText,'UserData');
img = imread(file);
worm = img(1:end,1:end,1);
res = size(worm);
h = get(handles.omegaFit,'UserData');


%Colors complemented
wormComplement=imcomplement(worm);

%Get the binary image
wormBinary=imbinarize(wormComplement,'adaptive');


% %Fill the small gaps with disk shaped object
se=strel('disk',3);
wormBinary=imclose(wormBinary,se);
wormBinary=bwareafilt(wormBinary,1);



%Get the worm skeleton from the binary image
wormOut=bwskel(wormBinary,'MinBranchLength',20);

if a==0
    temp=temp+1;
    updated_matrix = updateWormSkeleton1(wormOut);
    [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix);
elseif a==1
    temp=temp+1;
    updated_matrix = updateWormSkeleton2(wormOut);
    [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix);
elseif a==2
    temp=temp+1;
    updated_matrix = updateWormSkeleton3(wormOut);
    [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix);
    
elseif a==3
    temp=temp+1;
    updated_matrix = updateWormSkeleton4(wormOut);
    [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix);
    
elseif a==4
    temp=temp+1;
    updated_matrix = updateWormSkeleton5(wormOut);
    [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix);
    
elseif a==5
    temp=temp+1;
    updated_matrix = updateWormSkeleton6(wormOut);
    [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix);
   
elseif a==6
    temp=temp+1;
    updated_matrix = updateWormSkeleton7(wormOut);
    [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix);
    
elseif a==7
    updated_matrix = updateWormSkeleton8(wormOut);
    [xCenterLine,yCenterLine,xcross,ycross] = prepOmega(worm,updated_matrix);  
   
    
end

handles.output = [xCenterLine;yCenterLine;xcross;ycross];

%set(handles.doneOmega,[xCenterLine;yCenterLine;xcross;ycross]);


guidata(hObject,handles);
uiresume








% --- Executes on button press in doneOmega.
function doneOmega_Callback(hObject, eventdata, handles)
% hObject    handle to doneOmega (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'UserData',1);
set(hObject,'Enable','off');
