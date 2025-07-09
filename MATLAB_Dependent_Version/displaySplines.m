framesToDisplay=frameMatrix(topRow:topRow+1,:);

windowHandles = [handles.winA,handles.winB,handles.winC,handles.winD,handles.winE,handles.winF,handles.winG,handles.winH,handles.winI,handles.winJ];

set(windowHandles,'NextPlot','add');


for i=1:10
    res = [get(gca,'XLim') get(gca,'YLim')];
    res = floor(res);
    currentFrame = framesToDisplay(floor((i-1)/5)+1,mod(i-1,5)+1);
    if currentFrame~=0
        x=splineData(2*currentFrame-1,:);
        y=splineData(2*currentFrame,:);
        if mean(x)~=0 && mean(y)~=0
            plot(windowHandles(i),x,res(4)-y+1,'c')
            plot(windowHandles(i),x(1),res(4)-y(1)+1,'r.','MarkerSize',12)
            plot(windowHandles(i),x(end-2:end),res(4)-y(end-2:end)+1,'m')
            plot(windowHandles(i),x(1:2),res(4)-y(1:2)+1,'r')
        end
        if ~isempty(manualNeeded) && manualNeeded(currentFrame) == 1
            rectangle(windowHandles(i),'Position',[0 0 res(2)/100 res(4)],'FaceColor','r','EdgeColor','r','LineWidth',1)
            rectangle(windowHandles(i),'Position',[0 res(4)-res(2)/100 res(2) res(2)/100],'FaceColor','r','EdgeColor','r','LineWidth',1)
            rectangle(windowHandles(i),'Position',[res(2)-res(2)/100 0 res(2)/100 res(4)],'FaceColor','r','EdgeColor','r','LineWidth',1)
            rectangle(windowHandles(i),'Position',[0 0 res(2) res(2)/100],'FaceColor','r','EdgeColor','r','LineWidth',1)
        end
        
        if ~isempty(ventralDir) && ventralDir(currentFrame)
            
            [startPt,normalArrowComponents] = makeVentralArrow(currentFrame,x,y,ventralDir);
            
            hold(windowHandles(i),'on');
            
            arrowComponents = (res(4)/5)*normalArrowComponents;
            
%             quiver(windowHandles(i),startPt(1),res(4)-startPt(2)+1,arrowComponents(1),arrowComponents(2),'MaxHeadSize',10,'Color','r','LineWidth',1);

            text(windowHandles(i),startPt(1)+arrowComponents(1),res(4)-startPt(2)+1+arrowComponents(2),'V','Color','r');
            
            hold(windowHandles(i),'off');
            
        end



    end
end

set(windowHandles,'NextPlot','replacechildren');