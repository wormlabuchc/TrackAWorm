function updateBatchTrackFrames(handles,topRow)

frameMatrix = get(handles.frame,'UserData');
framesToDisplay = frameMatrix(topRow:topRow+1,:);
fileList = get(handles.imagePath,'UserData');
ventralDir = get(handles.ventralMessage,'UserData');
splineData = get(handles.inputSplinePath,'UserData');
crossData = get(handles.crossA,'UserData');
manualNeeded = get(handles.manualNeededText,'UserData');

x = splineData(1:2:end,:);
y = splineData(2:2:end,:);

frameHandles = [handles.frameA,handles.frameB,handles.frameC,handles.frameD,handles.frameE,handles.frameF,handles.frameG,handles.frameH,handles.frameI,handles.frameJ];
windowHandles = [handles.winA,handles.winB,handles.winC,handles.winD,handles.winE,handles.winF,handles.winG,handles.winH,handles.winI,handles.winJ];
swapHandles = [handles.swapA,handles.swapB,handles.swapC,handles.swapD,handles.swapE,handles.swapF,handles.swapG,handles.swapH,handles.swapI,handles.swapJ];
manualHandles = [handles.manualA,handles.manualB,handles.manualC,handles.manualD,handles.manualE,handles.manualF,handles.manualG,handles.manualH,handles.manualI,handles.manualJ];
crossHandles = [handles.crossA,handles.crossB,handles.crossC,handles.crossD,handles.crossE,handles.crossF,handles.crossG,handles.crossH,handles.crossI,handles.crossJ];

set(windowHandles,'NextPlot','add');

for i=1:10
    
    c = get(windowHandles(i),'children');
    delete(c)
    
    currentFrame = framesToDisplay(floor((i-1)/5)+1,mod(i-1,5)+1);
    set(frameHandles(i),'String',num2str(currentFrame));
    
    if currentFrame~=0
        
        img = imread(fileList{currentFrame});
        fileList(currentFrame);
        imshow(img,'Parent',windowHandles(i))
        set(swapHandles(i),'Enable','on');
        set(manualHandles(i),'Enable','on');
        set(crossHandles(i),'Enable','on');
        res = size(img);
        
    else
        
        set(swapHandles(i),'Enable','off');
        set(manualHandles(i),'Enable','off');
        set(crossHandles(i),'Enable','off');

        set(windowHandles(i),'Color',[.831 .816 .784]);
        
    end
    
    if currentFrame~=0 && exist('x','var') && ~isempty(x)
        xSpline = x(currentFrame,:);
        ySpline = y(currentFrame,:);
        xC = mean(xSpline,2);
        yC= mean(ySpline,2);
        
        if mean(xSpline)~=0 && mean(ySpline)~=0
            
            plot(windowHandles(i),xSpline,res(1)-ySpline+1,'c', 'LineWidth',1) %body
            
            plot(windowHandles(i),xSpline(end-2:end),res(1)-ySpline(end-2:end)+1,'m','LineWidth',1) %Towards head
            plot(windowHandles(i),xSpline(1:2),res(1)-ySpline(1:2)+1,'r','LineWidth',1) %Towards tail
            scatter(windowHandles(i),xSpline,res(1)-ySpline+1,12,'filled', 'MarkerFaceColor', 'w')
            %scatter(windowHandles(i),xSpline,res(1)-ySpline+1,20,'o', 'MarkerEdgeColor', 'w')
            plot(windowHandles(i),xSpline(1),res(1)-ySpline(1)+1,'r.','MarkerSize',20) %head
            scatter(windowHandles(i),xC,res(1)-yC+1,30,'filled', 'MarkerFaceColor', [1, 0.5, 0]);
        end
        
        if ~isempty(manualNeeded) && manualNeeded(currentFrame) == 1
            
            rectangle(windowHandles(i),'Position',[0 0 res(2)/100 res(1)],'FaceColor','r','EdgeColor','r','LineWidth',1)
            rectangle(windowHandles(i),'Position',[0 res(1)-res(2)/100 res(2) res(2)/100],'FaceColor','r','EdgeColor','r','LineWidth',1)
            rectangle(windowHandles(i),'Position',[res(2)-res(2)/100 0 res(2)/100 res(1)],'FaceColor','r','EdgeColor','r','LineWidth',1)
            rectangle(windowHandles(i),'Position',[0 0 res(2) res(2)/100],'FaceColor','r','EdgeColor','r','LineWidth',1)
            
        end
        
        if ~isempty(ventralDir) && ventralDir(currentFrame)
           
            [startPt,normalArrowComponents] = makeVentralArrow(currentFrame,xSpline,ySpline,ventralDir);
            
            hold(windowHandles(i),'on');
            
            arrowComponents = (res(1)/5)*normalArrowComponents;
            
%             quiver(windowHandles(i),startPt(1),res(1)-startPt(2)+1,arrowComponents(1),arrowComponents(2),'MaxHeadSize',10,'Color','r','LineWidth',1);
            
            text(windowHandles(i),startPt(1)+arrowComponents(1),res(1)-startPt(2)+1+arrowComponents(2),'V','Color','r');
            
            hold(windowHandles(i),'off');
            
        end           
            
    end
    
    if ~currentFrame==0 && ~isempty(crossData)
    
        xCross = crossData(2*currentFrame-1,:);
        yCross = crossData(2*currentFrame,:);
    
        if any(xCross) || any(yCross)
            set(crossHandles(i),'Enable','on');
        else
            set(crossHandles(i),'Enable','on');
        end
        
    else
        
        set(crossHandles(i),'Enable','on');
        
    end
    
end

set(windowHandles,'NextPlot','replacechildren');