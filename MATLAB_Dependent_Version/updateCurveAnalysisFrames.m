function updateCurveAnalysisFrames(handles,topRow)

frameMatrix = get(handles.frame,'UserData');
framesToDisplay = frameMatrix(topRow:topRow+1,:);
splineFile = get(handles.inputSplinePath,'String');
curveData = get(handles.curveSelectAll,'UserData');

[frameNumbers,ventralData,splineData,~] = parseSplineFile(splineFile);

overrideData = {};
dontSegment = get(handles.dontSegment,'Value');

% LIST OF HANDLES USED FOR SOME LOOPS
panelHandles = [handles.panelA,handles.panelB,handles.panelC,handles.panelD,handles.panelE,handles.panelF,handles.panelG,handles.panelH,handles.panelI,handles.panelJ];
infoHandles = [handles.infoA,handles.infoB,handles.infoC,handles.infoD,handles.infoE,handles.infoF,handles.infoG,handles.infoH,handles.infoI,handles.infoJ];
curveHandles = [handles.curveA,handles.curveB,handles.curveC,handles.curveD,handles.curveE,handles.curveF,handles.curveG,handles.curveH,handles.curveI,handles.curveJ];
frameCountHandles = [handles.frameCountA,handles.frameCountB,handles.frameCountC,handles.frameCountD,handles.frameCountE,handles.frameCountF,handles.frameCountG,handles.frameCountH,handles.frameCountI,handles.frameCountJ];

x = splineData(1:2:end,:); y = splineData(2:2:end,:);

% CHARACTER VECTOR OF COLORS TO CYCLE THROUGHT WHEN DISPLAYING SPLINES
colors = 'rmb';

numberOfFrames = length(frameNumbers)/2;

% IMPORT OVERRIDE DATA IF FOUND
if ~isempty(overrideData)
    overridenFrames = [overrideData{:,1}];
end

for i=1:10
    
    cla(panelHandles(i),'reset');
    set(panelHandles(i),'XTick',[],'YTick',[]);
    hold(panelHandles(i),'on');
    axis(panelHandles(i),'equal');
    
%     FIND CURRENT FRAME USING framesToDisplay MATRIX AND LOOP ITERATION
    currentFrame = framesToDisplay(floor((i-1)/5)+1,mod(i-1,5)+1);
    
    if currentFrame~=0
        
        frameCount = [num2str(currentFrame) ' / ' num2str(numberOfFrames)];
        
        set(curveHandles(i),'Visible','on');
        set(frameCountHandles(i),'String',frameCount);
        set(frameCountHandles(i),'Value',currentFrame);
               
        xSpline = x(currentFrame,:); ySpline = y(currentFrame,:);
        ventralDir = ventralData(currentFrame);
        
%         CALCULATE VALUES USING wC IF NO OVERRIDE FOUND
        if isempty(overrideData) || ~ismember(currentFrame,overridenFrames)
            
            [curvature,circlevdDirs,xySpline,pointList,wormCircles,wormCircleCenters] = wormCurvature(xSpline,ySpline,ventralDir,dontSegment);
           
%         OTHERWISE IMPORT DATA FROM OVERRIDES
        else
            
            overrideRow = overrideData(overridenFrames==currentFrame,:);
            
            curvature = overrideRow{2};
            circlevdDirs = overrideRow{3};
            xySpline = overrideRow{4};
            pointList = overrideRow{5};
            wormCircles = overrideRow{6};
            wormCircleCenters = overrideRow{7};       
            
        end
        
%         PLOT ENTIRE WORM AND WORM HEAD CROSS
        plot(panelHandles(i),xySpline(:,1),xySpline(:,2),'b','LineWidth',2);
        plot(panelHandles(i),xySpline(1,1),xySpline(1,2),'xr','MarkerSize',15);
        
        panelXLim = get(panelHandles(i),'XLim'); panelYLim = get(panelHandles(i),'YLim');
        
%         FOR EACH SEGMENT CREATED BY wC
        for j=1:size(pointList,1)
            
            xSeg = xySpline(pointList(j,1):pointList(j,2),1);
            ySeg = xySpline(pointList(j,1):pointList(j,2),2);
            colorToGraph = colors(mod(j,3)+1);
            
            plot(panelHandles(i),xSeg,ySeg,'Color',colorToGraph,'LineWidth',2); 
            
        end
        
%         EXTEND THE LIMITS OF THE GRAPH A LITTLE BIT (~10%) FOR A BETTER
%         DISPLAY OF THE WORM
        panelXLim = [panelXLim(1)-(diff(panelXLim)/10) panelXLim(2)+(diff(panelXLim)/10)];
        panelYLim = [panelYLim(1)-(diff(panelYLim)/10) panelYLim(2)+(diff(panelYLim)/10)];

        set(panelHandles(i),'XLim',panelXLim,'YLim',panelYLim);
        
%         REMOVE NON-EXISTENT CIRCLES FROM CIRCLE LIST (CREATED BY VERY
%         SHORT WORM SEGMENTS)
        wormCircleCenters = wormCircleCenters(~cellfun('isempty',wormCircles));
        wormCircles = wormCircles(~cellfun('isempty',wormCircles));
        
        for j=1:length(wormCircles)
            
            segmentCircle = wormCircles{j};
            segmentCircleCenter = wormCircleCenters{j};
            
%             FIND APPROPRIATE PLACEMENT FOR WORM TEXT
            textPos = [NaN NaN];
            textPos(1) = min([max([1.05*panelXLim(1) segmentCircleCenter(1)]) 1*panelXLim(2)]);
            textPos(2) = min([max([1.05*panelYLim(1) segmentCircleCenter(2)]) 1*panelYLim(2)]);
            
%             FIND LINE STYLE, BASED ON VENTRAL DIRECTION:
%             (SOLID-V,DASHED-D,DOTTED-UNKNOWN)
            switch circlevdDirs(j)
                case 1
                    lineStyle = '-';
                case -1
                    lineStyle = '-.';
                case 0
                    lineStyle = ':';
            end
            
            plot(panelHandles(i),segmentCircle(:,1),segmentCircle(:,2),'Color','k','LineStyle',lineStyle);
            text(panelHandles(i),textPos(1),textPos(2),num2str(j),'FontSize',10);
            
        end
         
%         CREATE DISPLAY TEXT, CONTAINING CURVATURE VALUES AS ONE STRING
        infoDisplayText = cell([1 2*length(curvature)]);
        
        for j=1:length(curvature)
            
            infoDisplayText(2*j-1:2*j) = [{num2str(round(curvature(j)*10)/10)} {' / '}];
            
        end
        
        infoDisplayText = ['(L/r): ' cell2mat(infoDisplayText(1:end-1))];
        
        set(infoHandles(i),'String',infoDisplayText);
        
%         OLD CODE THAT SHOWS ALTERNATIVE STRING
%         curveNumberPercentString = cell([1 length(curvature)]);
%         
%         for j=1:length(curvature)
%             curveNumberString = pad(num2str(j));
%             curvePercentString = [num2str(round(1000*curvature(j))/10) '%'];
%             curveNumberPercentString{j} = [curveNumberString ': ' curvePercentString ' / '];
%         end
        
%         curveNumberPercentString = cell2mat(curveNumberPercentString);
%         curveNumberPercentString = ['Curve #: % of worm length:         ' curveNumberPercentString(:,1:end-3)];
        
%         set(infoHandles(i),'String',curveNumberPercentString);

%         RETRIEVE USER-SET CURVE TO STORE IN CURVE NUMBER BOX
        curveNum = curveData(currentFrame);
        
        if curveNum==0
            curveNumStr = '#';
        else
            curveNumStr = num2str(curveNum);
        end
        
        set(curveHandles(i),'String',curveNumStr);

%     IF NO FRAME, DISPLAY BLANK STATE
    else
        set(frameCountHandles(i),'String','--- / ---');
        set(panelHandles(i),'Color',[.831 .816 .784]);
        set(curveHandles(i),'Visible','Off');
    end
end  