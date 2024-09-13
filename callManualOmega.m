function callManualOmega(handles,hObject)
omegaHandles = [handles.omegaA,handles.omegaB,handles.omegaC,handles.omegaD,handles.omegaE,handles.omegaF,handles.omegaG,handles.omegaH,handles.omegaI,handles.omegaJ];
topRow = get(handles.topRow,'Value');

splineData = get(handles.inputSplinePath,'UserData');
crossData = get(handles.crossA,'UserData');

frameMatrix = get(handles.frame,'UserData');
topRow = get(handles.topRow,'Value');
framesToDisplay = frameMatrix(topRow:topRow+1,:);

currentFrameNumber = find(omegaHandles==hObject);
currentFrameNumber = framesToDisplay(floor((currentFrameNumber-1)/5)+1,mod(currentFrameNumber-1,5)+1);

fileList = get(handles.imagePath,'UserData');
currentFile = fileList(currentFrameNumber);
data = manualOmega_gui('String',currentFile{1});
xcl = data(1,:);
ycl = data(2,:);

figure;
scatter(xcl,ycl)
xCross = data(3,:);
yCross = data(4,:);

splineData(2*currentFrameNumber-1,:) = xcl;
splineData(2*currentFrameNumber,:) = ycl;

% 
crossData(2*currentFrameNumber-1,:) = xCross;
crossData(2*currentFrameNumber,:) = yCross;
% 
set(handles.inputSplinePath,'UserData',splineData);
set(handles.crossA,'UserData',crossData);

