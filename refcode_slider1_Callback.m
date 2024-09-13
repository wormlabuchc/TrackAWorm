function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentFrameNumber = get(handles.currentFrameNumber,'Value');
framerate = get(handles.framerateOptions,'UserData');
fileList = get(handles.frame,'UserData');
totalNumberOfFrames = length(fileList);
Sliderval=get(hObject,'Value'); %returns position of slider
%         and  to determine range of slider
set(handles.slider1,'Min',1);
set(handles.slider1,'Max',totalNumberOfFrames);
%get(hObject,'Min')
%get(hObject,'Max')
if Sliderval==get(hObject,'Min')
    currentImage = imread(fileList{1});
    imshow(currentImage,'Parent',handles.win);
elseif Sliderval==get(hObject,'Max')
    currentImage = imread(fileList{totalNumberOfFrames});
    imshow(currentImage,'Parent',handles.win);
else
    currentImage = imread(fileList{currentFrameNumber});
    imshow(currentImage,'Parent',handles.win);
end



    
