function varargout = pickVD(varargin)
% PICKVD MATLAB code for pickVD.fig
%      PICKVD, by itself, creates a new PICKVD or raises the existing
%      singleton*.
%
%      H = PICKVD returns the handle to a new PICKVD or the handle to
%      the existing singleton*.
%
%      PICKVD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PICKVD.M with the given input arguments.
%
%      PICKVD('Property','Value',...) creates a new PICKVD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pickVD_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pickVD_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pickVD

% Last Modified by GUIDE v2.5 14-Mar-2014 13:28:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pickVD_OpeningFcn, ...
                   'gui_OutputFcn',  @pickVD_OutputFcn, ...
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


% --- Executes just before pickVD is made visible.
function pickVD_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pickVD (see VARARGIN)

% Choose default command line output for pickVD
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

img=varargin{1};
axes(handles.vdFig);
hImage=imshow(img);
set(hImage,'ButtonDownFcn',{@click,handles});
pathname=varargin{2};
set(handles.vdSavePath,'UserData',pathname);
set(handles.vdSavePath,'String',['Save path: ' pathname]);


% UIWAIT makes pickVD wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pickVD_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved -  to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse press over axes background.
function vdFig_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to vdFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function click(hObject, eventdata, handles)
loc=get(gca,'CurrentPoint');
loc=loc(1,1:2);
x=loc(1); y=loc(2);

set(handles.vdFig,'UserData',[x y]);
axes(handles.vdFig); hold on
xres=get(handles.vdFig,'XLim');
yres=get(handles.vdFig,'YLim');
xres=xres(2)-xres(1);
yres=yres(2)-yres(1);
plot(x,y,'r+','MarkerSize',20)
hold off