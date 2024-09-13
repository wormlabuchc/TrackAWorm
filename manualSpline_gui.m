function varargout = manualSpline_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manualSpline_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @manualSpline_gui_OutputFcn, ...
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

function manualSpline_gui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);

file = varargin{2};
img = imread(file);
img = img(1:end,1:end,1);
axes(handles.win);
h = imshow(img);

set(handles.start,'UserData',h);
set(handles.manualSplineText,'UserData',varargin{2});

uiwait

function varargout = manualSpline_gui_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
delete(gcf);

function start_Callback(hObject, eventdata, handles)

file = get(handles.manualSplineText,'UserData');
img = imread(file);
img = img(1:end,1:end,1);
res = size(img);

h = get(handles.start,'UserData');

hold on

disp('Click points on the figure to create spline, in head-to-tail order')

set(hObject,'Enable','off');
set(handles.reattempt,'Enable','off');
set(handles.swap,'Enable','off');
set(handles.reattemptDone,'Enable','off');

set(h,'buttondownfcn',{@click})
set(handles.done,'UserData',0);


f=1;

while f
    
    if get(handles.done,'UserData')==1
        f=0;
    end
    
    pause(.1)
    
end

splinePoints = get(h,'UserData');

x = splinePoints(:,1); y = splinePoints(:,2);
xi = interp(x,4); yi = interp(y,4);
xi = xi(1:end-3); yi = yi(1:end-3);
x = xi; y = yi;

hold off

imshow(img)

hold on

[xs,ys] = divideSpline(x,y,12);

plot(xs,ys,'.c','MarkerSize',6)
plot(xs(1),ys(1),'xc','MarkerSize',12,'LineWidth',2)

xcl = xs'; ycl = ys'; ycl= res(1)-ycl+1;

hold off

xCross = [0 0 0 0 0 0 0 0 0 0 0 0 0];
yCross = [0 0 0 0 0 0 0 0 0 0 0 0 0];

set(hObject,'Enable','on');

handles.output = [xcl;ycl;xCross;yCross];
guidata(hObject,handles);

uiresume

function done_Callback(hObject, eventdata, handles)

set(hObject,'UserData',1);
set(hObject,'Enable','off');

function click(src,~)

handles = guidata(src);

pointsSelected = get(handles.pointsSelected,'Value');
pointsSelected = pointsSelected+1;

set(handles.pointsSelected,'String',[num2str(pointsSelected) ' points selected']);
set(handles.pointsSelected,'Value',pointsSelected);

if pointsSelected>9
    
    set(handles.pointsSelected,'ForegroundColor','g');
    set(handles.done,'Enable','on');
    
end

data = get(src,'UserData');
p = get(gca,'CurrentPoint');
p = p(1,1:2);
data = [data;p];

if pointsSelected~=1
    plot(p(1),p(2),'.','MarkerSize',12,'Color','r');
else
    plot(p(1),p(2),'rx','MarkerSize',12,'Color','r');
end

drawnow

set(src,'UserData',data);
guidata(src,handles);

function reattempt_Callback(hObject, eventdata, handles)

set(handles.start,'Enable','off');

threshold = get(handles.threshold,'Value');
file = get(handles.manualSplineText,'UserData');

res = size(imread(file));

attempt = 1;
done = 0;

disp('Reattempting spline fit');

while ~done
    
    try

        [xcl,ycl,xCross,yCross] = mainProcess3(file,0,0,1,threshold);
        
        done = 1;
        disp('Successfully produced spline');
        
    catch
        
        attempt = attempt+1;
        
        disp('Analysis failed--Trying again')
        disp(['Attempt: ' num2str(attempt)])
        
        if attempt>2
            
            xcl = NaN([1 13]);
            ycl = NaN([1 13]);
            xCross = xcl; yCross = ycl;
            
            done = 1;
            
            disp('No spline found');
            
        end
            
    end

end

axes(handles.win);

if ~isnan(xcl(1))
    
    imshow(imread(file));
    
    hold on; axis equal
    
    plot(xcl(2:end),res(1)-ycl(2:end)+1,'r.');
    plot(xcl(1),res(1)-ycl(1)+1,'rx','MarkerSize',15);
    
    set(handles.reattemptDone,'UserData',[xcl;ycl;xCross;yCross],'Enable','on');
    set(handles.swap,'Enable','on');
    
else
    
    set(handle.reattemptDone,'UserData',[xcl;ycl;xCross;yCross],'Enable','off');
    set(handles.swap,'Enable','off');
    
end

function threshold_Callback(hObject, eventdata, handles)

% IF NEW THRESHOLD VALUE IF APPROPRIATE, SAVE IT -- ELSE RETURN TO
% EXISTING VALUE

oldThreshold = get(hObject,'Value');
newThreshold = get(hObject,'String');

newThreshold = str2double(newThreshold);

if ~isnan(newThreshold) && newThreshold>=0 && newThreshold<=255
    set(hObject,'Value',newThreshold);
    flashBox('g',hObject);
else
    set(hObject,'String',num2str(oldThreshold));
    flashBox('r',hObject);
end

function threshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function swap_Callback(hObject, eventdata, handles)

reattemptData = get(handles.reattemptDone,'UserData');

xcl = reattemptData(1,:); ycl = reattemptData(2,:);

xcl = fliplr(xcl); ycl = fliplr(ycl);

xCross = [0 0 0 0 0 0 0 0 0 0 0 0 0];
yCross = [0 0 0 0 0 0 0 0 0 0 0 0 0];

axes(handles.win);

file = get(handles.manualSplineText,'UserData');
img = imread(file);

imshow(img);

res = size(img);

imshow(imread(file));

hold on; axis equal

plot(xcl(2:end),res(1)-ycl(2:end)+1,'r.');
plot(xcl(1),res(1)-ycl(1)+1,'rx','MarkerSize',15);

set(handles.reattemptDone,'UserData',[xcl;ycl;xCross;yCross]);

function reattemptDone_Callback(hObject, eventdata, handles)

handles.output = get(hObject,'UserData');

guidata(hObject,handles);
uiresume
