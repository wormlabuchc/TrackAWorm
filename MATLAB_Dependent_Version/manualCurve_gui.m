function varargout = manualCurve_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manualCurve_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @manualCurve_gui_OutputFcn, ...
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

function manualCurve_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);

xSpline = varargin{1}; ySpline = varargin{2};
xSpline = interp(xSpline,3); ySpline = interp(ySpline,3);

axes(handles.win);

set(gca,'XTick',[],'YTick',[]);
hold(gca,'on');
axis(gca,'equal');



plot(xSpline,ySpline,'k');
plot(xSpline(1),ySpline(1),'kx','MarkerSize',15);

xLim = get(gca,'XLim'); yLim = get(gca,'YLim');
set(gca,'XLim',[.90 1.1].*xLim);
set(gca,'YLim',[.90 1.1].*yLim);

set(handles.win,'UserData',[{xSpline} {ySpline}]);

uiwait

function varargout = manualCurve_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
delete(gcf);


function start_Callback(hObject, eventdata, handles)

set(handles.done,'Enable','on');

xySpline = get(handles.win,'UserData');

xSpline = xySpline{1}; ySpline = xySpline{2};

wormLength = pathLength(xSpline,ySpline);

axes(handles.win); hold on

disp('Click points on the figure to complete a curve, then press ''Next Curve''')

dcm_obj = datacursormode(gcf);

set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','off','Enable','on','UpdateFcn',{@dataCursorUpdateFunction,xSpline,ySpline,wormLength,dcm_obj,gcf});

while 1==1
    
    if get(handles.done,'UserData')==1
        break
    end
    
    pause(.1);
    
end

set(hObject,'Enable','on');

allPositions = getCursorInfo(dcm_obj);
allPositions = [allPositions(1:length(allPositions)).Position];
allPositions = reshape(allPositions,2,[])';

handles.output = allPositions;

guidata(hObject,handles);

uiresume

function done_Callback(hObject, eventdata, handles)

set(hObject,'UserData',1);
set(hObject,'Enable','off');

function txt = dataCursorUpdateFunction(~,~,xSpline,ySpline,wormLength,dcm_obj,gcf)

dataTipStructure = findall(gcf,'Type','hggroup');

infoStructure = getCursorInfo(dcm_obj);
allPositions = [infoStructure(1:length(infoStructure)).Position];
allPositions = reshape(allPositions,2,[])';

numberOfPoints = size(allPositions,1);

closestPointIndices = [(numberOfPoints:-1:1)',NaN([numberOfPoints,1])];

for i=numberOfPoints:-1:1

    closestPointIndices(i,2) = findClosestPoint(allPositions(i,1),allPositions(i,2),xSpline,ySpline);
    
end

closestPointIndices = sortrows(closestPointIndices,2,'descend');

for i=1:numberOfPoints
    
    set(dataTipStructure(i),'String',['End of Curve #' num2str(closestPointIndices(i,1))],'Draggable','off');
    
end

   
txt = dataTipStructure(1).String;
% curveNumber = 1; prevClosestPointIndex = 0;
% 
% for i=numberOfPoints:-1:2
% 
%     newPrevClosestPointIndex = findClosestPoint(allPositions(i,1),allPositions(i,2),xSpline,ySpline);
%     
%     if newPrevClosestPointIndex>prevClosestPointIndex
%         
%         curveNumber = curveNumber+1;
%         prevClosestPointIndex = newPrevClosestPointIndex;
%         
%     end   
% end

% closestPointIndex = findClosestPoint(pos(1),pos(2),xSpline,ySpline);
% wormLengthToPoint = pathLength(xSpline(1:closestPointIndex),ySpline(1:closestPointIndex));
% 
% prevLength = pathLength(xSpline(1:prevClosestPointIndex),ySpline(1:prevClosestPointIndex));
% 
% percentWormLength = (round(wormLengthToPoint/wormLength*1000)/10)-(round(prevLength/wormLength*1000)/10);
% 
% if closestPointIndex>prevClosestPointIndex
%     txt = {['Curve ' num2str(curveNumber) ':'],[num2str(percentWormLength) '%']};
% else
%     txt = ['Point not included'];
% end
