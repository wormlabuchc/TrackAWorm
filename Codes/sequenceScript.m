drawnow
ch1=get(handles.ch1,'Value');
ch2=get(handles.ch2,'Value');
ch3=get(handles.ch3,'Value');
rpt1=str2num(get(handles.repeat1,'String'));
rpt2=str2num(get(handles.repeat2,'String'));
rpt3=str2num(get(handles.repeat3,'String'));
% rectime=get(handles.rectime,'String'); rectime=str2double(rectime);

if strcmp(eventdata.Key,'return')
    currLen=str2num(get(handles.seqlength,'String'));
    if ch1
        currStr1=get(handles.sequence1,'String');
        currStr1=processSequence(currStr1,rpt1);
    else
        currStr1=[];
    end
    if ch2
        currStr2=get(handles.sequence2,'String');
        currStr2=processSequence(currStr2,rpt2);
    else
        currStr2=[];
    end
    if ch3
        currStr3=get(handles.sequence3,'String');
        currStr3=processSequence(currStr3,rpt3);
    else
        currStr3=[];
    end
    lengths=[length(currStr1) length(currStr2) length(currStr3)];
    newLen=max(lengths);
    newLen=num2str(newLen);
    set(handles.seqlength,'String',newLen)
    drawnow
end