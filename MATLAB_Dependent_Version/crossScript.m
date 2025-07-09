splineDataOrig=get(handles.text16,'UserData');
splineData=get(handles.splinePath,'UserData');
crossData=get(handles.crossA,'Userdata');
frameMatrix=get(handles.frame,'UserData');
topRow=str2double(get(handles.topRow,'String'));
framesToDisplay=frameMatrix(topRow:topRow+1,:);
if strcmp(f,'A')
    currFrame=framesToDisplay(1,1);
elseif strcmp(f,'B')
    currFrame=framesToDisplay(1,2);
elseif strcmp(f,'C')
    currFrame=framesToDisplay(1,3);
elseif strcmp(f,'D')
    currFrame=framesToDisplay(1,4);
elseif strcmp(f,'E')
    currFrame=framesToDisplay(1,5);
elseif strcmp(f,'F')
    currFrame=framesToDisplay(2,1);
elseif strcmp(f,'G')
    currFrame=framesToDisplay(2,2);
elseif strcmp(f,'H')
    currFrame=framesToDisplay(2,3);
elseif strcmp(f,'I')
    currFrame=framesToDisplay(2,4);
elseif strcmp(f,'J')
    currFrame=framesToDisplay(2,5);
end

files=get(handles.imagePath,'UserData');
currFile=files(currFrame);

currSplineRow=2*currFrame-1;
x=splineDataOrig(currSplineRow,:);
y=splineDataOrig(currSplineRow+1,:);

cx=crossData(currSplineRow,:);
cy=crossData(currSplineRow+1,:);

stageMovement=get(handles.stagePath,'UserData');
frameRate=str2double(get(handles.frameRate,'String'));
calibx=str2double(get(handles.calibx,'String'));
caliby=str2double(get(handles.caliby,'String'));

[calibcx,calibcy]=compensateForStage(cx,cy,currFrame,stageMovement,frameRate,calibx,caliby);
calibcx=calibcx*calibx;
calibcy=calibcy*caliby;

newSplineDataOrig=[splineDataOrig(1:currSplineRow-1,:); cx; cy; splineDataOrig(currSplineRow+2:end,:)];
newSplineData=[splineData(1:currSplineRow-1,:); calibcx; calibcy; splineData(currSplineRow+2:end,:)];

newCrossData=[crossData(1:currSplineRow-1,:); x; y; crossData(currSplineRow+2:end,:)];

set(handles.text16,'UserData',newSplineDataOrig);
set(handles.splinePath,'UserData',newSplineData);
set(handles.crossA,'UserData',newCrossData);