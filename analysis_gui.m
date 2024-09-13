function varargout = analysis_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @analysis_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @analysis_gui_OutputFcn, ...
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
 
function analysis_gui_OpeningFcn(hObject, eventdata, handles, varargin)
 
handles.output = hObject;
guidata(hObject, handles);
 
function varargout = analysis_gui_OutputFcn(hObject, eventdata, handles)
 
varargout{1} = handles.output;
 
function browseSpline_Callback(hObject, eventdata, handles)
set(handles.wormAmplitude,'Enable','off');
set(handles.speedAndDistance,'Enable','off');
set(handles.directionAnalysis,'Enable','off');
set(handles.exportWormPath,'Enable','off');
%set(handles.fwdBwdSpectrum,'Enable','off');
set(handles.binData,'Enable','off');
savePath = get(handles.exportPath,'String');
saveIndex = get(handles.exportPath,'Value');
switch savePath
    case 'Browse to name an Excel file to save results...'
        msg=msgbox('Enter Excel file to export results.');
    otherwise
        persistent lastSplinePath
        if isempty(lastSplinePath)   
        [filename,pathname] = uigetfile('*.txt','',pwd);   
        else 
        [filename,pathname] = uigetfile('*.txt','',lastSplinePath);
        end

    splinePath = [pathname,filename];
    [path,name,~]=fileparts(splinePath);
    name = strrep(name,'_spline','');
    newPath=fullfile(path,name);
    
    %Get the name of the first image in the folder
    firstImage = getFirstNameImage(newPath);

    

    comp = computer;
    if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
        slash = '/';
    else
        slash = '\';
    end

    if ~isnumeric(splinePath)

        lastSplinePath = splinePath;

        lastSlash = find(splinePath==slash);
        lastSlash = lastSlash(end);

        wormName = splinePath(lastSlash+1:end-11);

        set(handles.splinePath,'String',splinePath);

        stagePath = [splinePath(1:lastSlash) wormName slash wormName '.txt'];
        timesPath = [splinePath(1:lastSlash) wormName slash wormName '_times.txt'];
        %savePath = [splinePath(1:lastSlash) wormName '_results.xlsx'];

        [~,calib] = parseStageFile(stagePath);
        res = parseSplineFileForRes(splinePath);
        [~,framerate] = parseTimesFile(timesPath);
        [~,~,reducedframerate]=parseTimesFile(timesPath);
        if num2str(reducedframerate)=="NaN"
            reducedframerate= "N.A.";
        end
        totalFrames = countFramesInFile(splinePath);

        set(handles.stagePath,'String',stagePath);
        set(handles.timesPath,'String',timesPath);
        set(handles.calib,'String',num2str(calib));
        set(handles.framerate,'String',num2str(framerate));
        set(handles.reducedframerate,'String',num2str(reducedframerate));
        set(handles.movementPanel,'UserData',[]);
        set(handles.totalFrames,'String',['/ ',num2str(totalFrames)],'Value',totalFrames);
        set(handles.beginFrame,'String','1','Value',1);
        set(handles.endFrame,'String',num2str(totalFrames),'Value',totalFrames);
        set(handles.framesToAnalyze,'UserData',[1 totalFrames]);
       % set(handles.allFrames,'Enable','on');
        %set(handles.selectedFrames,'Enable','on');
        set(handles.resHolder,'UserData',res);

        if ~strcmp(get(handles.exportPath,'String'),'Enter Excel file to export results...') && ~strcmp(get(handles.exportPath,'String'),savePath)

            updateChoice = questdlg(['Update export path to new Excel file, or continue to use file: ' get(handles.exportPath,'String')],'New Excel File Confirmation','Update Excel Save Path','Continue Without Updating','Continue Without Updating');

            switch updateChoice

                case 'Update Excel Save Path'
                    updateChoice = 1;
                case 'Continue Without Updating'
                    updateChoice = 0;
            end

        else

            updateChoice = 1;

        end

        if ~updateChoice

            savePath = get(handles.exportPath,'String');

        end

        if exist(savePath,'file') && updateChoice

            pause(.23)

            overwriteOption = questdlg('Results Excel file already exists. Ovewrite or append new data?','Overwite confirmation','Overwrite','Append','Append');

            switch overwriteOption

                case 'Overwrite'
                    overwriteOption = 1;
                case 'Append'
                    overwriteOption = 0;

            end

            set(handles.exportPath,'String',savePath,'Value',overwriteOption);

        elseif exist(savePath,'file') && ~updateChoice

            set(handles.exportPath,'String',savePath,'Value',0);

        else

            set(handles.exportPath,'String',savePath,'Value',1);

        end

    end
end

 
function splinePath_Callback(hObject, eventdata, handles)
 
comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end
 
splinePath = get(hObject,'String');
 
lastSlash = find(splinePath==slash);
lastSlash = lastSlash(end);
 
wormName = splinePath(lastSlash+1:end-11);
 
set(handles.splinePath,'String',splinePath);
 
stagePath = [splinePath(1:lastSlash) wormName slash wormName '.txt'];
timesPath = [splinePath(1:lastSlash) wormName slash wormName '_times.txt'];
savePath = [splinePath(1:lastSlash) wormName '_results.xlsx'];
     
try
 
    [~,calib] = parseStageFile(stagePath);
     
    [~,framerate] = parseTimesFile(timesPath);
    res = parseSplineFileForRes(splinePath);
    totalFrames = countFramesInFile(splinePath);
    
    set(handles.resHolder,'UserData',res);
    set(handles.stagePath,'String',stagePath);
    set(handles.timesPath,'String',timesPath);
    set(handles.calib,'String',num2str(calib));
    set(handles.framerate,'String',num2str(framerate));
    set(handles.movementPanel,'UserData',[]);
    set(handles.totalFrames,'String',['/ ',num2str(totalFrames)],'Value',totalFrames);
    set(handles.beginFrame,'String','1','Value',1);
    set(handles.endFrame,'String',num2str(totalFrames),'Value',totalFrames);
    set(handles.framesToAnalyze,'UserData',[1 totalFrames]);
    %set(handles.allFrames,'Enable','on');
    %set(handles.selectedFrames,'Enable','on');
     
    flashBox('g',handles.splinePath,handles.stagePath,handles.timesPath);
      
catch
     
    flashBox('r',handles.splinePath,handles.stagePath,handles.timesPath);
 
    return
end
 
if ~strcmp(get(handles.exportPath,'String'),'Enter Excel file to export results...') && ~strcmp(get(handles.exportPath,'String'),savePath)
     
    updateChoice = questdlg(['Update export path to new Excel file, or continue to use file: ' get(handles.exportPath,'String')],'New Excel File Confirmation','Update Excel Save Path','Continue Without Updating','Continue Without Updating');
     
    switch updateChoice
         
        case 'Update Excel Save Path'
            updateChoice = 1;
        case 'Continue Without Updating'
            updateChoice = 0;
    end
     
else
     
    updateChoice = 1;
     
end
 
if ~updateChoice
     
    savePath = get(handles.exportPath,'String');
     
end
 
if exist(savePath,'file') && updateChoice
     
    pause(.23)
     
    overwriteOption = questdlg('Results Excel file already exists. Ovewrite or append new data?','Overwite confirmation','Overwrite','Append','Append');
     
    switch overwriteOption
         
        case 'Overwrite'
            overwriteOption = 1;
        case 'Append'
            overwriteOption = 0;
             
    end
     
    set(handles.exportPath,'String',savePath,'Value',overwriteOption);
     
elseif exist(savePath,'file') && ~updateChoice
     
    set(handles.exportPath,'String',savePath,'Value',0);
     
else
 
    set(handles.exportPath,'String',savePath,'Value',1);
     
end
set(handles.wormAmplitude,'Enable','off');
set(handles.speedAndDistance,'Enable','off');
set(handles.directionAnalysis,'Enable','off');
set(handles.exportWormPath,'Enable','off');
set(handles.fwdBwdSpectrum,'Enable','off');
 
function splinePath_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function framerate_Callback(hObject, eventdata, handles)
 
% IF NEW FRAMERATE VALUE IF APPROPRIATE, SAVE IT -- ELSE RETURN TO
% EXISTING VALUE
 
oldFramerate = get(hObject,'Value');
newFramerate = get(hObject,'String');
 
newFramerate = str2double(newFramerate);
 
if ~isnan(newFramerate)
     
    set(hObject,'Value',newFramerate);
    set(handles.movementPanel,'UserData',[]);
    flashBox('g',hObject);
     
else
     
    set(hObject,'String',num2str(oldFramerate));
    flashBox('r',hObject);
     
end
set(handles.wormAmplitude,'Enable','off');
set(handles.speedAndDistance,'Enable','off');
set(handles.directionAnalysis,'Enable','off');
set(handles.exportWormPath,'Enable','off');
set(handles.fwdBwdSpectrum,'Enable','off');
 
function framerate_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function calib_Callback(hObject, eventdata, handles)
 
% IF NEW CALIB VALUE IF APPROPRIATE, THEN SAVE IT -- ELSE RETURN TO
% EXISTING VALUE
  
oldCalibValue = get(hObject,'Value');
newCalibValue = get(hObject,'String');
 
newCalibValue = str2double(newCalibValue);
 
if ~isnan(newCalibValue)
    set(hObject,'Value',newCalibValue);
    flashBox('g',hObject);
    set(handles.movementPanel,'UserData',[]);
else
    set(hObject,'String',num2str(oldCalibValue));
    flashBox('r',hObject);
end
 
function calib_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
% function allFrames_Callback(hObject, eventdata, handles)
%  
% % SET 'SELECTED framesToAnalyze' LIMITS TO DEFAULT VALUES AND DISABLE ENTRY FIELDS
% % -- DELETE ANY SAVED wL DATA
%  
% totalFrames = get(handles.totalFrames,'Value');
%  
% set(handles.beginFrame,'String','1');
% set(handles.endFrame,'String',num2str(totalFrames));
%  
% set(handles.beginFrame,'Enable','off');
% set(handles.endFrame,'Enable','off');
%  
% set(handles.framesToAnalyze,'UserData',[1,totalFrames]);
% set(handles.movementPanel,'UserData',[]);
 
function selectedFrames_Callback(hObject, eventdata, handles)
 
% SAVE SELECTED framesToAnalyze LIMITS TO USER DATA -- DELETE ANY SAVED wL DATA
 
beginFrame = get(handles.beginFrame,'Value');
endFrame = get(handles.endFrame,'Value');
 
set(handles.beginFrame,'Enable','on');
set(handles.endFrame,'Enable','on');
set(handles.movementPanel,'UserData',[]);
 
set(handles.framesToAnalyze,'UserData',[beginFrame,endFrame]);
 
function beginFrame_Callback(hObject, eventdata, handles)
 
% IF NEW BEGIN FRAME VALUE IF APPROPRIATE, SAVE IT -- ELSE RETURN TO
% EXISTING VALUE
 
oldBeginFrame = get(hObject,'Value');
endFrame = get(handles.endFrame,'Value');
 
newBeginFrame = get(hObject,'String');
newBeginFrame = str2double(newBeginFrame);
 
if isnan(newBeginFrame) || newBeginFrame>=endFrame || newBeginFrame<=0
    flashBox('r',hObject);
    set(hObject,'String',num2str(oldBeginFrame));
else
    set(hObject,'Value',newBeginFrame);
    set(handles.framesToAnalyze,'UserData',[newBeginFrame,endFrame]);
    set(handles.movementPanel,'UserData',[]);
    flashBox('g',hObject);
end
     
function beginFrame_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function endFrame_Callback(hObject, eventdata, handles)
 
% IF NEW ENDFRAME VALUE IF APPROPRIATE, SAVE IT -- ELSE RETURN TO
% EXISTING VALUE
 
oldEndFrame = get(hObject,'Value');
beginFrame = get(handles.beginFrame,'Value');
totalFrames = get(handles.totalFrames,'Value');
 
 
newEndFrame = get(hObject,'String');
newEndFrame = str2double(newEndFrame);
 
if isnan(newEndFrame) || beginFrame>=newEndFrame || newEndFrame>totalFrames
    flashBox('r',hObject);
    set(hObject,'String',num2str(oldEndFrame));
else
    set(hObject,'Value',newEndFrame);
    set(handles.framesToAnalyze,'UserData',[beginFrame,newEndFrame]);
    set(handles.movementPanel,'UserData',[]);
    flashBox('g',hObject);
end
 
function endFrame_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function bendNumber_Callback(hObject, eventdata, handles)
 
function bendNumber_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function plotBend_Callback(hObject, eventdata, handles)
 
[splineFile,~,~,framerate,~,~,framesToAnalyze,~] = getAnalysisProperties(handles);
 
bendNumber = get(handles.bendNumber,'Value');
fs = framerate;
 
[~,time,selectedBendAngles] = fftFunction(splineFile,bendNumber,fs,framesToAnalyze);
 
figure;
plot(time,selectedBendAngles)
title('Bend Trace')
xlabel('Time (sec)');
ylabel('Bending Angle (deg)')
 
function sumOfBends_Callback(hObject, eventdata, handles)
 
[splineFile,~,~,~,~,~,framesToAnalyze,~] = getAnalysisProperties(handles);
 
sumOfBends = averageSumOfBendAngles(splineFile,framesToAnalyze);
 
sumOfBends = round(sumOfBends*100)/100;
 
set(handles.bendMessages,'String',['Sum of All Bends ' num2str(sumOfBends) ' degrees']);
 
function bendFreqRms_Callback(hObject, eventdata, handles)
 
[splineFile,~,~,framerate,~,~,framesToAnalyze,~] = getAnalysisProperties(handles);
 
bendNumber = get(handles.bendNumber,'Value');
fs = framerate;
 
rms = findRms(splineFile,bendNumber,framesToAnalyze);
 
[freq,~,~] = fftFunction(splineFile,bendNumber,fs,framesToAnalyze,1);
 
freq = round(freq*100)/100;
rms = round(rms*100)/100;
 
set(handles.bendMessages,'String',['Frequency ' num2str(freq) ' Hz; RMS ' num2str(rms) ' degrees'])
 
function maxBend_Callback(hObject, eventdata, handles)
 
[splineFile,~,~,framerate,~,~,framesToAnalyze,~] = getAnalysisProperties(handles);
 
bendNumber = get(handles.bendNumber,'Value');
fs = framerate;
 
[~,time,selectedBendAngles] = fftFunction(splineFile,bendNumber,fs,framesToAnalyze);
 
exc = bendCursor_gui(time,selectedBendAngles);
exc = round(exc*100)/100;
 
set(handles.bendMessages,'String',['Maximum Bend ' num2str(round(exc,1)) ' degrees']);
 
function thrashing_Callback(hObject, eventdata, handles)
 
[splineFile,~,~,framerate,~,~,~,~] = getAnalysisProperties(handles);
 
[n,freq] = thrashingFreq(splineFile,framerate);
freq = round(freq*10)/10;
set(handles.bendMessages,'String',['Thrashing count ' num2str(n) ' Frequency ' num2str(freq) '/min']);
 
function exportBendData_Callback(hObject, eventdata, handles)
 
[splineFile,~,timesFile,framerate,~,~,framesToAnalyze,~] = getAnalysisProperties(handles);
framesToAnalyze
[frameFileNumbers,~,~,~] = parseSplineFile(splineFile);
%frameFileNumbers = frameFileNumbers(1:2:end);
 
[filename,pathname] = uiputfile('*.xlsx','Save Bend Data');

fs = framerate;
 
data = cell(1,11);
 
for bendNumber=1:11
     
    [~,~,selectedBendAngles] = fftFunction(splineFile,bendNumber,fs,framesToAnalyze);
    data{bendNumber} = selectedBendAngles;
end
 
frameFileNumbers = frameFileNumbers(1:2:end);
%frameFileNumbersToAnalyze = frameFileNumbers(framesToAnalyze(1):framesToAnalyze(2));
%size(frameFileNumbersToAnalyze) 
%timesData = load(timesFile);
timesData = importdata(timesFile);
timesData=timesData.data;
%size(timesData)
times = timesData(:,1);
 
data = cell2mat(data);
 
data=[times data];
data_1= table(data,'VariableNames',{'a'});
data_1= splitvars(data_1);
data_1.Properties.VariableNames={'Time (sec)','Bend 1','Bend 2','Bend 3','Bend 4','Bend 5','Bend 6','Bend 7','Bend 8','Bend 9','Bend 10','Bend 11'};
writetable(data_1,[pathname,filename],'WriteVariableNames',true);
%labels=[{'%%Time'} {'%%Bend 1'} {'%%Bend 2'} {'%%Bend 3'} {'%%Bend 4'} {'%%Bend 5'} {'%%Bend 6'} {'%%Bend 7'} {'%%Bend 8'} {'%%Bend 9'} {'%%Bend 10'} {'%%Bend 11'}];
%saveDataMatrix(labels,data,[pathname filename]);

set(handles.bendMessages,'String','Bend Data Exported');
 
function stagePath_Callback(hObject, eventdata, handles)
 
function stagePath_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function browseStage_Callback(hObject, eventdata, handles)
 
[filename,pathname] = uigetfile('*.txt','Open stage file');
 
if ~isnumeric(filename) && ~isnumeric(pathname)
    set(handles.stagePath,'String',[pathname filename]);
end
 
function timesPath_Callback(hObject, eventdata, handles)
 
function timesPath_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function browseTimes_Callback(hObject, eventdata, handles)
 
[filename,pathname] = uigetfile('*.txt','Open times file');
 
if ~isnumeric(filename) && ~isnumeric(pathname)
    set(handles.timesPath,'String',[pathname filename]);
end
 
function splinePoint_Callback(hObject, eventdata, handles)
 
set(handles.movementPanel,'UserData',[]);
set(handles.wormAmplitude,'Enable','off');
set(handles.speedAndDistance,'Enable','off');
set(handles.directionAnalysis,'Enable','off');
set(handles.exportWormPath,'Enable','off');
set(handles.fwdBwdSpectrum,'Enable','off');
 
function splinePoint_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function showScatter_Callback(hObject, eventdata, handles)
 
function plotPath_Callback(hObject, eventdata, handles)
% h=findobj('Tag','figure1');
% h
corerate=getappdata(0,'rate');

[splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles);
reducedframerate = str2double(get(handles.reducedframerate,'String'));

% GET wL DATA IF IT IS NOT ALREADY SAVED
if isempty(get(handles.movementPanel,'UserData'))
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,reducedframerate,calib,splinePoint,framesToAnalyze,res,corerate);
    set(handles.movementPanel,'UserData',locomotionData);
   
else
    locomotionData = get(handles.movementPanel,'UserData');
end
times=locomotionData.times;

%Default bin number max number of bins
numberToDisplay= length(times);
set(handles.nbins, 'String', num2str(numberToDisplay));
% REMOVE NaN X/Y splinePointS AND PLOT AGAINST 'TIME' DOMAIN TO GENERATE SPLINE
xPlot = locomotionData(1).Plot;
yPlot = locomotionData(2).Plot;
proj=locomotionData.proj;

[xPlot,yPlot];
fullXPlot = xPlot(~isnan(xPlot)); fullYPlot = yPlot(~isnan(yPlot));
t = 1:length(fullXPlot);

figure; 
hold on; 
axis equal; 

% Plot the path of the worm with gray color
plot(xPlot, yPlot,'color', [1 1 1],'LineWidth', 2);

% Plot the starting point with a red 'X'
plot(xPlot(1), yPlot(1), 'X', 'MarkerFaceColor', 'r', 'MarkerSize', 15, 'LineWidth', 3);

% Iterate over each pair of consecutive points
for i = 2:length(xPlot)
    % Determine the color based on the corresponding value in the proj vector
    if proj(i) < 0
        color = "#FF0000"; % Red color for negative proj value
    else
        color = "#0000FF"; % Blue color for positive proj value
    end
    
    % Plot the line segment between consecutive points with the determined color
    plot([xPlot(i-1), xPlot(i)], [yPlot(i-1), yPlot(i)], '-', 'Color', color,'LineWidth', 1);
end

title('Worm path (''X'' marks the starting point)');
xlabel('x position (um)');
ylabel('y position (um)');

if get(handles.showScatter, 'Value')
    % Create a custom colormap with red and blue colors
    custom_colormap = [1 0 0; 0 0 1];

    % Apply the custom colormap to the current figure
    colormap(custom_colormap);
    scatter_colors = zeros(size(proj)); % Initialize with zeros
    scatter_colors(proj < 0) = 1; % Assign 1 to points with negative proj (red)
    scatter_colors(proj >= 0) = 2; % Assign 2 to points with non-negative proj (blue)
    scatter(xPlot, yPlot, 10, scatter_colors, 'filled');
   
    %scatter(xPlot, yPlot, 20, 'filled', 'MarkerFaceColor', '#0072BD');
end

hold off;



% figure; hold on; axis equal; 
% % plot(xPlot,yPlot,'.-');
% 
% plot(xPlot,yPlot,'color', [.5 .5 .5],'LineWidth',1)
% %plot(xPlot,yPlot,'k','MarkerFaceColor','red','MarkerSize',10,'LineWidth',1)
% hold on  
% plot(xPlot(1),yPlot(1),'X','MarkerFaceColor','r','MarkerSize',15,'LineWidth',2);
% title('Worm path (''X'' marks the starting point)')
% xlabel('x position (um)');
% ylabel('y position (um)');
% 
% if get(handles.showScatter,'Value')
%    scatter(xPlot,yPlot,20,"filled","MarkerFaceColor","#0072BD");
% end

%  
% xGraphPlot = spline(t,fullXPlot,t); yGraphPlot = spline(t,fullYPlot,t);
% lenData = length(xGraphPlot);
% newX = [];
% newY = [];
% distBetween = [];
%%% "MAKE" THE FRAMERATE 10 INSTEAD OF 15 - CUT OUT 5 AFTER EVERY TEN
%%% FRAMES - START AFTER THE 5TH 
%%% DELAY OPTION + SKIP FRAMES OPTION
%delay = str2double(get(handles.delay, 'String'));

% distBetween = [];
% for i = 1:20
%     dis = sqrt(power((xGraphPlot(i) - xGraphPlot(i+1)), 2) + power((yGraphPlot(i) - yGraphPlot(i+1)), 2));
%     distBetween = [distBetween dis];
% end
% outlierDist = isoutlier(distBetween, 'mean');
% %disp(outlierDist);
% outlierDelay = 0;
% for i = 1:20
%     if outlierDist(i) == 1
%         outlierDelay = i;
%         break
%     end
% end
% frameSkip = 4;
% if outlierDelay <= 10
%     delay = outlierDelay+4;
% else
%     delay = outlierDelay - 10;
% end
% 
% for i = delay+1:lenData
%     if mod(i-delay, 15)<(15-frameSkip)
%         newX = [newX xGraphPlot(i)];
%         newY = [newY yGraphPlot(i)];
%     end
% end
% plot(newX, newY);
% %plot(xPlot, yPlot);
% if get(handles.showScatter,'Value')
%    %scatter(xPlot(7:end),yPlot(7:end));
%    scatter(newX, newY);
% end
 
% PLOT X/Y DATA
 
%plot(xPlot(1),yPlot(1),'xr','MarkerSize',12,'LineWidth',2)
% plot(newX(1),newY(1),'xr','MarkerSize',12,'LineWidth',2)
% title('Worm path (''X'' marks starting splinePoint)')
% xlabel('x position (um)');
% ylabel('y position (um)');
 
% for i=24:24:length(xGraphPlot)-2
%     
%     arrowComponents = [xGraphPlot(i+2)-xGraphPlot(i) yGraphPlot(i+2)-yGraphPlot(i)]/2;
%     arrow = annotation('arrow','Color','b','headStyle','vback3','HeadLength',5,'HeadWidth',10);
%     set(arrow,'parent',gca,'position',[xGraphPlot(i) yGraphPlot(i) arrowComponents(1) arrowComponents(2)]);
%     
% end
         
hold off
set(handles.wormAmplitude,'Enable','on');
set(handles.speedAndDistance,'Enable','on');
set(handles.directionAnalysis,'Enable','on');
set(handles.exportWormPath,'Enable','on');
set(handles.binData,'Enable','on');

 
function wormAmplitude_Callback(hObject, eventdata, handles)
corerate=getappdata(0,'rate');
 
[splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles);
reducedframerate = str2double(get(handles.reducedframerate,'String')); 
% GET wL DATA IF IT IS NOT ALREADY SAVED
if isempty(get(handles.movementPanel,'UserData'))
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res,corerate);
    set(handles.movementPanel,'UserData',locomotionData);
else
    locomotionData = get(handles.movementPanel,'UserData');
end
%locomotionData(1)
%locomotionData(2)
amp = locomotionData(1).Amplitude;
alratio = locomotionData(2).Amplitude;
%locomotionData(2)
%locomotionData(2).Amplitude
 
% ROUND AMP AND AMP RATIO
 
meanAmp=mean(amp);
meanAmp=round(meanAmp*100)/100;
alratio=round(alratio*100)/100;
length=meanAmp/alratio;
 
set(handles.movementMessages,'String',['Worm Length ' num2str(round(length,1)) ' µm; Average Amplitude ' num2str(round(meanAmp,1)) ' µm; A/L ratio ' num2str(round(alratio,1))])
 
function speedAndDistance_Callback(hObject, eventdata, handles)
corerate=getappdata(0,'rate');
 
[splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles);
reducedframerate = str2double(get(handles.reducedframerate,'String')); 
% GET wL DATA IF IT IS NOT ALREADY SAVED
if isempty(get(handles.movementPanel,'UserData'))
%     totalFrames = countFramesInFile(splineFile);
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res,corerate);
    set(handles.movementPanel,'UserData',locomotionData);
else
    locomotionData = get(handles.movementPanel,'UserData');
end
xPlot = locomotionData(1).Plot; yPlot = locomotionData(2).Plot;
speed = locomotionData(1).Speed;

[frameFileNumbers,~,splineData,~] = parseSplineFile(splineFile);
frameFileNumbers = frameFileNumbers(1:2:end);
frameFileNumbers = frameFileNumbers(framesToAnalyze(1):framesToAnalyze(2));
frameFileNumbers(end)=[];
% [times,~] = parseTimesFile(timesFile);
% timesNew = diff(times);
%size(speed);
%size(frameFileNumbers);

averageSpeed = mean(speed);
% fullXPlot = xPlot(~isnan(xPlot)); fullYPlot = yPlot(~isnan(yPlot));
% t = 1:length(fullXPlot);

% xGraphPlot = spline(t,fullXPlot,t); yGraphPlot = spline(t,fullYPlot,t);

% lenData = length(xGraphPlot);
% newX = [];
% newY = [];
%delay = str2double(get(handles.delay, 'String'));
% delay = 0;
% for i = delay+1:lenData
%     if mod(i-delay, 15)<(11)
%         newX = [newX xGraphPlot(i)];
%         newY = [newY yGraphPlot(i)];
%     end
% end
% totalDist=0;
% for i = 1:length(newX)-1
%     x1 = newX(i);
%     x2 = newX(i+1);
%     y1 = newY(i);
%     y2 = newY(i+1);
%     totalDist = totalDist + sqrt(((x2-x1)*(x2-x1)) + ((y2-y1)*(y2-y1)));
% end
% timeCalc = lenData/framerate;
% speedNew = totalDist/(timeCalc);
% % totalDistance = locomotionData(1).Distance;
% totalDistance = sum(totalDistance);
%  
% speed = locomotionData.Speed;
%  
netDist = locomotionData(2).Distance;
totalDist = sum(locomotionData(1).Distance);
 
% UNUSED CODE FOR PLOTTING SPEED AGAINST TIME
 
% startTime=0; endTime=length(speed)/framerate;
% times=startTime:1/framerate:endTime;
% avgTimes=[];
% 
% for i=1:length(times)-1
%     avg=mean([times(i) times(i+1)]);
%     avgTimes=[avgTimes avg];
% end
 
% f=figure;
% plot(avgTimes,speed);
% title('Worm speed (absolute value)');
% xlabel('Time (sec)');
% ylabel('Speed (um/sec)');
 
%meanSpeed = mean(speed(~isnan(speed)));
 
%totalDistance = round(totalDistance*100)/100;
totalDist = round(totalDist*100)/100;
%meanSpeed = round(meanSpeed*100)/100;
% speedNew = round(speedNew*100)/100;

set(handles.movementMessages,'String',['Total Distance Traveled ' num2str(round(totalDist,1)) ' um;  Net Distance Traveled ' num2str(round(netDist,1)) ' um;  Average Speed ' num2str(round(averageSpeed,1)) ' um/sec'])
 
function directionAnalysis_Callback(hObject, eventdata, handles)
corerate=getappdata(0,'rate');

[splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles);
reducedframerate = str2double(get(handles.reducedframerate,'String')); 
% GET wL DATA IF IT IS NOT ALREADY SAVED
if isempty(get(handles.movementPanel,'UserData'))
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res,corerate);
    set(handles.movementPanel,'UserData',locomotionData);
else
    locomotionData = get(handles.movementPanel,'UserData');
end

dist = locomotionData(1).Direction;
speed = locomotionData(2).Direction;
%disp(dist)
%disp(speed)

dist = round(dist*100)/100;
speed = round(speed*100)/100;

set(handles.movementMessages,'String',['Forward Distance ' num2str(round(dist(1),1)) ' um;  Forward Speed ' num2str(round(speed(1),1)) ' um/s;' newline ' Backward Distance ' num2str(round(dist(2),1)) ' um;  Backward Speed ' num2str(round(speed(2),1)) ' um/s'])
forwardSpeed_New=locomotionData.forwardSpeed;
times=locomotionData.times;
length(times)

numBins = str2double(get(handles.nbins,'String'));
    
if isnan(numBins)
    disp('Full plot')
    numBins = length(times);      
end

% Check if the number of bins exceeds the length of time
if numBins == length(times)
    numBins=length(times)-1;
elseif numBins >length(times)
    % Display a message box informing the user of the maximum allowed bins
    msgbox(['Number of bins can''t exceed ' num2str(length(times)) ], 'Bin Limit Exceeded', 'warn');
    
    % return
    return;
end

% Determine the total number of points 
totalPoints = length(times);
numBins=numBins+1;
times(1)
% Generate bin edges (similar logic to your curvature binning)
bins = 1:(totalPoints-1)/numBins:totalPoints;

% Discretize the time points based on indices, similar to how curvature was binned
binIdx = discretize(1:totalPoints, bins);


% Initialize arrays to hold the binned speed data
binnedTime = zeros(numBins, 1);
binnedSpeed = zeros(numBins, 1);

% Compute the mean speed for each time bin
for i = 1:numBins
    % Get the indices of the data points that fall into the current bin
    inBin = binIdx == i;
    
    % Compute the mean time and mean speed for the current bin
    binnedTime(i) = mean(times(inBin));
    binnedSpeed(i) = mean(forwardSpeed_New(inBin));
end

% Start of original plotting code
figure;

% Generate a dense set of time points for smooth interpolation, starting from the second point
binnedTimeSmooth = linspace(binnedTime(2), max(binnedTime), 1000); % Ignore the first point for smoothing

% Use cubic spline interpolation to generate smooth speed values
binnedSpeedSmooth = interp1(binnedTime(2:end), binnedSpeed(2:end), binnedTimeSmooth, 'spline');

% Plot the smooth curve with color changes based on whether it is above or below y=0
hold on;
for i = 1:length(binnedTimeSmooth)-1
    if binnedSpeedSmooth(i) > 0 && binnedSpeedSmooth(i+1) > 0
        % Both points are above 0, plot in blue
        plot(binnedTimeSmooth(i:i+1), binnedSpeedSmooth(i:i+1), 'b-', 'LineWidth', 2);
    elseif binnedSpeedSmooth(i) < 0 && binnedSpeedSmooth(i+1) < 0
        % Both points are below 0, plot in red
        plot(binnedTimeSmooth(i:i+1), binnedSpeedSmooth(i:i+1), 'r-', 'LineWidth', 2);
    else
        % The curve crosses y=0, handle the intersection
        t_intersect = interp1([binnedSpeedSmooth(i) binnedSpeedSmooth(i+1)], [binnedTimeSmooth(i) binnedTimeSmooth(i+1)], 0);
        if binnedSpeedSmooth(i) > 0
            % Plot the first segment in blue
            plot([binnedTimeSmooth(i) t_intersect], [binnedSpeedSmooth(i) 0], 'b-', 'LineWidth', 2);
            % Plot the second segment in red
            plot([t_intersect binnedTimeSmooth(i+1)], [0 binnedSpeedSmooth(i+1)], 'r-', 'LineWidth', 2);
        else
            % Plot the first segment in red
            plot([binnedTimeSmooth(i) t_intersect], [binnedSpeedSmooth(i) 0], 'r-', 'LineWidth', 2);
            % Plot the second segment in blue
            plot([t_intersect binnedTimeSmooth(i+1)], [0 binnedSpeedSmooth(i+1)], 'b-', 'LineWidth', 2);
        end
    end
end

% Plot dashed line at y=0
plot(get(gca, 'xlim'), [0 0], '--k');

% Insert text boxes
% Text at the top right corner of the plot
text(max(get(gca, 'xlim')), max(get(gca, 'ylim'))-10, 'Forward', 'Color', 'blue', 'HorizontalAlignment', 'right');

% Text at the bottom right corner of the plot
text(max(get(gca, 'xlim')), min(get(gca, 'ylim'))+15, 'Backward', 'Color', 'red', 'HorizontalAlignment', 'right');

xlabel('time (sec)');
ylabel('Speed (um/sec)');
title('Forward vs Backward Speeds');

hold off;



function exportWormPath_Callback(hObject, eventdata, handles)
corerate=getappdata(0,'rate');
 
[filename,pathname] = uiputfile('*.xlsx','Save Path Data');
 
[splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles);
%framesToAnalyze
[frameFileNumbers,~,~,~] = parseSplineFile(splineFile);
reducedframerate = str2double(get(handles.reducedframerate,'String'));
% GET wL DATA IF IT IS NOT ALREADY SAVED
if isempty(get(handles.movementPanel,'UserData'))
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,reducedframerate,calib,splinePoint,framesToAnalyze,res,corerate);
    set(handles.movementPanel,'UserData',locomotionData);
else
    locomotionData = get(handles.movementPanel,'UserData');
end
 
xData = locomotionData(1).Plot; 
yData = locomotionData(2).Plot;
 
frameFileNumbers = frameFileNumbers(1:2:end);
frameFileNumbersToAnalyze = frameFileNumbers(framesToAnalyze(1):framesToAnalyze(2));
 
timesData = importdata(timesFile);
timesData= timesData.data;
times = timesData(:,1);

if framerate==15 && isnan(reducedframerate)
    times = timesData(frameFileNumbersToAnalyze(1:5:end),1);
else
    times=times;
end

data = [times xData yData];

data_1= table(data,'VariableNames',{'a'});
data_1= splitvars(data_1);
data_1.Properties.VariableNames={'Time (sec)','x (um)','y (um)'};
writetable(data_1,[pathname,filename],'WriteVariableNames',true);
%labels = [{'%%time'} {'%%x'} {'%%y'}];
 
%saveDataMatrix(labels,data,[pathname,filename]);

 
set(handles.movementMessages,'String','Path data exported')
 
function exportPath_Callback(hObject, eventdata, handles)
 
function exportPath_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function browseExport_Callback(hObject, eventdata, handles)
 
[filename,pathname] = uiputfile('*.xlsx','Save export file');
 
if ~isnumeric(filename) && ~isnumeric(pathname)
    set(handles.exportPath,'String',[pathname filename]);
end
 
function exportComments_Callback(hObject, eventdata, handles)
 
function exportComments_CreateFcn(hObject, eventdata, handles)
 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function doMaxBend_Callback(hObject, eventdata, handles)
 
function saveAndAppend_Callback(hObject, eventdata, handles)
comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end
 
path = get(handles.exportPath,'String');
 
[splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles);
class(framesToAnalyze)
StageData = importdata(stageFile);
StageData=StageData.data;

% [times,~] = parseTimesFile(timesFile)
% times = times(framesToAnalyze(1):framesToAnalyze(2));
% timesData= importdata(timesFile);
% framerate=timesData(:,end)
%framesToAnalyze
%framesToAnalyze(1)
%framesToAnalyze(2)
bendNumber = get(handles.bendNumber,'Value');
 
%1.) ANIMAL NAME AND COMMENTS
 
slashPosition = find(splineFile==slash);
slashPosition = slashPosition(end);
animalName = splineFile(1+slashPosition:end-4);
animalName = {animalName};
 
comments=get(handles.exportComments,'String');
 
if isempty(comments)
    comments='';
end
 
comments={comments};
comments
 
%2.) RECORDING LENGTH
 
[frameFileNumbers,~,~] = parseSplineFile(splineFile);
 
numberOfFrames = size(frameFileNumbers,1)/2;
% splinePath = get(handles.splinePath,'String');
% 
% % stagePath = [splinePath(1:lastSlash) wormName slash wormName '.txt'];
% timesPath = [splinePath(1:lastSlash) wormName slash wormName '_times.txt'];
%reducedframerate = get(handles.reducedframerate,'String');
% if reducedframerate=='-'
%     reducedframerate= 15
% elseif reducedframerate=='5'
%     reducedframerate= 3
% elseif reducedframerate=='3'
%     reducedframerate= 5
% elseif reducedframerate=='1'
%     reducedframerate= 1
% end
%size(StageData,1)-1
lengthOfRecording = size(StageData,1)-1;
lengthOfRecording = {num2str(lengthOfRecording)};
 
%3.) SUM OF ANGLES
 
sumOfAngles = averageSumOfBendAngles(splineFile,framesToAnalyze);
sumOfAngles = {num2str(sumOfAngles)};
 
%4.) FREQUNECY OF BEND ANGLES
 
[freq,~,~] = fftFunction(splineFile,bendNumber,framerate,framesToAnalyze);
freq={num2str(freq)};
 
%5.) RMS OF BEND ANGLES
 
rms = findRms(splineFile,bendNumber,framesToAnalyze);
rms = {num2str(rms)};

 
%6.) MAXIMUM BEND ANGLE
 
if get(handles.doMaxBend,'Value')
    [freq,time,selectedBendAngles] = fftFunction(splineFile,bendNumber,framerate,framesToAnalyze);
    exc = bendCursor_gui(time,selectedBendAngles);
    exc = {num2str(exc)};
else
    exc={'N/A'};
end
reducedframerate = str2double(get(handles.reducedframerate,'String'));
%DATA FROM WORM LOCOMOTION FUNCTIONS
 
if isempty(get(handles.movementPanel,'UserData'))
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,reducedframerate,calib,splinePoint,framesToAnalyze,res);
    set(handles.movementPanel,'UserData',locomotionData);
else
    locomotionData = get(handles.movementPanel,'UserData');
end

%7.) AVERAGE AMPLITUDE
%locomotionData(1)
amp = locomotionData(1).Amplitude;
alratio = locomotionData(2).Amplitude;
meanAmp=mean(amp);
length=meanAmp/alratio;
meanAmp={num2str(meanAmp)};
alratio={num2str(alratio)};

 
%8.) AVERAGE SPEED
speed = locomotionData.Speed;
meanSpeed = mean(speed(~isnan(speed)));
meanSpeed = {num2str(meanSpeed)};
 
%9.) DISTANCE
distance = locomotionData(1).Distance;
totalDistance = sum(distance);
netDist = locomotionData(2).Distance;
totalDistance = {num2str(totalDistance)};
netDistance = {num2str(netDist)};
 
%11.) DIRECTION DISTANCES
directionDist = locomotionData(1).Direction;
distForward= directionDist(1);
distBackward = directionDist(2);
%COUNTS
stepsForward = locomotionData(1).Count;
stepsForward = {num2str(stepsForward)};
stepsBackward = locomotionData(2).Count;
stepsBackward = {num2str(stepsBackward)};
 
%10.) DIRECTION SPEEDS
directionSpeeds = locomotionData(2).Direction;
speedForward = directionSpeeds(1);
if isnan(speedForward)
    speedForward={'N/A'};
else
    speedForward = {num2str(speedForward)};
end
speedBackward = directionSpeeds(2);
if isnan(speedBackward)
    speedBackward={'N/A'};
else
    speedBackward = {num2str(speedBackward)};
end
 
%12.) THRASHING COUNT
 [thrashCount,thrashFreq] = thrashingFreq(splineFile,framerate);
 thrashCount = {num2str(thrashCount)};
 thrashFreq = {num2str(thrashFreq)};
 
% thrashCount = 'N/A';
% thrashFreq = 'N/A';
 
if splinePoint == 0
    splinePoint = 'C';
else
    splinePoint = num2str(splinePoint);
end
 
labels=[{'Animal'} {'splinePoint'} {'Bend'} {'Rec Length (s)'} {'Avg Sum Bends (deg)'} {'Freq (Hz)'} {'RMS (deg)'} {'Max Bend (deg)'} {'Avg Amp (µm)'} {'A/L Ratio'} {'wormLength (µm)'} {'Avg Spd (µm/s)'} {'Speed F (µm/s)'} {'Speed B (µm/s)'} {'Tot Dist (µm)'} {'Net Dist (µm)'} {'Dist F (µm)'} {'Dist B (µm)'} {'Frames F'} {'Frames B'} {'Thrash Count'} {'Thrash Freq (/min)'} {'Comments'}];
newDataLine=[animalName {splinePoint} {num2str(bendNumber)} lengthOfRecording sumOfAngles freq rms exc meanAmp alratio length meanSpeed speedForward speedBackward totalDistance netDistance distForward distBackward stepsForward stepsBackward thrashCount thrashFreq comments];
% size(labels)
% size(newDataLine)
exportPath = get(handles.exportPath,'String');
overwriteOption = get(handles.exportPath,'Value');
 
if overwriteOption 
     
    if exist(exportPath,'file')
        delete(exportPath);
    end
    
    newData = [labels;newDataLine];
     
else 
    
    [~,~,oldData] = xlsread(exportPath);
    %(oldData)
    newData = [oldData;newDataLine];
     
end
 
try
    
     
     
%     data=xlsread(exportpath);
%     data(1,:)=[];
    %newData_1=table(newData,'VariableNames',{'a'});
    %newData_1=table(newData);
    %newData_1=splitvars(newData_1);
    %newData_1.Properties.VariableNames={'Animal','splinePoint','Bend','Rec Length','Avg Sum Bends','Freq','RMS','Max Bend','Avg Amp','A/L Ratio','wormLength','Avg Spd','Speed F','Speed B','Tot Dist','Net Dist','Dist F','Dist B','Frames F','Frames B','Thrash Count','Thrash Freq'};
    %writetable(newData_1,exportPath,'WriteVariableNames',true);
    writecell(newData,exportPath);
    disp('Data saved');    
catch ME
     
    disp('Error saving excel file');
    ME
     %[filename,pathname] = uiputfile('*.xlsx','Save Path Data');
end
 
function [splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles)
 
splineFile = get(handles.splinePath,'String');
stageFile = get(handles.stagePath,'String');
timesFile = get(handles.timesPath,'String');
framerate = str2double(get(handles.framerate,'String'));
calib = str2double(get(handles.calib,'String'));
res = get(handles.resHolder,'UserData');
disp(res)
splinePoint = get(handles.splinePoint,'Value')-1;
 
framesToAnalyze = get(handles.framesToAnalyze,'UserData');



function delay_Callback(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay as text
%        str2double(get(hObject,'String')) returns contents of delay as a double


% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frameSkip_Callback(~, eventdata, handles)
% hObject    handle to frameSkip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameSkip as text
%        str2double(get(hObject,'String')) returns contents of frameSkip as a double


% --- Executes during object creation, after setting all properties.
function frameSkip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameSkip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on splinePath and none of its controls.
function splinePath_KeyPressFcn(hObject, ~, handles)
% hObject    handle to splinePath (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over framerate.
function framerate_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function reducedframerate_Callback(hObject, eventdata, handles)
oldFramerate = get(hObject,'Value');
newFramerate = get(hObject,'String');
 
newFramerate = str2double(newFramerate);
 
if ~isnan(newFramerate)
     
    set(hObject,'Value',newFramerate);
    set(handles.movementPanel,'UserData',[]);
    flashBox('g',hObject);
     
else
     
    set(hObject,'String',num2str(oldFramerate));
    flashBox('r',hObject);
     
end
% hObject    handle to reducedframerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reducedframerate as text
%        str2double(get(hObject,'String')) returns contents of reducedframerate as a double


% --- Executes during object creation, after setting all properties.
function reducedframerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reducedframerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over reducedframerate.
function reducedframerate_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to reducedframerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fwdBwdSpectrum.
function fwdBwdSpectrum_Callback(hObject, eventdata, handles)
% hObject    handle to fwdBwdSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
corerate=getappdata(0,'rate');
 
[filename,pathname] = uiputfile('*.xlsx','Save Speed Data');
 
[splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles);
%framesToAnalyze
[frameFileNumbers,~,~,~] = parseSplineFile(splineFile);
reducedframerate = str2double(get(handles.reducedframerate,'String'));
% GET wL DATA IF IT IS NOT ALREADY SAVED
if isempty(get(handles.movementPanel,'UserData'))
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,reducedframerate,calib,splinePoint,framesToAnalyze,res,corerate);
    set(handles.movementPanel,'UserData',locomotionData);
else
    locomotionData = get(handles.movementPanel,'UserData');
end
 
forwardSpeed_New=locomotionData.forwardSpeed;
forwardSpeed_New=forwardSpeed_New(2:end);
times=locomotionData.times;
times=times(2:end);
 
% frameFileNumbers = frameFileNumbers(1:2:end);
% frameFileNumbersToAnalyze = frameFileNumbers(framesToAnalyze(1):framesToAnalyze(2));
% 
% timesData = importdata(timesFile);
% timesData= timesData.data;
% times = timesData(:,1);
% 
% if framerate==15 && isnan(reducedframerate)
%     times = timesData(frameFileNumbersToAnalyze(1:5:end),1);
% else
%     times=times;
% end

data = [times forwardSpeed_New];

data_1= table(data,'VariableNames',{'a'});
data_1= splitvars(data_1);
data_1.Properties.VariableNames={'Time (sec)','Speed (um/sec)'};
writetable(data_1,[pathname,filename],'WriteVariableNames',true);

 
set(handles.movementMessages,'String','Speed data exported')



function nbins_Callback(hObject, eventdata, handles)
% hObject    handle to nbins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nbins as text
%        str2double(get(hObject,'String')) returns contents of nbins as a double


% --- Executes during object creation, after setting all properties.
flashBox('g',handles.nbins);
function nbins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nbins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in speedPlot.
function speedPlot_Callback(hObject, eventdata, handles)
% hObject    handle to speedPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function plotPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in binData.
function binData_Callback(hObject, eventdata, handles)
% hObject    handle to binData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
corerate=getappdata(0,'rate');
 
[filename,pathname] = uiputfile('*.xlsx','Save Binned Speed Data');
 
[splineFile,stageFile,timesFile,framerate,calib,splinePoint,framesToAnalyze,res] = getAnalysisProperties(handles);
%framesToAnalyze
[frameFileNumbers,~,~,~] = parseSplineFile(splineFile);
reducedframerate = str2double(get(handles.reducedframerate,'String'));
% GET wL DATA IF IT IS NOT ALREADY SAVED
if isempty(get(handles.movementPanel,'UserData'))
    locomotionData = newWormLocomotion(splineFile,stageFile,timesFile,framerate,reducedframerate,calib,splinePoint,framesToAnalyze,res,corerate);
    set(handles.movementPanel,'UserData',locomotionData);
else
    locomotionData = get(handles.movementPanel,'UserData');
end
dist = locomotionData(1).Direction;
speed = locomotionData(2).Direction;
%disp(dist)
%disp(speed)

dist = round(dist*100)/100;
speed = round(speed*100)/100;

set(handles.movementMessages,'String',['Forward Distance ' num2str(round(dist(1),1)) ' um;  Forward Speed ' num2str(round(speed(1),1)) ' um/s;' newline ' Backward Distance ' num2str(round(dist(2),1)) ' um;  Backward Speed ' num2str(round(speed(2),1)) ' um/s'])
forwardSpeed_New=locomotionData.forwardSpeed;
times=locomotionData.times;
length(times)

numBins = str2double(get(handles.nbins,'String'));
    
if isnan(numBins)
    disp('Full plot')
    numBins = length(times);      
end

% Check if the number of bins exceeds the length of time
if numBins == length(times)
    numBins=length(times)-1;
elseif numBins >length(times)
    % Display a message box informing the user of the maximum allowed bins
    msgbox(['Number of bins can''t exceed ' num2str(length(times)) ], 'Bin Limit Exceeded', 'warn');
    
    % return
    return;
end

% Determine the total number of points 
totalPoints = length(times);
numBins=numBins+1;
% Generate bin edges (similar logic to your curvature binning)
bins = 1:(totalPoints-1)/numBins:totalPoints;

% Discretize the time points based on indices, similar to how curvature was binned
binIdx = discretize(1:totalPoints, bins);


% Initialize arrays to hold the binned speed data
binnedTime = zeros(numBins, 1);
binnedSpeed = zeros(numBins, 1);

% Compute the mean speed for each time bin
for i = 1:numBins
    % Get the indices of the data points that fall into the current bin
    inBin = binIdx == i;
    
    % Compute the mean time and mean speed for the current bin
    binnedTime(i) = mean(times(inBin));
    binnedSpeed(i) = mean(forwardSpeed_New(inBin));
end

% Generate a dense set of time points for smooth interpolation, starting from the second point
binnedTimeSmooth = linspace(binnedTime(2), max(binnedTime), 1000);% Ignore the first point for smoothing
binnedTimeSmooth_T = linspace(binnedTime(2), max(binnedTime), 1000)';
% Use cubic spline interpolation to generate smooth speed values
binnedSpeedSmooth = interp1(binnedTime(2:end), binnedSpeed(2:end), binnedTimeSmooth, 'spline')';

% deltaTime = binnedTime(2:end) - binnedTime(1:end-1); % Calculate differences for binnedTime
% 
% % Removing the first value of binnedSpeed
%binnedSpeedModified = binnedSpeed(2:end);
% Prepare your data
data = [binnedTime binnedSpeed];

% Define column labels
labels = {'Time (s)', 'Speed (um/sec)', 'Time (Interpolated)', 'Speed (Interpolated)'};

% Write the labels first
writecell(labels, [pathname filename], 'Sheet', 1, 'Range', 'A1');

% Write the first dataset under the first two labels
writematrix(data, [pathname filename], 'Sheet', 1, 'Range', 'A2');

% Write the second dataset (without concatenation)
writematrix(binnedTimeSmooth_T, [pathname filename], 'Sheet', 1, 'Range', 'C2');
writematrix(binnedSpeedSmooth, [pathname filename], 'Sheet', 1, 'Range', 'D2');

 
set(handles.movementMessages,'String','Binned Speed data exported')


% --- Executes during object creation, after setting all properties.
function fwdBwdSpectrum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fwdBwdSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
