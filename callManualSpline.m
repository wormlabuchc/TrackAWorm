function callManualSpline(handles,hObject)

manualHandles = [handles.manualA,handles.manualB,handles.manualC,handles.manualD,handles.manualE,handles.manualF,handles.manualG,handles.manualH,handles.manualI,handles.manualJ];

splineData = get(handles.inputSplinePath,'UserData');
crossData = get(handles.crossA,'UserData');

frameMatrix = get(handles.frame,'UserData');
topRow = get(handles.topRow,'Value');
framesToDisplay = frameMatrix(topRow:topRow+1,:);

currentFrameNumber = find(manualHandles==hObject);
currentFrameNumber = framesToDisplay(floor((currentFrameNumber-1)/5)+1,mod(currentFrameNumber-1,5)+1);

fileList = get(handles.imagePath,'UserData');
currentFile = fileList(currentFrameNumber);

data = manualSpline_gui('String',currentFile{1});

xcl = data(1,:);
ycl = data(2,:);
xCross = data(3,:);
yCross = data(4,:);

splineData(2*currentFrameNumber-1,:) = xcl;
splineData(2*currentFrameNumber,:) = ycl;

crossData(2*currentFrameNumber-1,:) = xCross;
crossData(2*currentFrameNumber,:) = yCross;

set(handles.inputSplinePath,'UserData',splineData);
set(handles.crossA,'UserData',crossData);