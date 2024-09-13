function nextFrame_Callback(hObject, eventdata, handles)

currentFrameNumber = get(handles.currentFrameNumber,'Value');
fileList = get(handles.frame,'UserData');

% INCREASE FRAME NUMBER IF NOT AT THE END
currentFrameNumber = min(currentFrameNumber+1,length(fileList));

if currentFrameNumber==length(fileList)
    set(hObject,'Enable','off');
end

updatePlaybackFrame(currentFrameNumber,handles);