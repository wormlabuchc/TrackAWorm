function play_Callback(hObject, eventdata, handles)

% ENABLE PAUSE, DISABLE FRAME STEPPING AND PLAY
set(handles.pause,'UserData',0);
set(handles.prevFrame,'Enable','off');
set(handles.nextFrame,'Enable','off');
set(handles.pause,'Enable','on');
set(hObject,'Enable','off');
set(handles.currentFrameNumber,'Enable','off');

% GET FILE DATA
currentFrameNumber = get(handles.currentFrameNumber,'Value');
framerate = get(handles.framerateOptions,'UserData');
fileList = get(handles.frame,'UserData');

totalNumberOfFrames = length(fileList);

% IF RECORDING HAS BEEN PLAYED TO THE END BEFORE BE KIND, REWIND
if currentFrameNumber==totalNumberOfFrames
    
    currentFrameNumber = 1;
    updatePlaybackFrame(currentFrameNumber,handles)
    
end

% INCREASE FRAME EVERY 1/framerate SECONDS
while currentFrameNumber<=totalNumberOfFrames && ~get(handles.pause,'UserData')
    
    updatePlaybackFrame(currentFrameNumber,handles);
    currentFrameNumber = currentFrameNumber+1;
    pause(1/framerate);
    
end

% ENABLE PLAY AND FRAME STEPPING, DISABLE PAUSE
set(hObject,'Enable','on');
set(handles.pause,'Enable','off');
set(handles.currentFrameNumber,'Enable','on');
set(handles.prevFrame,'Enable','on');