function varargout = curveAnalyzer(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @curveAnalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @curveAnalyzer_OutputFcn, ...
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

function curveAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = curveAnalyzer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function inputSplinePath_Callback(hObject, eventdata, handles)

inputSplinePath = get(hObject,'String');

if exist(inputSplinePath,'file')

    set(handles.load,'Enable','on');
    
    flashBox('g',hObject);
    
else
    
    set(handles.load,'Enable','off');
    
    flashBox('r',hObject);
    
end

function inputSplinePath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function browseInputSpline_Callback(hObject, eventdata, handles)

persistent lastInputSplinePath

if isempty(lastInputSplinePath)   
    [filename,pathname] = uigetfile('*.txt',pwd);
else
    [filename,pathname] = uigetfile('*.txt',lastInputSplinePath);
end

inputSplinePath = [pathname,filename];

if ~isnumeric(inputSplinePath)
    
    set(handles.inputSplinePath,'String',inputSplinePath);
    
    set(handles.load,'Enable','on');
    
    lastInputSplinePath = inputSplinePath;
    
end

function load_Callback(hObject, eventdata, handles)

inputSplinePath = get(handles.inputSplinePath,'String');

savePath = [inputSplinePath(1:end-11) '_curvature_results'];
savebinPath = [inputSplinePath(1:end-11) '_curvature_binnedData'];

set(handles.save,'Enable','on','UserData',savePath);
set(handles.savebin,'Enable','on','UserData',savebinPath);

[frameNumbers,ventralData,splineData,~] = parseSplineFile(inputSplinePath);
frameNumbers = frameNumbers(1:2:end);

% UPDATE ALL DATA POSSIBLY SAVED FROM OTHER RECORDINGS
set(handles.ventralMessage,'UserData',ventralData);
set(handles.inputSplinePath,'UserData',splineData);
%set(handles.fixA,'UserData',{});

numberOfFrames = size(frameNumbers,1);

% THE FRAME MATRIX IS AN Nx5 MATRIX, WHERE N IS THE MINIMUM NUMBER OF ROWS
% TO CONTAIN ALL FRAMES OF THE SPLINE FILE -- THE MATRIX DETERMINES WHICH
% FRAMES SHOULD BE DISPLAYED IN EACH BOX WHEN NAVIGATING THE GUI

numberOfRows = ceil(numberOfFrames/5);
frameMatrix = zeros(5,numberOfRows);
frameMatrix(1:numberOfFrames) = 1:numberOfFrames;
frameMatrix = frameMatrix';
set(handles.frame,'UserData',frameMatrix);

%  SELECTEDCURVES IS A 1xM MATRIX, WHERE M IS THE NUMBER OF FRAMES, CONTAINING
%  THE USER-SELECTED CURVE NUMBER FOR EACH FRAMES OR ZERO IF UNSELECTED

selectedCurves = zeros(numberOfFrames);
set(handles.curveSelectAll,'UserData',selectedCurves);

set(handles.frameCountText,'UserData',frameNumbers);
set(handles.frameCountText,'String',[num2str(numberOfFrames) ' frames']);

topRow = 1;
set(handles.topRow,'Value',topRow,'Enable','on','String',num2str(topRow));
set(handles.pageDown,'Enable','on');

updateCurveAnalysisFrames(handles,topRow);

function dontSegment_Callback(hObject, eventdata, handles)

function curveSelectAll_Callback(hObject, eventdata, handles)

function curveSelectAll_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setCurveNums_Callback(hObject, eventdata, handles)

splineFile = get(handles.inputSplinePath,'String');
[frameNumbers,~,~,~] = parseSplineFile(splineFile);

curveHandles = [handles.curveA,handles.curveB,handles.curveC,handles.curveD,handles.curveE,handles.curveF,handles.curveG,handles.curveH,handles.curveI,handles.curveJ];

% GENERATE NEW CURVEDATA ARRAY OF DIMENSION 1xN, WHERE N IS NUMBER OF
% FRAMES
newCurveNum = str2double(get(handles.curveSelectAll,'String'));
newCurveData = newCurveNum*ones([1,size(frameNumbers,1)/2]);
set(handles.curveSelectAll,'UserData',newCurveData);

% UPDATE ALL CURVE NUMBER FIELDS DISPLAYED
for i=1:10
    set(curveHandles(i),'String',num2str(newCurveNum));
end

function pageUp_Callback(hObject, eventdata, handles)

frameMatrix = get(handles.frame,'UserData');
frameMatrixLength = length(frameMatrix(:,1));
topRow = str2double(get(handles.topRow,'String'));

if isnan(topRow)
    topRow = 2;
end

topRow = max(topRow-1,1);

set(handles.topRow,'Value',topRow,'String',num2str(topRow));

% ENABLE PAGE DOWN IF ROW HAS MOVED UP TO THE THIRD TO LAST ROW
if topRow == frameMatrixLength-2
    set(handles.pageDown,'Enable','on')
end

% DISABLE PAGE UP IF ROW HAS MOVED UP TO TOP ROW
if topRow==1
    set(handles.pageUp,'Enable','off')
end

updateCurveAnalysisFrames(handles,topRow);

function pageDown_Callback(hObject, eventdata, handles)

frameMatrix = get(handles.frame,'UserData');
frameMatrixLength = length(frameMatrix(:,1));
topRow = str2double(get(handles.topRow,'String'));

if isnan(topRow)
    topRow = 0;
end

topRow = min(topRow+1,frameMatrixLength-1);

set(handles.topRow,'Value',topRow);
set(handles.topRow,'String',num2str(topRow));

% DISABLE PAGE DOWN IF ROW HAS MOVED DOWN TO SECOND TO LAST ROW
if topRow==frameMatrixLength-1
    set(handles.pageDown,'Enable','off')
end

% ENABLE PAGE UP IF ROW HAS MOVED DOWN TO SECOND ROW
if topRow==2
    set(handles.pageUp,'Enable','on')
end

updateCurveAnalysisFrames(handles,topRow);

function topRow_Callback(hObject, eventdata, handles)

topRow = get(handles.topRow,'String');
topRow = str2double(topRow);
oldTopRow = get(handles.topRow,'Value');

frameMatrix = get(handles.frame,'UserData');

% REVERT TO OLD VALUE IF NEW VALUE IS INVALID
if topRow > size(frameMatrix,1) || topRow <= 0 || isnan(topRow)
    
    flashBox('r',handles.topRow)
    set(handles.topRow,'String',num2str(oldTopRow));

% OTHERWISE SET NEW VALUE AND UPDATE ALL FRAMES
else
    
    flashBox('g',handles.topRow)
    set(handles.topRow,'String',num2str(topRow));
    set(handles.topRow,'Value',topRow);
    updateCurveAnalysisFrames(handles,topRow);
    
end

function topRow_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function curve_Callback(hObject, eventdata, handles)

function curve_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function curve_KeyPressFcn(hObject, eventdata, handles)

drawnow

curveHandles = [handles.curveA,handles.curveB,handles.curveC,handles.curveD,handles.curveE,handles.curveF,handles.curveG,handles.curveH,handles.curveI,handles.curveJ];
frameCountHandles = [handles.frameCountA,handles.frameCountB,handles.frameCountC,handles.frameCountD,handles.frameCountE,handles.frameCountF,handles.frameCountG,handles.frameCountH,handles.frameCountI,handles.frameCountJ];

currentFrameNumber = find(curveHandles==hObject);
currentFrameNumber = get(frameCountHandles(currentFrameNumber),'Value');

curveData = get(handles.curveSelectAll,'UserData');

if strcmp(eventdata.Key,'return')
    
    oldCurveNum = get(hObject,'Value');
    input = str2double(get(hObject,'String'));
    
%     DO NOTHING IF DEFAULT VALUE OF '#'
    if get(hObject,'String')=='#'
    
%     SET NEW VALUE AND UPDATE CURVEDATA IF VALID INPUT
    elseif ~isnan(input) && isnumeric(input)
        
        pause(.2)
        flashBox('g',hObject);
        curveData(currentFrameNumber) = input;
        set(hObject,'Value',input)
        set(handles.curveSelectAll,'UserData',curveData);
        
%     REVERT TO PREVIOUS VALUE IF INPUT INVALID
    else
        
        pause(.2)
        flashBox('r',hObject);
        
        if isnan(oldCurveNum)
            set(hObject,'String','#');
        else
            set(hObject,'String',num2str(oldCurveNum));
        end
        
    end
    
end

function fix_Callback(hObject, eventdata, handles)

callManualCurve(handles,hObject);
topRow = get(handles.topRow,'Value');
updateCurveAnalysisFrames(handles,topRow);

function save_Callback(hObject, eventdata, handles)

defaultSavePath = get(hObject,'UserData');

% USER SELECTS NEW PATH TO EXPORT TO OR EXISTING FILE
[filename,pathname] = uiputfile('*.xlsx', 'Save data in spreadsheet',defaultSavePath);
savePath = [pathname,filename];

% GET ALREADY CURVE OVERRIDES FROM fixA USERDATA
overrideData = {};
dontSegment = get(handles.dontSegment,'Value');

saveSelected = get(handles.saveSelected,'Value');
saveAll = get(handles.saveAll,'Value');

splineData =get(handles.inputSplinePath,'UserData');
selectedCurves = get(handles.curveSelectAll,'UserData');
ventralData = get(handles.ventralMessage,'UserData');
frameNumbers = get(handles.frameCountText,'UserData');

numberOfFrames = length(frameNumbers);

x = splineData(1:2:end,:);
y = splineData(2:2:end,:);

% CELL ARRAYS ULTIMATELY USED FOR EXPORT FILE -- ONE ROW PER FRAME
curvatureData = cell([numberOfFrames,1]);
vdOrientation = cell([numberOfFrames,1]);
curveDataToBin = cell([numberOfFrames,1]);
pointMidptsData = cell([numberOfFrames,1]);

if ~isempty(overrideData)
    overridenFrames = [overrideData{:,1}];
end

if mean(filename~=0) && mean(pathname~=0)
    
    if saveSelected
        if selectedCurves<=0
                msgbox('Select a curve');
                return;
        end
        
%         ONLY ONE CURVE, SO COLUMN COUNT IS KNOWN
        labels = [{'Frame'} {'Curve #'} {'Nomalized Midpt'} {'Length/Radius Ratio'} {'Ventral/Dorsal'}];
        
        
        for i=1:numberOfFrames
            
            ventralDir = ventralData(i);
            
            xSpline = x(i,:); ySpline = y(i,:);
            
%             GENERATE DATA IF CURVE IS NOT OVERRIDED
            if isempty(overrideData) || ~ismember(i,overridenFrames)
                
                [curvature,circlevdDirs,~,pointsSelectedIndices,~,~] = wormCurvature(xSpline,ySpline,ventralDir,dontSegment);
                
%             OTHERWISE LOAD OVERRIDE DATA
            else
                
                overrideRow = overrideData(overridenFrames==i,:);
                
                curvature = overrideRow{2};
                circlevdDirs = overrideRow{3};
                pointsSelectedIndices = overrideRow{5};
                
            
            end
            
%             GET SELECTED CURVE FOR CURRENT FRAME
            currentFrameSelectedCurve = selectedCurves(i);
            
            
%             IF SELECTED CURVE IS NOT GREATER THAN THE NUMBER OF CURVES
            if currentFrameSelectedCurve<=length(curvature)
            
%                 GATHER SELECTED CRUVE'S CURVATURE AND VD DATA
                selectedCurveCurvature = curvature(currentFrameSelectedCurve);
                selectedCurvevdData = circlevdDirs(currentFrameSelectedCurve);
                
%                 CONVERT VD DIRECTION TO APPROPRIATE CHARACTER
                switch selectedCurvevdData
                    
                    case -1
                        selectedCurvevdData = {'V'};
                    case 1
                        selectedCurvevdData = {'D'};
                    case 0
                        selectedCurvevdData = {'U'};
                        
                end
                
%                 ADD CURRENT FRAME'S DATA TO CELL ARRAYS OF DATA
                curvatureData{i} = selectedCurveCurvature;
                vdOrientation(i) = selectedCurvevdData;
            
%             OTHERWISE SET FRAME'S DATA IN CELL ARRAY TO NaN
            else
                
                curvatureData{i} = NaN;
                vdOrientation{i} = NaN;
                
            end
            
%             THIS NUMBER IS DEPENDENT ON INTERP. FACTOR IN wormCurvature,
%             AND IS 24 A.T.M. - IT IS NUMBER OF POINTS CREATED FOR WORM IN
%             wormCurvature ANALYSIS
            pointCount = pointsSelectedIndices(end);
            
            
            
%             FIND AVERAGE VALUE OF POINT INDICES (IE MIDDLE OF WORM
%             SPLINE)
            pointsSelectedIndices = pointsSelectedIndices(1:length(curvature),:);
            pointMidpts = mean(pointsSelectedIndices,2)';
            
%             NORMALIZE DATA TO WORM LENGTH AND ROUND MIDPT TO .001 
            pointMidptsData(i) = num2cell(round(1000*pointMidpts(currentFrameSelectedCurve)/pointCount)/1000);
%             ADD MIDPT DATA TO BINNING DATA CELL ARRAY
            curveDataToBin{i} = [pointMidpts',curvature'];
            
        end
        
%         SAVE ALL DATA CELL ARRAYS TO ONE CELL ARRAY AND ADD LABELS
        data = cell([numberOfFrames+1 4]);
        data(2:end,1) = num2cell(frameNumbers);
        data(2:end,2) = num2cell(selectedCurves');
        data(2:end,3) = pointMidptsData;
        data(2:end,4) = curvatureData;
        data(2:end,5) = vdOrientation;
        data(1,:) = labels;
        
    elseif saveAll
        
%         THIS VALUE WILL BE INCREASED WHENEVER A HIGHER NUMBER OF CURVES
%         IS ENCOUNTERED
        maxNumberOfCurves = 0;

        % Arrays to store max dorsal and ventral curvature for each frame
        maxDorsalCurvature = nan(numberOfFrames, 1); 
        maxVentralCurvature = nan(numberOfFrames, 1);
        point=0;
        numberOfFrames
        for i=1:numberOfFrames
            
%             FIND CURRENT FRAME'S VENTRAL DATA
            ventralDir = ventralData(i);
            
            xSpline = x(i,:); ySpline = y(i,:);
            
%             GENERATE DATA IF CURVE IS NOT OVERRIDED
            if isempty(overrideData) || ~ismember(i,overridenFrames)
                
                [curvature,circlevdDirs,~,pointsSelectedIndices,~,~] = wormCurvature(xSpline,ySpline,ventralDir,dontSegment);
                point=point+1
              
%             OTHERWISE LOAD OVERRIDE DATA
            else
                
                overrideRow = overrideData(overridenFrames==i,:);
                
                curvature = overrideRow{2};
                circlevdDirs = overrideRow{3};
                pointsSelectedIndices = overrideRow{5};
            
            end

%             FIND NUMBER OF CURVES IN CURRENT FRAME
            numberOfCurves = length(curvature);
            
            if numberOfCurves>maxNumberOfCurves
                
%                 ADD EXTRA COLUMN TO ALL PREVIOUS DATA CELL ARRAYS' ROWS - NEW
%                 COLUMN HAS PLACEHOLDER '-' CHARACTER
                pointMidptsData(i:i-1,maxNumberOfCurves+1:numberOfCurves) = {'-'};
                curvatureData(1:i-1,maxNumberOfCurves+1:numberOfCurves) = {'-'};
                vdOrientation(1:i-1,maxNumberOfCurves+1:numberOfCurves) = {'-'};
                
%                 UPDATE MAX CURVE NUMBER
                maxNumberOfCurves = numberOfCurves;
                
%                 dasPadding IS EMPTY - CURRENT FRAME'S ROW IS ALREADY
%                 EQUAL TO ALL PREVIOUS ROWS' LENGHTS
                dashPadding = {};
            
%             OTHERWISE CURRENT FRAME DOES NOT HAVE THE MOST CURVES OF ALL
%             OTHER FRAMES
            else
                                
%                 CREATE A ROW CELL ARRAY dashPadding, WHICH WOULD MAKE THE
%                 CURRENT FRAME'S ROW THE SAME LENGHT AS ALL OTHER ROWS
                dashPadding = cell([1 (maxNumberOfCurves-numberOfCurves)]);
                dashPadding(:) = {'-'};
                
            end
            
%             FIND INDICIES OF V/D IN VD DATA
            vIndices = circlevdDirs==1;
            dIndices = circlevdDirs==-1;
            
            circlevdDirs = cell([1 length(circlevdDirs)]);
            
%             CREATE CHARACTER CELL ARRAY FROM VD DATA
            circlevdDirs(:) = {'U'};
            circlevdDirs(dIndices) = {'D'};
            circlevdDirs(vIndices) = {'V'};
            
%             THIS NUMBER IS DEPENDENT ON INTERP. FACTOR IN wormCurvature,
%             AND IS 24 A.T.M. - IT IS NUMBER OF POINTS CREATED FOR WORM IN
%             wormCurvature ANALYSIS
            pointCount = pointsSelectedIndices(end);
            
%             FIND AVERAGE VALUE OF POINT INDICES (IE MIDDLE OF WORM
%             SPLINE)
            pointsSelectedIndices = pointsSelectedIndices(1:length(curvature),:);
            pointMidpts = mean(pointsSelectedIndices,2)';
            
%             SAVE CURRENT FRAME'S DATA TO A ROW IN CURVATURE AND VD DATA
%             CELL ARRAYS
            curvatureData(i,1:maxNumberOfCurves) = [num2cell(curvature) dashPadding];
            vdOrientation(i,1:maxNumberOfCurves) = [circlevdDirs dashPadding];
            
%             NORMALIZE DATA TO WORM LENGTH AND ROUND MIDPT TO .001       
            pointMidptsData(i,1:maxNumberOfCurves) = [num2cell(round(1000*pointMidpts/pointCount)/1000) dashPadding];
%             ADD MIDPT DATA TO BINNING DATA CELL ARRAY
            curveDataToBin{i} = [pointMidpts',curvature'];

            % Calculate maximum dorsal and ventral curvatures
            maxDorsalCurvature(i) = max(curvature(dIndices));  % Maximum dorsal curvature
            maxVentralCurvature(i) = max(curvature(vIndices)); % Maximum ventral curvature
            
        end

        % Calculate average values for dorsal and ventral curvatures
        avgMaxDorsalCurvature = mean(maxDorsalCurvature, 'omitnan');
        avgMaxVentralCurvature = mean(maxVentralCurvature, 'omitnan');
    
        
%         CREATE LABEL ARRAY BASED ON MAXIMUM NUMBER OF CURVES
        labels = cell([1 (3*maxNumberOfCurves)+3]);
        labels{1} = 'Frame';
        
        for i=1:maxNumberOfCurves
            
            labels{3*i-1} = ['Normalized Midpt-#' num2str(i)];
            labels{3*i} = ['Curvature-#' num2str(i)];
            labels{3*i+1} = ['V/D-#' num2str(i)];
            
        end
        labels{end-2} = 'Maximum dorsal curvature';
        labels{end-1} = 'Maximum ventral curvature';
        %labels{end} = 'Averages'; % For the averages row
        
%         SAVE ALL DATA CELL ARRAYS TO ONE CELL ARRAY AND ADD LABELS
        data = cell([numberOfFrames+2 1+(3*maxNumberOfCurves)+2]);
        data(2:end-1,1) = num2cell(frameNumbers);
        data(2:end-1,2:3:end-3) = pointMidptsData;
        data(2:end-1,3:3:end-2) = curvatureData;
        data(2:end-1,4:3:end-1) = vdOrientation;
        data(2:end-1,end-2) = num2cell(maxDorsalCurvature);
        data(2:end-1,end-1) = num2cell(maxVentralCurvature);
        data(1,:) = labels;

        % Insert average values at the bottom
        data(end, end-2) = {avgMaxDorsalCurvature};
        data(end, end-1) = {avgMaxVentralCurvature};
        data(end,1) = {'Averages'};
        
    end
    
    curveDataToBin = cell2mat(curveDataToBin);
    
    numberOfBins = str2double(get(handles.numberOfBins,'String'));
    
    if isnan(numberOfBins)
        
        disp('Bin number error -- using 5 bins')
        numberOfBins = 5;
        
    end
    
%     CREATE ARRAY OF BIN EDGES, WITH LENGTH numberOfBins+1;
    bins = 1:(pointCount-1)/numberOfBins:pointCount;
    
    sortedToBins = discretize(curveDataToBin(:,1),bins);
    binnedData = cell([numberOfBins,2]);
    
%     ADJUST SO THAT MINIMUM EDGE HAS VALUE ZERO, AND NORMALIZE TO WORM
%     LENGTH (pointsSelectedIndices TOTAL NUMBER OF POINTS)
    bins = (bins-1)/(pointCount-1);
    binLabels = {'Segment' 'AvgCurvature' 'SDCurvature'};
    binEdgeLabels = cell([numberOfBins 1]);
    
%     BIN DATA
    for i=1:numberOfBins
        
        binIndices = sortedToBins(:,1)==i;
        binnedData{i,1} = mean(curveDataToBin(binIndices,2));
        binnedData{i,2} = std(curveDataToBin(binIndices,2));
        
        currentBinEdgeLabel = ['[' num2str(bins(i)) '-' num2str(bins(i+1)) ')'];
        
        if i==numberOfBins
            
            currentBinEdgeLabel(end) = ']';
            
        end
        
        binEdgeLabels{i} = currentBinEdgeLabel;
    end
    
%     ADD LABELS AND EDGE VALUES
    binnedData = [binLabels;binEdgeLabels,binnedData];
    
    disp('Saving data to spreadsheet');
    
    if exist(savePath,'file')
        delete(savePath);
        disp('Existing data overwritten');
    end
    %disp(data)
    %disp(binnedData)
    
%     SAVE DATA TO EXCEL FILE
    try
        
        xlswrite(savePath,data,1);
        disp('Data saved successfully');
        
    catch
        
        disp('Error saving data');
        
    end
    
end


function saveSelected_Callback(hObject, eventdata, handles)

saveSelected=get(handles.saveSelected,'Value');
saveAll=get(handles.saveAll,'Value');
if saveSelected
    set(handles.saveSelected,'Value',1);
    set(handles.saveAll,'Value',0);
elseif ~saveSelected && ~saveAll
    set(handles.saveSelected,'Value',1);
    set(handles.saveAll,'Value',0);
end

function saveAll_Callback(hObject, eventdata, handles)

saveSelected=get(handles.saveSelected,'Value');
saveAll=get(handles.saveAll,'Value');
if saveAll
    set(handles.saveAll,'Value',1);
    set(handles.saveSelected,'Value',0);
elseif ~saveSelected && ~saveAll
    set(handles.saveSelected,'Value',1);
    set(handles.saveAll,'Value',0);
end

function numberOfBins_Callback(hObject, eventdata, handles)

function numberOfBins_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function frame_WindowKeyPressFcn(hObject, eventdata, handles)

% CHECK THAT PAGE UP/DOWN IS ENABLE, AND CALL PAGE UP/DOWN WHEN RESPECTIVE
% ARROW KEY IS PRESSED
if strcmp(eventdata.Key,'uparrow') && strcmp(get(handles.pageUp,'Enable'),'on')
    pageUp_Callback(handles.pageUp,[],handles);
elseif strcmp(eventdata.Key,'downarrow') && strcmp(get(handles.pageDown,'Enable'),'on')
    pageDown_Callback(handles.pageDown,[],handles);
end


% --- Executes on button press in savebin.
function savebin_Callback(hObject, eventdata, handles)
% hObject    handle to savebin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
defaultSavePath = get(hObject,'UserData');

% USER SELECTS NEW PATH TO EXPORT TO OR EXISTING FILE
[filename,pathname] = uiputfile('*.xlsx', 'Save data in spreadsheet',defaultSavePath);
savePath = [pathname,filename];

% GET ALREADY CURVE OVERRIDES FROM fixA USERDATA
overrideData = {};
dontSegment = get(handles.dontSegment,'Value');

saveSelected = get(handles.saveSelected,'Value');
saveAll = get(handles.saveAll,'Value');

splineData =get(handles.inputSplinePath,'UserData');
selectedCurves = get(handles.curveSelectAll,'UserData');
ventralData = get(handles.ventralMessage,'UserData');
frameNumbers = get(handles.frameCountText,'UserData');

numberOfFrames = length(frameNumbers);

x = splineData(1:2:end,:);
y = splineData(2:2:end,:);

% CELL ARRAYS ULTIMATELY USED FOR EXPORT FILE -- ONE ROW PER FRAME
curvatureData = cell([numberOfFrames,1]);
vdOrientation = cell([numberOfFrames,1]);
curveDataToBin = cell([numberOfFrames,1]);
pointMidptsData = cell([numberOfFrames,1]);

if ~isempty(overrideData)
    overridenFrames = [overrideData{:,1}];
end

if mean(filename~=0) && mean(pathname~=0)
    
    if saveSelected
        
%         ONLY ONE CURVE, SO COLUMN COUNT IS KNOWN
        labels = [{'Frame'} {'Curve #'} {'Nomalized Midpt'} {'Radius/Length Ratio'} {'Ventral/Dorsal'}];
        
        for i=1:numberOfFrames
            
            ventralDir = ventralData(i);
            
            xSpline = x(i,:); ySpline = y(i,:);
            
%             GENERATE DATA IF CURVE IS NOT OVERRIDED
            if isempty(overrideData) || ~ismember(i,overridenFrames)
                
                [curvature,circlevdDirs,~,pointsSelectedIndices,~,~] = wormCurvature(xSpline,ySpline,ventralDir,dontSegment);
             
%             OTHERWISE LOAD OVERRIDE DATA
            else
                
                overrideRow = overrideData(overridenFrames==i,:);
                
                curvature = overrideRow{2};
                circlevdDirs = overrideRow{3};
                pointsSelectedIndices = overrideRow{5};
            
            end
            
%             GET SELECTED CURVE FOR CURRENT FRAME
            currentFrameSelectedCurve = selectedCurves(i);
            
%             IF SELECTED CURVE IS NOT GREATER THAN THE NUMBER OF CURVES
            if currentFrameSelectedCurve<=length(curvature)
            
%                 GATHER SELECTED CRUVE'S CURVATURE AND VD DATA
                selectedCurveCurvature = curvature(currentFrameSelectedCurve);
                selectedCurvevdData = circlevdDirs(currentFrameSelectedCurve);
                
%                 CONVERT VD DIRECTION TO APPROPRIATE CHARACTER
                switch selectedCurvevdData
                    
                    case -1
                        selectedCurvevdData = {'V'};
                    case 1
                        selectedCurvevdData = {'D'};
                    case 0
                        selectedCurvevdData = {'U'};
                        
                end
                
%                 ADD CURRENT FRAME'S DATA TO CELL ARRAYS OF DATA
                curvatureData{i} = selectedCurveCurvature;
                vdOrientation(i) = selectedCurvevdData;
            
%             OTHERWISE SET FRAME'S DATA IN CELL ARRAY TO NaN
            else
                
                curvatureData{i} = NaN;
                vdOrientation{i} = NaN;
                
            end
            
%             THIS NUMBER IS DEPENDENT ON INTERP. FACTOR IN wormCurvature,
%             AND IS 24 A.T.M. - IT IS NUMBER OF POINTS CREATED FOR WORM IN
%             wormCurvature ANALYSIS
            pointCount = pointsSelectedIndices(end);
            
%             FIND AVERAGE VALUE OF POINT INDICES (IE MIDDLE OF WORM
%             SPLINE)
            pointsSelectedIndices = pointsSelectedIndices(1:length(curvature),:);
            pointMidpts = mean(pointsSelectedIndices,2)';
            
%             NORMALIZE DATA TO WORM LENGTH AND ROUND MIDPT TO .001 
            pointMidptsData(i) = num2cell(round(1000*pointMidpts(currentFrameSelectedCurve)/pointCount)/1000);
%             ADD MIDPT DATA TO BINNING DATA CELL ARRAY
            curveDataToBin{i} = [pointMidpts',curvature'];
            
        end
        
%         SAVE ALL DATA CELL ARRAYS TO ONE CELL ARRAY AND ADD LABELS
        data = cell([numberOfFrames+1 4]);
        data(2:end,1) = num2cell(frameNumbers);
        data(2:end,2) = num2cell(selectedCurves');
        data(2:end,3) = pointMidptsData;
        data(2:end,4) = curvatureData;
        data(2:end,5) = vdOrientation;
        data(1,:) = labels;
        
    elseif saveAll
        
%         THIS VALUE WILL BE INCREASED WHENEVER A HIGHER NUMBER OF CURVES
%         IS ENCOUNTERED
        maxNumberOfCurves = 0;
        
        for i=1:numberOfFrames
            
%             FIND CURRENT FRAME'S VENTRAL DATA
            ventralDir = ventralData(i);
            
            xSpline = x(i,:); ySpline = y(i,:);
            
%             GENERATE DATA IF CURVE IS NOT OVERRIDED
            if isempty(overrideData) || ~ismember(i,overridenFrames)
                
                [curvature,circlevdDirs,~,pointsSelectedIndices,~,~] = wormCurvature(xSpline,ySpline,ventralDir,dontSegment);
              
%             OTHERWISE LOAD OVERRIDE DATA
            else
                
                overrideRow = overrideData(overridenFrames==i,:);
                
                curvature = overrideRow{2};
                circlevdDirs = overrideRow{3};
                pointsSelectedIndices = overrideRow{5};
            
            end

%             FIND NUMBER OF CURVES IN CURRENT FRAME
            numberOfCurves = length(curvature);
            
            if numberOfCurves>maxNumberOfCurves
                
%                 ADD EXTRA COLUMN TO ALL PREVIOUS DATA CELL ARRAYS' ROWS - NEW
%                 COLUMN HAS PLACEHOLDER '-' CHARACTER
                pointMidptsData(i:i-1,maxNumberOfCurves+1:numberOfCurves) = {'-'};
                curvatureData(1:i-1,maxNumberOfCurves+1:numberOfCurves) = {'-'};
                vdOrientation(1:i-1,maxNumberOfCurves+1:numberOfCurves) = {'-'};
                
%                 UPDATE MAX CURVE NUMBER
                maxNumberOfCurves = numberOfCurves;
                
%                 dasPadding IS EMPTY - CURRENT FRAME'S ROW IS ALREADY
%                 EQUAL TO ALL PREVIOUS ROWS' LENGHTS
                dashPadding = {};
            
%             OTHERWISE CURRENT FRAME DOES NOT HAVE THE MOST CURVES OF ALL
%             OTHER FRAMES
            else
                                
%                 CREATE A ROW CELL ARRAY dashPadding, WHICH WOULD MAKE THE
%                 CURRENT FRAME'S ROW THE SAME LENGHT AS ALL OTHER ROWS
                dashPadding = cell([1 (maxNumberOfCurves-numberOfCurves)]);
                dashPadding(:) = {'-'};
                
            end
            
%             FIND INDICIES OF V/D IN VD DATA
            vIndices = circlevdDirs==1;
            dIndices = circlevdDirs==-1;
            
            circlevdDirs = cell([1 length(circlevdDirs)]);
            
%             CREATE CHARACTER CELL ARRAY FROM VD DATA
            circlevdDirs(:) = {'U'};
            circlevdDirs(dIndices) = {'D'};
            circlevdDirs(vIndices) = {'V'};
            
%             THIS NUMBER IS DEPENDENT ON INTERP. FACTOR IN wormCurvature,
%             AND IS 24 A.T.M. - IT IS NUMBER OF POINTS CREATED FOR WORM IN
%             wormCurvature ANALYSIS
            pointCount = pointsSelectedIndices(end);
            
            
%             FIND AVERAGE VALUE OF POINT INDICES (IE MIDDLE OF WORM
%             SPLINE)
            pointsSelectedIndices = pointsSelectedIndices(1:length(curvature),:);
            pointMidpts = mean(pointsSelectedIndices,2)';
            
%             SAVE CURRENT FRAME'S DATA TO A ROW IN CURVATURE AND VD DATA
%             CELL ARRAYS
            curvatureData(i,1:maxNumberOfCurves) = [num2cell(curvature) dashPadding];
            vdOrientation(i,1:maxNumberOfCurves) = [circlevdDirs dashPadding];
            
%             NORMALIZE DATA TO WORM LENGTH AND ROUND MIDPT TO .001       
            pointMidptsData(i,1:maxNumberOfCurves) = [num2cell(round(1000*pointMidpts/pointCount)/1000) dashPadding];
%             ADD MIDPT DATA TO BINNING DATA CELL ARRAY
            curveDataToBin{i} = [pointMidpts',curvature'];
            
        end
        
        
%         CREATE LABEL ARRAY BASED ON MAXIMUM NUMBER OF CURVES
        labels = cell([1 (3*maxNumberOfCurves)+1]);
        labels{1} = 'Frame';
        
        for i=1:maxNumberOfCurves
            
            labels{3*i-1} = ['Normalized Midpt-#' num2str(i)];
            labels{3*i} = ['Curvature-#' num2str(i)];
            labels{3*i+1} = ['V/D-#' num2str(i)];
            
        end
        
%         SAVE ALL DATA CELL ARRAYS TO ONE CELL ARRAY AND ADD LABELS
        data = cell([numberOfFrames+1 1+(3*maxNumberOfCurves)]);
        data(2:end,1) = num2cell(frameNumbers);
        data(2:end,2:3:end-2) = pointMidptsData;
        data(2:end,3:3:end-1) = curvatureData;
        data(2:end,4:3:end) = vdOrientation;
        data(1,:) = labels;
        
    end
    
    curveDataToBin = cell2mat(curveDataToBin);
    
    numberOfBins = str2double(get(handles.numberOfBins,'String'));
    
    if isnan(numberOfBins)
        
        disp('Bin number error -- using 5 bins')
        numberOfBins = 5;
        
    end
    
%     CREATE ARRAY OF BIN EDGES, WITH LENGTH numberOfBins+1;
    bins = 1:(pointCount-1)/numberOfBins:pointCount;
    
    sortedToBins = discretize(curveDataToBin(:,1),bins);
    binnedData = cell([numberOfBins,2]);
    
%     ADJUST SO THAT MINIMUM EDGE HAS VALUE ZERO, AND NORMALIZE TO WORM
%     LENGTH (pointsSelectedIndices TOTAL NUMBER OF POINTS)
    bins = (bins-1)/(pointCount-1);
    binLabels = {'Segment' 'AvgCurvature' 'SDCurvature'};
    binEdgeLabels = cell([numberOfBins 1]);
    
%     BIN DATA
    for i=1:numberOfBins
        
        binIndices = sortedToBins(:,1)==i;
        binnedData{i,1} = mean(curveDataToBin(binIndices,2));
        binnedData{i,2} = std(curveDataToBin(binIndices,2));
        
        currentBinEdgeLabel = ['[' num2str(bins(i)) '-' num2str(bins(i+1)) ')'];
        
        if i==numberOfBins
            
            currentBinEdgeLabel(end) = ']';
            
        end
        
        binEdgeLabels{i} = currentBinEdgeLabel;
    end
    
%     ADD LABELS AND EDGE VALUES
    binnedData = [binLabels;binEdgeLabels,binnedData];
    
    disp('Saving data to spreadsheet');
    
    if exist(savePath,'file')
        delete(savePath);
        disp('Existing data overwritten');
    end
    %disp(data)
    %disp(binnedData)
    
%     SAVE DATA TO EXCEL FILE
    try
        
        %xlswrite(savePath,data,1);
        xlswrite(savePath,binnedData,2);
        disp('Data saved successfully');
        
    catch
        
        disp('Error saving data');
        
    end
    
end
