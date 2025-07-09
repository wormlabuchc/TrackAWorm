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

% Last Modified by GUIDE v2.5 09-Sep-2024 14:31:03

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


% --- Executes on button press in connectCamera.
function connectCamera_Callback(hObject, eventdata, handles)
% hObject    handle to connectCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%THIS FUNCTION CONNECTS THE CAMERA AND SETS IT TO THE FRAME 
cameraString= get(handles.cameraName, 'String');
cameraIndex = get(handles.cameraName, 'value');
try
    switch cameraString{cameraIndex}
        case 'ALLIED VISION'
            vid = videoinput('gige', 1, 'Mono8');
            src = getselectedsource(vid);
            set(handles.connectCamera,'UserData', vid);
            src.ExposureAuto = 'Off';
            set(vid, 'Timeout', 30)
            src.ExposureTimeAbs = 5000;
             src.AcquisitionFrameRateAbs = 15;
             axes(handles.win);
            frame = getsnapshot(vid);
            himage = imshow(frame);
            preview(vid, himage); %display live video
            hold on
            set(himage, 'buttondownfcn', {@click, handles, himage})
            %set(handles.messages, 'String', 'Click two points along the calibration slide.');
        case 'HAMAMATSU'
            vid = videoinput('hamamatsu', 1); 
            src = getselectedsource(vid);
            set(vid, 'Timeout', 30) %changed from 30 to 60 to possibly delay the automatic screen 
            set(vid, 'FramesPerTrigger', 60);
            set(handles.connectCamera, 'UserData', vid);
            set(vid, 'FrameGrabInterval', 2);
            axes(handles.win);
            frame = getsnapshot(vid);
            himage = imshow(frame);
            preview(vid, himage); %display live video
            hold on
            set(himage, 'buttondownfcn', {@click, handles, himage})
            %set(handles.messages, 'String', 'Click two points along the calibration slide.');
        case 'TISIMAQ'
            vid = videoinput('tisimaq_r2013_64',1,'RGB24 (1024x768)');
            src = getselectedsource(vid);
            set(vid, 'Timeout', 30);
            set(vid, 'FramesPerTrigger', 60);
            set(handles.connectCamera,'UserData', vid);
            set(vid, 'FrameGrabInterval', 2);
            src.FrameRate = 15;
            axes(handles.win);
            frame = getsnapshot(vid);
            himage = imshow(frame);
            preview(vid, himage); %display live video
            hold on
            set(himage, 'buttondownfcn', {@click, handles, himage})
            %set(handles.messages, 'String', 'Click two points along the calibration slide.');
        case 'Choose Camera...'
            f = msgbox('Choose a camera.');
    end
catch
    disp('Failed to connect camera. Check connections and try again.')
    %set(handles.messages, 'String', 'Can not connect to camera.  Check connections and try again.');
end
set(handles.disconnectCamera,'Enable','on');
set(handles.connectCamera,'Enable','off');



function brightness_Callback(hObject, eventdata, handles)
% hObject    handle to brightnessInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of brightnessInput as text
%        str2double(get(hObject,'String')) returns contents of brightnessInput as a double


% --- Executes during object creation, after setting all properties.
function brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brightnessInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function exposure_Callback(hObject, eventdata, handles)
% hObject    handle to exposureInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposureInput as text
%        str2double(get(hObject,'String')) returns contents of exposureInput as a double


% --- Executes during object creation, after setting all properties.
function exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposureInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in disconnectCamera.
function disconnectCamera_Callback(hObject, eventdata, handles)
% hObject    handle to disconnectCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vid = get(handles.connectCamera, 'UserData');

if ~isempty(vid)
    stop(vid)
    stoppreview(vid)
    clear vid
    %set(handles.messages, 'String', 'Camera Disconnected')
    set(hObject, 'Value', 1);
end
set(handles.disconnectCamera,'Enable','off');
set(handles.connectCamera,'Enable','on');

% --- Executes on button press in apply.
function apply_Callback(hObject, eventdata, handles)
% hObject    handle to apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    vid = get(handles.connectCamera, 'UserData');
    src = getselectedsource(vid);
    brightness = round(str2double(get(handles.brightnessInput, 'String')));
    exposure = round(str2double(get(handles.exposureInput, 'String')));
    set(src, 'Brightness', brightness);
    set(src, 'Exposure', exposure);
catch
    disp(('Attribute Under Revision'))
    %set(handles.messages, 'String', 'Apply Function Unavailable')
    set(hObject, 'Value', 1);
end

function length_Callback(hObject, eventdata, handles)
% hObject    handle to length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of length as text
%        str2double(get(hObject,'String')) returns contents of length as a double


% --- Executes during object creation, after setting all properties.
function length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%THIS FUNCTION FINDS THE SCALE OF um PER CAM PIXEL
um_length = str2double(get(handles.length, 'String'));
currentData = get(handles.done, 'UserData');
if isempty(currentData)
    f = msgbox('Choose two points along the calibration slide.');
end
px_x_dist = abs(currentData(2,1) - currentData(1,1));
py_y_dist = abs(currentData(2,2) - currentData(1,2));
px_length = sqrt(px_x_dist^2 + py_y_dist^2);
k = um_length / px_length;  
calibstring = strcat(num2str(k));
set(handles.results, 'String', calibstring);


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
    set(handles.done, 'UserData', data);
    %set(handles.messages, 'String',...
        %'Enter Calibration Values and Press ''Done''')
    set(himage, 'buttondownfcn', {});
end
set(gcbo, 'UserData', data);
disp(p)


function figure1_CloseRequestFcn(hObject, eventdata, handles)
 
disconnectCamera_Callback(handles.disconnectCamera, [], handles)
delete(hObject)


% --- Executes on selection change in cameraName.
function cameraName_Callback(hObject, eventdata, handles)
% hObject    handle to cameraName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cameraName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cameraName


% --- Executes during object creation, after setting all properties.
function cameraName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function results_Callback(hObject, eventdata, handles)
% hObject    handle to results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of results as text
%        str2double(get(hObject,'String')) returns contents of results as a double


% --- Executes during object creation, after setting all properties.
function results_CreateFcn(hObject, eventdata, handles)
% hObject    handle to results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
