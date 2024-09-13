function varargout = fitRegion(varargin)
% FITREGION MATLAB code for fitRegion.fig
%      FITREGION, by itself, creates a new FITREGION or raises the existing
%      singleton*.
%
%      H = FITREGION returns the handle to a new FITREGION or the handle to
%      the existing singleton*.
%
%      FITREGION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FITREGION.M with the given input arguments.
%
%      FITREGION('Property','Value',...) creates a new FITREGION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fitRegion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fitRegion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fitRegion

% Last Modified by GUIDE v2.5 20-Jun-2019 12:18:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fitRegion_OpeningFcn, ...
                   'gui_OutputFcn',  @fitRegion_OutputFcn, ...
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


% --- Executes just before fitRegion is made visible.
function fitRegion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fitRegion (see VARARGIN)

% Choose default command line output for fitRegion
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fitRegion wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = fitRegion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure1
delete(hObject)



function path_Callback(hObject, eventdata, handles)
% hObject    handle to path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of path as text
%        str2double(get(hObject,'String')) returns contents of path as a double


% --- Executes during object creation, after setting all properties.
function path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to path (see GCBO)
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
pathX = uigetdir;
set(handles.path, 'String', pathX);

% --- Executes on button press in graph.
function graph_Callback(hObject, eventdata, handles)
% hObject    handle to graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x = get(handles.path, 'String');
mat = fitImage_Callback(hObject, eventdata, handles);
xaxis = [1:1:450];
figure;
plot(xaxis, mat); 


% --- Executes on button press in loadImages.
function loadImages_Callback(hObject, eventdata, handles)
% hObject    handle to loadImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imwinHandles = [handles.image1, handles.image2, handles.image3, handles.image4, handles.image5, handles.image6, handles.image7, handles.image8];
intensityLabels = [handles.intensity1, handles.intensity2, handles.intensity3, handles.intensity4, handles.intensity5, handles.intensity6, handles.intensity7, handles.intensity8];
srcFiles = dir(strcat (get(handles.path, 'String'), '\*.bmp'));
imNum = [handles.im1, handles.im2, handles.im3, handles.im4, handles.im5, handles.im6, handles.im7, handles.im8];
for i = 1:8
    filename = strcat(get(handles.path, 'String'), '\', srcFiles(i).name);
    remaind = (mod((i-1), 8) + 1);
    axes(imwinHandles(remaind));
    imshow(filename);
    hold on
    set(imNum(mod((i-1), 8) +1), 'String', i); %want to make 'i' actually the intensity located in the intensity matrix from demo()
end
% pathLine = get(handles.path, 'String');
% matOfIntensities = zeros;
% pause(1)
% for i = 1:8
%     [meanGL, burnedImage] = intensity(strcat(pathLine, '\', srcFiles(i).name));
%     matOfIntensities(i) = meanGL;
%     close
%     axes(imwinHandles(i));
%     imshow(burnedImage);
%     hold on
%     set(intensityLabels(mod((i-1), 8) +1), 'String', matOfIntensities(i));
% end



% --- Executes on button press in upArrow.
function upArrow_Callback(hObject, eventdata, handles)
% hObject    handle to upArrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentFrame = str2double(get(handles.im1, 'String'));
imwinHandles = [handles.image1, handles.image2, handles.image3, handles.image4, handles.image5, handles.image6, handles.image7, handles.image8];
intensityLabels = [handles.intensity1, handles.intensity2, handles.intensity3, handles.intensity4, handles.intensity5, handles.intensity6, handles.intensity7, handles.intensity8];
imNum = [handles.im1, handles.im2, handles.im3, handles.im4, handles.im5, handles.im6, handles.im7, handles.im8];
srcFiles = dir(strcat (get(handles.path, 'String'), '\*.bmp'));
% if currentFrame == 9
%     set(handles.upArrow, 'Enable', 'off');
%     for i = 1:8
%         filename = strcat(get(handles.path, 'String'), '\', srcFiles(i).name);
%         remaind = (mod((i-1), 8) + 1);
%         axes(imwinHandles(remaind));
%         imshow(filename);
%         hold on
%         set(imNum(mod((i-1), 8) +1), 'String', i); %want to make 'i' actually the intensity located in the intensity matrix from demo()
%     end
% else
    set(handles.upArrow, 'Enable', 'on');
    for i = currentFrame-8:currentFrame-1
    filename = strcat(get(handles.path, 'String'), '\', srcFiles(i).name);
    remaind = (mod((i-1), 8) + 1);
    axes(imwinHandles(remaind));
    imshow(filename);
    hold on
    set(imNum(mod((i-1), 8) +1), 'String', i); %want to make 'i' actually the intensity located in the intensity matrix from demo()
    end
fitImage_Callback(hObject, eventdata, handles);


% --- Executes on button press in downArrow.
function downArrow_Callback(hObject, eventdata, handles)
% hObject    handle to downArrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentFrame = str2double(get(handles.im2, 'String'));
imwinHandles = [handles.image1, handles.image2, handles.image3, handles.image4, handles.image5, handles.image6, handles.image7, handles.image8];
intensityLabels = [handles.intensity1, handles.intensity2, handles.intensity3, handles.intensity4, handles.intensity5, handles.intensity6, handles.intensity7, handles.intensity8];
imNum = [handles.im1, handles.im2, handles.im3, handles.im4, handles.im5, handles.im6, handles.im7, handles.im8];
srcFiles = dir(strcat (get(handles.path, 'String'), '\*.bmp'));
if currentFrame ==450
    set(handles.downArrow, 'Enable', 'off');
else
    set(handles.downArrow, 'Enable', 'on');
    for i = currentFrame+7:currentFrame+14
        filename = strcat(get(handles.path, 'String'), '\', srcFiles(i).name);
        remaind = (mod((i-1), 8) + 1);
        axes(imwinHandles(remaind));
        imshow(filename);
        hold on
        set(imNum(mod((i-1), 8) +1), 'String', i); %want to make 'i' actually the intensity located in the intensity matrix from demo()
        
    end
fitImage_Callback(hObject, eventdata, handles);
end

        


% --- Executes on button press in fitImage.
function matOfIntensities = fitImage_Callback(hObject, eventdata, handles)
% hObject    handle to fitImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathLine = get(handles.path, 'String');
srcFiles = dir(strcat (get(handles.path, 'String'), '\*.bmp'));
currentFrame = str2double(get(handles.im1, 'String'));
imwinHandles = [handles.image1, handles.image2, handles.image3, handles.image4, handles.image5, handles.image6, handles.image7, handles.image8];
intensityLabels = [handles.intensity1, handles.intensity2, handles.intensity3, handles.intensity4, handles.intensity5, handles.intensity6, handles.intensity7, handles.intensity8];
pause(1)
folder = uigetdir;
global matOfIntensities
matOfIntensities = zeros;
%global matOfImages
%
    for i = 1:450
        figure;
        [meanInt, keeperBlobsImage] = BlobsDemo(strcat(pathLine, '\', srcFiles(i).name));
        close
        matOfIntensities(i) = meanInt;
        imwrite(keeperBlobsImage, strcat(folder, '\bim', int2str(i), '.jpeg'));
       % disp(matOfImages(i))
%        
%         matOfImages(i,:,:) = keeperBlobsImage;
    end
%end

% for i = currentFrame:currentFrame+7  
%     [meanInt, keeperBlobsImage] = BlobsDemo(strcat(pathLine, '\', srcFiles(i).name));
%     axes(imwinHandles(mod((i-1), 8)+1));
%     imshow(matOfImages(i));
%     hold on
%     set(intensityLabels(mod((i-1), 8) +1), 'String', matOfIntensities(i));
% end
% disp(matOfIntensities);


% --- Executes on button press in display.
function display_Callback(hObject, eventdata, handles)
% hObject    handle to display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentFrame = str2double(get(handles.im1, 'String'));
imwinHandles = [handles.image1, handles.image2, handles.image3, handles.image4, handles.image5, handles.image6, handles.image7, handles.image8];
intensityLabels = [handles.intensity1, handles.intensity2, handles.intensity3, handles.intensity4, handles.intensity5, handles.intensity6, handles.intensity7, handles.intensity8];
matOfIntensities = fitImage_Callback(hObject, eventdata, handles);
srcFiles = dir(strcat (get(handles.path, 'String'), '\*.jpeg'));
for i = currentFrame:currentFrame+7 
    filename = strcat(get(handles.path, 'String'), '\', srcFiles(i).name);
    axes(imwinHandles(mod((i-1), 8)+1));
    imshow(filename);
    hold on
    set(intensityLabels(mod((i-1), 8) +1), 'String', matOfIntensities(i));
end
