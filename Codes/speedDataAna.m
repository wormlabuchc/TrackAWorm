classdef speedDataAna<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
        speedax
        thresholdEdit
        countEdit
        minpeakEdit
        resetBtn
        anaBtn
        %% result
        durationEdit
        motionlessEdit
        eventsFreqEdit
        meventEdit
        %% line object
        obj_line
        vline_beginning
        vline_end
        %% data
        data_cy
        eventMarker
    end
    
    methods
        function obj = speedDataAna(cy)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.data_cy = cy;
            speedgui = figure('Name','WormLabApp','Position',[100 50 1024 568],'IntegerHandle', 'off', 'Resize', 'off','Units','pixels');
            speedgui.MenuBar = 'none';
            speedgui.ToolBar = 'none';
            obj.speedax = axes(speedgui,'Units','pixels','Box','on','Position',[300 150 700 400]);
            ylabelStr = ['Speed ( ',char(181),'m/10s )'];
            
            obj.speedax.YLabel.String = ylabelStr;
            obj.speedax.XLabel.String = 'Image sequence number';
            obj.speedax.YLim = [0 400];
            
            cy_length  = length(cy);
            cx = 1:cy_length;
            obj.obj_line = line(obj.speedax,'XData',cx,'YData',cy);
%             xline(obj.speedax,200);
            obj.vline_beginning = drawline(obj.speedax,'Position',[180 0;180 400],'Color','b');
            obj.vline_end = drawline(obj.speedax,'Position',[1000 0;1000 400],'Color','b');
            %% setup for analysis
            threshold_str = ['Threshold (',char(181),'m): '];
            uicontrol(speedgui,'Style','text','Position',[10 500 120 30],'String',threshold_str,'FontSize',10);
            obj.thresholdEdit = uicontrol(speedgui,'Style','edit','Position',[125 508 50 25],'String','20','FontSize',10);
            uicontrol(speedgui,'Style','text','Position',[60 460 80 30],'String','Count: ','FontSize',10);
            obj.countEdit = uicontrol(speedgui,'Style','edit','Position',[125 470 50 25],'String','3','FontSize',10);
            uicontrol(speedgui,'Style','text','Position',[10 423 120 30],'String','MinPeakDistance: ','FontSize',10);
            obj.minpeakEdit = uicontrol(speedgui,'Style','edit','Position',[125 430 50 25],'String','10','FontSize',10);
            %% ana button
            obj.anaBtn = uicontrol(speedgui,'Style','pushbutton','Position',[125 380 60 25],'String','Analyze','FontSize',10,'Callback',@obj.anafunction);
            obj.resetBtn = uicontrol(speedgui,'Style','pushbutton','Position',[30 380 60 25],'String','Reset','FontSize',10);
            
            %% result item
            uicontrol(speedgui,'Style','text','Position',[10 300 120 30],'String','Duration (min):  ','FontSize',10);
            obj.durationEdit = uicontrol(speedgui,'Style','edit','Position',[125 310 80 20],'String','0','FontSize',10);
            uicontrol(speedgui,'Style','text','Position',[10 260 100 30],'String','Motionless Duration (min):  ','FontSize',10);
            obj.motionlessEdit = uicontrol(speedgui,'Style','edit','Position',[125 265 80 20],'String','0','FontSize',10);
            uicontrol(speedgui,'Style','text','Position',[10 210 110 40],'String','Events Frequency ( /h):  ','FontSize',10);
            obj.eventsFreqEdit = uicontrol(speedgui,'Style','edit','Position',[125 225 80 20],'String','0','FontSize',10);
            uicontrol(speedgui,'Style','text','Position',[10 170 110 40],'String','Mean Duration of event (s) :  ','FontSize',10);
            obj.meventEdit = uicontrol(speedgui,'Style','edit','Position',[125 185 80 20],'String','0','FontSize',10);
        end
        
        function anafunction(obj,~,~)
            speed_threshold = str2double(obj.thresholdEdit.String);
            countValue = str2double(obj.countEdit.String);
            minpeakDist = str2double(obj.minpeakEdit.String);
            h_count = 0;
            i = uint16(obj.vline_beginning.Position(1,1));
            %% find the beginning point
            while true
                if h_count>countValue
                    break;
                elseif obj.data_cy(i)<speed_threshold
                    h_count = h_count + 1;
                    i = i + 1;
                else
                    i = i + 1;
                    h_count = 0;
                end
            end
            obj.vline_beginning.Position = [i 0;i 400];
            %% find the end point
            j = uint16(obj.vline_end.Position(1,1));
            count_end = 0;
            while true
                if count_end>countValue
                    break;
                elseif obj.data_cy(j)<speed_threshold
                    count_end = count_end + 1;
                    j = j - 1;
                else
                    j = j - 1;
                    count_end = 0;
                end
                
            end
            obj.vline_end.Position(:,1)= j;
            sleepDuration = (j-i)/6;
            obj.durationEdit.String = num2str(sleepDuration);
            %% find peaks
            [pks,locs,w,~] = findpeaks(obj.data_cy(i:j),'MinPeakHeight',speed_threshold,'MinPeakDistance',minpeakDist);
            hold(obj.speedax,'on');
            if ~isobject(obj.eventMarker)
                obj.eventMarker = plot(obj.speedax,double(i)+locs,pks,'*','MarkerEdgeColor','r');
            else
                obj.eventMarker.XData = double(i)+locs;
                obj.eventMarker.YData = pks;
            end
            hold(obj.speedax,'off');
            peaknumber = length(pks);
            eventfreq = uint16(peaknumber)/(sleepDuration/60);
            obj.eventsFreqEdit.String = num2str(eventfreq);
            obj.motionlessEdit.String = num2str(sleepDuration - (sum(w)/6));
            obj.meventEdit.String =num2str(10*mean(w));
        end
        function resetfunction(obj,~,~)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.thresholdEdit.String = '20';
            obj.countEdit.String = '3';
            
        end
    end
end

