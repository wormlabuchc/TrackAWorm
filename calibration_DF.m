 function varargout = calibration_DF(varargin)
% CALIBRATION_DF MATLAB code for calibration_DF.fig
%      CALIBRATION_DF, by itself, creates a new CALIBRATION_DF or raises the existing
%      singleton*.
%
%      H = CALIBRATION_DF returns the handle to a new CALIBRATION_DF or the handle to
%      the existing singleton*.
%
%      CALIBRATION_DF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATION_DF.M with the given input arguments.
%
%      CALIBRATION_DF('Property','Value',...) creates a new CALIBRATION_DF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calibration_DF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calibration_DF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calibration_DF

% Last Modified by GUIDE v2.5 05-Jun-2019 10:06:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibration_DF_OpeningFcn, ...
                   'gui_OutputFcn',  @calibration_DF_OutputFcn, ...
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


% --- Executes just before calibration_DF is made visible.
function calibration_DF_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calibration_DF (see VARARGIN)

% Choose default command line output for calibration_DF
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calibration_DF wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = calibration_DF_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in d_connectCamera.
function d_connectCamera_Callback(hObject, eventdata, handles)
% hObject    handle to d_connectCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%THIS FUNCTION CONNECTS THE CAMERA AND SETS IT TO THE FRAME 
%try
%     vid = videoinput('hamamatsu', 1); 
%     src = getselectedsource(vid); 
vid = videoinput('hamamatsu', 1); 
src = getselectedsource(vid);
set(vid, 'Timeout', 10) %changed from 30 to 60 to possibly delay the automatic screen 
set(vid, 'FramesPerTrigger', 60);
set(handles.d_connectCamera, 'UserData', vid);
set(vid, 'FrameGrabInterval', 2);
%src.FrameRate = 15;
    
axes(handles.d_videoInput);
frame = getsnapshot(vid);
himage = imshow(frame);
preview(vid, himage); %display live video
hold on
set(himage, 'buttondownfcn', {@click, handles, himage})
set(handles.d_messagesText, 'String', 'Click two points along the calibration slide.');
    
% catch
%     disp(('Failed to connect Hamamatsu Camera'));
%     set(handles.d_messagesText, 'String', 'No Camera Detected');
%     set(hObject, 'Enable', 'on');
%     



function d_brightnessInput_Callback(hObject, eventdata, handles)
% hObject    handle to d_brightnessInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d_brightnessInput as text
%        str2double(get(hObject,'String')) returns contents of d_brightnessInput as a double


% --- Executes during object creation, after setting all properties.
function d_brightnessInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d_brightnessInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function d_exposureInput_Callback(hObject, eventdata, handles)
% hObject    handle to d_exposureInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d_exposureInput as text
%        str2double(get(hObject,'String')) returns contents of d_exposureInput as a double


% --- Executes during object creation, after setting all properties.
function d_exposureInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d_exposureInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in d_disconnectCamera.
function d_disconnectCamera_Callback(hObject, eventdata, handles)
% hObject    handle to d_disconnectCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vid = get(handles.d_connectCamera, 'UserData');

if ~isempty(vid)
    stop(vid)
    stoppreview(vid)
    clear vid
    set(handles.d_messagesText, 'String', 'Camera Disconnected')
    set(hObject, 'Value', 1);
end

% --- Executes on button press in d_apply.
function d_apply_Callback(hObject, eventdata, handles)
% hObject    handle to d_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    vid = get(handles.d_connectCamera, 'UserData');
    src = getselectedsource(vid);
    brightness = round(str2double(get(handles.d_brightnessInput, 'String')));
    exposure = round(str2double(get(handles.d_exposureInput, 'String')));
    set(src, 'Brightness', brightness);
    set(src, 'Exposure', exposure);
catch
    disp(('Attribute Under Revision'))
    set(handles.d_messagesText, 'String', 'Apply Function Unavailable')
    set(hObject, 'Value', 1);
end

function d_lengthInput_Callback(hObject, eventdata, handles)
% hObject    handle to d_lengthInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d_lengthInput as text
%        str2double(get(hObject,'String')) returns contents of d_lengthInput as a double


% --- Executes during object creation, after setting all properties.
function d_lengthInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d_lengthInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in d_done.
function d_done_Callback(hObject, eventdata, handles)
% hObject    handle to d_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%THIS FUNCTION FINDS THE SCALE OF um PER CAM PIXEL
um_length = str2double(get(handles.d_lengthInput, 'String'));
currentData = get(handles.d_done, 'UserData');
px_x_dist = abs(currentData(2,1) - currentData(1,1));
py_y_dist = abs(currentData(2,2) - currentData(1,2));
px_length = sqrt(px_x_dist^2 + py_y_dist^2);
k = um_length / px_length;  
calibstring = strcat(num2str(k), ' um per cam pixel');
set(handles.d_resultsText, 'String', calibstring);


function click(gcbo, hObject, handles, himage)
p = get(gca, 'CurrentPoint');
p = p(1, 1:2);
plot (p(1), p(2), '.', 'MarkerSize', 12, 'Color', 'r');

data = get(gcbo, 'UserData');
data = [data; p];

if size(data, 1) == 2
    line([data(1,1) data(2,1)], [data(1,2) data(2,2)], 'Color', 'r',...
        'LineWidth', 2, 'Marker', '.', 'MarkerSize', 6)
    hold off
    set(handles.d_done, 'UserData', data);
    set(handles.d_messagesText, 'String',...
        'Enter Calibration Values and Press ''Done''')
    set(himage, 'buttondownfcn', {});
end
set(gcbo, 'UserData', data);
disp(p)


function figure1_CloseRequestFcn(hObject, eventdata, handles)
 
d_disconnectCamera_Callback(handles.d_disconnectCamera, [], handles)
delete(hObject)
