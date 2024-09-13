function varargout = bendCursor_gui(varargin)
% BENDCURSOR_GUI M-file for bendCursor_gui.fig
%      BENDCURSOR_GUI, by itself, creates a new BENDCURSOR_GUI or raises the existing
%      singleton*.
%
%      H = BENDCURSOR_GUI returns the handle to a new BENDCURSOR_GUI or the handle to
%      the existing singleton*.
%
%      BENDCURSOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BENDCURSOR_GUI.M with the given input arguments.
%
%      BENDCURSOR_GUI('Property','Value',...) creates a new BENDCURSOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bendCursor_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bendCursor_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bendCursor_gui

% Last Modified by GUIDE v2.5 23-Jun-2010 15:05:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bendCursor_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bendCursor_gui_OutputFcn, ...
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


% --- Executes just before bendCursor_gui is made visible.
function bendCursor_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bendCursor_gui (see VARARGIN)

% Choose default command line output for bendCursor_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% figure;

axes(handles.win);
plot(varargin{1},varargin{2}) %plot time vs bend

% ax=gca;
% roi=drawpoint(ax);

hold on
line([0 max(varargin{1})],[0 0],'Color','k')
hold off
title('Hold the ''Alt'' key when clicking the graph to create cursors.')
%p=get(gcf,'Position');
%set(gcf,'Position',[100 100 1200 800]);
datacursormode on
% dcm = datacursormode;
% dcm.Enable = 'on';
% set(dcm,'DisplayStyle','datatip','FontSize',4,'SnapToDataVertex','off')

% dcm.DisplayStyle = 'window';
%set(hObject,'Backgroundalpha',0);
 
uiwait
% UIWAIT makes bendCursor_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bendCursor_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(gcf)

% --- Executes on button press in finish.
function finish_Callback(hObject, eventdata, handles)
% hObject    handle to finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dcm_obj = datacursormode(gcf);
% alldatacursors = findall(gcf, 'type', 'hggroup', '-property', 'FontSize');
% set(alldatacursors,'FontSize',4);
% set(alldatacursors,'FontName','Times');
% set(alldatacursors, 'FontWeight', 'bold');
info_struct = getCursorInfo(dcm_obj);
angles=[];
for i=1:length(info_struct)
    angles=[angles;info_struct(i).Position(2)];
end
posAngles=angles(angles>0);
negAngles=angles(angles<0);

if isempty(posAngles)
    posAngles = 0;
end
if isempty(negAngles)
    negAngles = 0;
end

excursion=mean(posAngles)-mean(negAngles);
handles.output=excursion;
guidata(hObject,handles);
uiresume
