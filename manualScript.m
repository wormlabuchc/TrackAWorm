%manualScript
splineDataOrig=get(handles.text16,'UserData');
splineData=get(handles.splinePath,'UserData');
crossData=get(handles.crossA,'UserData');

frameMatrix=get(handles.frame,'UserData');
topRow=str2double(get(handles.topRow,'String'));
framesToDisplay=frameMatrix(topRow:topRow+1,:);
stageMovement=get(handles.stagePath,'UserData');
frameRate=str2double(get(handles.frameRate,'String'));
calibx=str2double(get(handles.calibx,'String'));
caliby=str2double(get(handles.caliby,'String'));


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

%last head coordinates
if currFrame~=1
    prevX=splineDataOrig(2*(currFrame-1)-1,:);
    prevY=splineDataOrig(2*(currFrame-1),:);
else
    prevX=[0 0 0 0 0 0 0 0 0 0 0 0 0];
    prevY=prevX;
end
% lastHead=[lastHeadX lastHeadY];

filelist=get(handles.imagePath,'UserData');
currFile=filelist(currFrame);
data=manualSpline_gui(currFile{1},prevX,prevY);
xclOrig=data(1,:);
yclOrig=data(2,:);
xcross=data(3,:);
ycross=data(4,:);

[xcl,ycl]=compensateForStage(xclOrig,yclOrig,currFrame,stageMovement,frameRate,calibx,caliby);

splineData(2*currFrame-1,:)=xcl;
splineData(2*currFrame,:)=ycl;
splineDataOrig(2*currFrame-1,:)=xclOrig;
splineDataOrig(2*currFrame,:)=yclOrig;
crossData(2*currFrame-1,:)=xcross;
crossData(2*currFrame,:)=ycross;

set(handles.text16,'UserData',splineDataOrig);
set(handles.splinePath,'UserData',splineData);
set(handles.crossA,'UserData',crossData);