buttonLabel=get(buttonHandle,'String');
frames=(currFrame-1)*2+1:(currFrame-1)*2+2; 
x=splineData(frames(1),:);
y=splineData(frames(2),:);
x=interp(x,9);
y=interp(y,9);
x=x(1:5:end);
y=y(1:5:end);

if strcmp(buttonLabel,'Fix curve')
    prompt = {'Enter curve to modify:'};
    dlg_title = 'Curve input';
    num_lines = 1;
    def = {'1'};
    curveNum = inputdlg(prompt,dlg_title,num_lines,def);
    curveNum=str2num(curveNum{1});

    axes(panel)
    hold off
    plot(x,y,'LineWidth',2)
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    datacursormode on
    set(buttonHandle,'String','Done')
    data=get(handles.fixA,'UserData'); %will always use fixA button for UserData, regardless of which button actually accesses this function
    data=[data; currFrame curveNum 0 0 0 0];
    set(handles.fixA,'UserData',data)

elseif strcmp(buttonLabel,'Done')
    axes(panel)
    datacursormode off
    dcm_obj = datacursormode(gcf);
    info_struct = getCursorInfo(dcm_obj);
    indA=info_struct(1).DataIndex;
    indB=info_struct(2).DataIndex;
    ind=[indA indB]; ind=sort(ind);
    X=x(ind(1):ind(2));
    Y=y(ind(1):ind(2));
    vd=ventralData(currFrame);
    cw=isClockwise(X,Y);
    if cw && vd==1
        dir=-1; %dorsal
    elseif cw && vd==2
        dir=1; %ventral
    elseif ~cw && vd==1
        dir=1; %ventral
    elseif ~cw && vd==2
        dir=-1; %dorsal
    elseif vd==0
        dir=0; %undecided
    end    
    
    XY=[X' Y'];
    Par = CircleFitByKasa(XY);
    a=Par(1); b=Par(2); r=Par(3);
    data=get(handles.fixA,'UserData');
    data(end,:)=[data(end,1) data(end,2) a b r dir];
    set(handles.fixA,'UserData',data)
    set(buttonHandle,'String','Fix curve');
    
    currFrame=get(handles.currFrame,'UserData');
    currFrame=currFrame(1);
    if currFrame==1
        set(handles.back,'Visible','Off')
    end
    displayCurveAnalysisFrames
end