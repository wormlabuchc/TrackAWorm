classdef APana < handle
    properties
        Value {mustBeNumeric}
        gui;  %camera videoinput handle
        ax_AP;       %axes handle
        line_ap;
        line_APD50;
        threshpoint;
        rmline;
        bwmrmpline;
        AP_merge
        phase_merge
        ax_trace;
        ax_overlap;
        apMerge_y;
        pl_m_y;
        pl_m_x;
        phaseArray;
        ax_phase;
        pasteBtn; %connect camera handle
        % set parameters
        mousebaseline;
        bwmbaseline
        anaBtn
        data_table;
        cm
        lineData
        ap_x
        ap_y
        ap_single_y
        ap_baseline_y

        pks;
        locs;
        minipeak {mustBeNumeric};
        neuron_box
        bmw_box
        neuron_gap
        % C.elegans body wall muscle action potential
        bmw_threshold
        bmw_gap
        runoneAP
        runonebackbtn

        AP_duration
        AP_count
        trace_AP_mark
        %
        apfreq
        ppvalue = 0;
        data_Frequency
        PPms
        data_RMP
        data_APD50
        data_AHP
        data_baselineAHP
        data_Amplitude
        %
        table_row = []
        % overlap axes setting
        base_point

        % table
        tableData
        tablearray


    end
    methods
        function obj = APana  % it is a constructor funciton
            obj.gui = uifigure('Name','Action Potential app','Position',[0 0 1200 800], 'IntegerHandle', 'off', 'Resize', 'on','AutoResizeChildren','on');
            
            obj.gui.MenuBar = 'none';
            obj.gui.ToolBar = 'none';

            aplayout = uigridlayout(obj.gui);
            aplayout.RowHeight = {300,300,'1x'};
            aplayout.ColumnWidth ={320,'2x','1x','1x'};
            % create axes in figure obj.gui
            obj.ax_AP = uiaxes(aplayout,'Position',[0.22 0.065 0.35 0.5],'XLim',[0 70],'YLim',[-70 50],'XTick',0:10:70,'YTick', -70:20:50,'Units', 'pixels',TickDir='out');
            obj.ax_AP.XLabel.String = 'Time (ms)';
            obj.ax_AP.YLabel.String = 'Membrane Potential (mV)';
            obj.ax_AP.Title.String = 'Selected AP';
            obj.ax_AP.Toolbar.Visible = 'off'; 
            obj.ax_AP.Layout.Row = [2 3];
            obj.ax_AP.Layout.Column = 2;

            %obj.ax_trace  = axes(obj.gui,'Position',[0.22 0.68 0.77 0.28],'XLim',[0 100],'YLim',[-80 80],'XTick',0:10:100,'YTick',-80:20:80,'Units', 'pixels',TickDir='out',TickLength=[0.002 0.025]);
            tracepanel = uipanel(aplayout,'BorderType','none','Units','normalized');
            obj.ax_trace  = uiaxes(tracepanel,'Position',[0 0 1362 300],'XLim',[0 100],'YLim',[-80 80],'XTick',0:10:100,'YTick',-80:20:80,'Units', 'pixels',TickDir='out',TickLength=[0.002 0.025]);
            obj.ax_trace.Title.String = 'AP Overview';
            obj.ax_trace.YLabel.String ='Membrane Potential (mV)';
            obj.ax_trace.XLabel.String = 'Time (s)';
             obj.ax_trace.Toolbar.Visible = 'off';   

            tracepanel.Layout.Row = 1;
            tracepanel.Layout.Column = [2 4];

            obj.ax_overlap  = uiaxes(aplayout,'Position',[0.61 0.30 0.17 0.26],'XLim',[0 80],'YLim',[-70 50],'Units', 'pixels',TickDir='out');
            obj.ax_overlap.Title.String = 'AP Overlay';
            obj.ax_overlap.XLabel.String = 'Time (ms)';
            obj.ax_overlap.YLabel.String = 'Membrane Potential (mV)';
            obj.ax_overlap.Toolbar.Visible = 'off'; 
            obj.ax_overlap.Layout.Row = 2;
            obj.ax_overlap.Layout.Column = 3;

            % uicontrol(obj.gui,'Style', 'pushbutton', 'Position', [1310 20 100 20],'String', 'Export to Excel','FontSize',10, 'Callback',@obj.exportdata);
            obj.ax_phase  = uiaxes(aplayout,'Position',[0.818 0.30 0.17 0.26],'XLim',[-60 50],'YLim',[-60 120],'XTick',-60:20:50,'YTick',-60:20:120,'Units', 'pixels',TickDir='out');

            obj.ax_phase.Title.String = 'Voltage Phase Plot Overlay';
            obj.ax_phase.YLabel.String = 'dV/dt (mV/ms)';
            obj.ax_phase.XLabel.String = 'Membrane Potential (mV)';
            obj.ax_phase.Toolbar.Visible = 'off'; 
            obj.ax_phase.Layout.Row = 2;
            obj.ax_phase.Layout.Column = 4;

            setpanel = uipanel(aplayout,'BorderType','none','Position',[0 0 300 600]);
            setpanel.Layout.Row = [1 2];
            setpanel.Layout.Column = 1;


            uicontrol(setpanel,'Style', 'text', 'Position', [90 430 90 30],'String','Cell Type','FontSize',15,'FontWeight','bold');

            obj.neuron_box = uicontrol(setpanel,'Style', 'checkbox', 'Position', [40 200 190 40],'String', '  Mammalian Neurons','FontSize',12,'FontWeight','bold','Callback',@obj.neuron_checkbox);
            uicontrol(setpanel,'Style', 'text', 'Position', [60 166 127 30],'String','Threshold detection','FontSize',10);
            uicontrol(setpanel,'Style', 'text', 'Position', [70 145 80 30],'String','Auto (dV/dt)','FontSize',10);

            uicontrol(setpanel,'Style', 'text', 'Position', [60 115 215 30],'String','Resting membrane potential search','FontSize',10);
            uicontrol(setpanel,'Style', 'text', 'Position', [60 95 130 30],'String','Time before peak ','FontSize',10);
            uicontrol(setpanel,'Style', 'text', 'Position', [265 95 20 30],'String','ms','FontSize',10);
            obj.mousebaseline = uicontrol(setpanel,'Style', 'edit', 'Position', [225 105 30 22],'String', 20, 'FontSize', 10);

            obj.bmw_box = uicontrol(setpanel,'Style', 'checkbox', 'Position', [40 360 130 40],'String', ' C.elegans','FontSize',12,'FontWeight','bold','FontAngle','italic','Callback',@obj.bwm_checkbox);
            uicontrol(setpanel,'Style', 'text', 'Position', [137 350 100 40],'String', 'Muscle Cells','FontSize',12,FontWeight='bold');

            uicontrol(setpanel,'Style', 'text', 'Position', [60 320 127 40],'String', 'Threshold detection ','FontSize',10);
            uicontrol(setpanel,'Style', 'text', 'Position', [55 300 140 40],'String', 'Time before peak ','FontSize',10);
            uicontrol(setpanel,'Style', 'text', 'Position', [265 300 20 40],'String', 'ms','FontSize',10);
            obj.bmw_threshold = uicontrol(setpanel,'Style', 'edit', 'Position', [230 320 30 22],'String', 40, 'FontSize', 10);

            uicontrol(setpanel,'Style', 'text', 'Position', [58 280 223 30],'String','Resting membrane potential search','FontSize',10);
            uicontrol(setpanel,'Style', 'text', 'Position', [55 260 140 30],'String','Time before peak ','FontSize',10);
            uicontrol(setpanel,'Style', 'text', 'Position', [265 260 20 30],'String','ms','FontSize',10);
            obj.bwmbaseline = uicontrol(setpanel,'Style', 'edit', 'Position', [230 270 30 22],'String', 40, 'FontSize', 10);


            obj.pasteBtn = uicontrol(setpanel,'Style', 'pushbutton', 'Position', [37 65 240 22],'FontName', 'arial','FontSize',10,...
                 'Callback', @obj.pasteData, 'String', 'Click to paste 10 kHz sampled AP data');
            % uicontrol(tracepanel,'Style', 'text', 'Position', [1000 220 120 20],'String', 'Firing Rate (APs/s) : ','FontSize',10,'HorizontalAlignment','left','BackgroundColor', [1 1 1]);
            uilabel(setpanel,'Text','Firing Rate (APs/s) :','Position',[60 35 120 20]);
            % obj.apfreq = uicontrol(tracepanel,'Style', 'edit', 'Position', [1120 120 40 20],'String','0','FontSize',10);
            obj.apfreq = uieditfield(setpanel,'numeric','Position',[225 35 30 22],'Value', 0,'HorizontalAlignment','center');
   

            bg = uibuttongroup(setpanel,'Position',[50 0 90 25]);
            obj.runonebackbtn = uibutton(bg,"push",'Position',[0 0 30 25],'ButtonPushedFcn',@obj.runone,'Text','<');
            obj.runoneAP = uibutton(bg,"push",'Position',[30 0 30 25],'ButtonPushedFcn',@obj.runone,'Text','>');
            obj.anaBtn = uibutton(bg,"push",'Position',[60 0 30 25],'ButtonPushedFcn',@obj.runAna,'Text','>>>');

            obj.AP_count = uieditfield(setpanel,"numeric",'Position',[225 0 30 22],'Value',0,'HorizontalAlignment','center');

            obj.data_table = uitable(aplayout,'Data', [], 'ColumnName', {'RMP', 'TH', 'AP Amp', 'APD50','AHP','Rise time','Decay time','Max slope','Min slope', 'Rise Slope', 'Decay Slope'},'RowName',{'Mean';'SE'}, 'Position', [1000 60 690 150],'ColumnWidth','fit');
            obj.data_table.Layout.Row = 3;
            obj.data_table.Layout.Column = [3 4];
            cm = uicontextmenu(obj.gui);
            m1 = uimenu(cm,'Text','Export to Excel','MenuSelectedFcn',@obj.exportdata);
            obj.data_table.ContextMenu = cm;



        end
        function runAna(obj,~,~)

            while true
                anaNo = str2double(obj.AP_count.String)+1;
                if anaNo>length(obj.locs)
                    break;
                else
                    obj.runone();
                end
            end
        end
        function runAnaBWM(obj,~,~) % for C.elegans BWM

            while true
                anaNo = str2double(obj.AP_count.String)+1;
                peak_no = length(obj.locs);
                if anaNo>peak_no
                    warndlg('AP analysis is done','Warning');
                    break;
                else
                    obj.runonebwmforward();
                end
            end
        end
        function [data_threshold, data_threshold_locs] = find_threshold(~,data_y,~)
            data_len = length(data_y);
            data_differ = zeros(1,(data_len - 1));
            for i = 1:(data_len-5)
                data_differ(i) = data_y(i+1) - data_y(i);
                if data_differ(i)>2
                    data_threshold = data_y(i);
                    data_threshold_locs = i-1;
                end
            end
        end
        function [data, locs]=find_baseline(~,data_y,~)
            data_len = length(data_y);
            data_differ = zeros(1,(data_len - 1));
            for i = 1:(data_len-5)
                data_differ(i) = data_y(data_len - i) - data_y(data_len-i-4);
                if data_differ(i)<1
                    data = data_y(i);
                    locs = i;
                    break;
                end
            end
        end

        function runone(obj,~,~)  % for mouse Neuron runone analyze Ap

            if obj.locs(1)<400
                anaNo = 2;
                obj.AP_count.Value = 2;
                ppmsval = obj.PPms(anaNo - 1);
            elseif 0==(obj.AP_count.Value)
                anaNo = 1;
                obj.AP_count.Value = anaNo;
                ppmsval = 0;
            else
                anaNo = obj.AP_count.Value + 1;
                obj.AP_count.Value = anaNo;
                if anaNo>length(obj.locs)
                    warndlg('AP analysis is done','Warning');
                    return;
                end
                ppmsval = obj.PPms(anaNo - 1);
            end
            peak_no = length(obj.locs);
            if anaNo>peak_no
                warndlg('AP analysis is done','Warning');
                return;
            end

            apLoc = obj.locs(anaNo);
            y = obj.ap_y((apLoc-400):(apLoc+300));

            x = 0.1:0.1:(length(y)/10);
            if isempty(obj.line_ap)
                obj.line_ap = line(obj.ax_AP,'XData', x, 'YData', y, 'LineWidth', 1.5);
            else
                obj.line_ap.XData = x;
                obj.line_ap.YData = y;
            end
            obj.ax_AP.Box = 'off';
            obj.ax_AP.XLabel.String = 'Time (ms)';
            obj.ax_AP.YLabel.String = 'Membrane Potential (mV)';
            hold(obj.ax_trace,'on');
            %show peak point

            if isempty(obj.trace_AP_mark)
                obj.trace_AP_mark = drawpoint(obj.ax_trace, Position=[obj.locs(anaNo)/10000, obj.pks(anaNo)]);
            else
                obj.trace_AP_mark.Position = [obj.locs(anaNo)/10000, obj.pks(anaNo)];
            end
            hold(obj.ax_trace,'off');
            obj.ap_single_y = obj.ap_y((apLoc-100):apLoc);
            line_L = obj.ap_single_y;
            line_R = obj.ap_y(apLoc:(apLoc +100));
            obj.ap_baseline_y = y(1:400);
            hold(obj.ax_AP,'on');
            % find and show threshold point.
            data_threshold_locs = find(diff(obj.ap_single_y)>0.6,1,"first")-2; % to find threshold location.
            if isempty(obj.base_point)
                obj.base_point.x = (data_threshold_locs + 300)/10;
                obj.base_point.y = obj.ap_single_y(data_threshold_locs);
                threshold_point.x = (data_threshold_locs+300)/10;
                threshold_point.y = obj.ap_single_y(data_threshold_locs);
                obj.threshpoint = drawpoint(obj.ax_AP,Position=[threshold_point.x, threshold_point.y], Color='green');

            else
                threshold_point.x = (data_threshold_locs+300)/10;
                threshold_point.y = obj.ap_single_y(data_threshold_locs);
                obj.threshpoint.Position = [threshold_point.x, threshold_point.y];
            end
            % calculate rise time and rise slope
            risephase_y = line_L(data_threshold_locs:100);
            riseslop = max(diff(risephase_y))*10;
            risetime = length(risephase_y)/10;

            decaythresh_plocs = find(line_R<threshold_point.y, 1);
            decayphase_y = line_R(1:decaythresh_plocs);
            decayslop = min(diff(decayphase_y))*10;
            decaytime = length(decayphase_y)/10;

            % define AP amplitude between threshold and peak
            ap_amp = obj.pks(anaNo) - threshold_point.y;
            %% calculate 10-90% slope
            rise_fp = find((risephase_y - threshold_point.y)>ap_amp*0.1,1,"first");
            rise_lp = find((risephase_y - threshold_point.y)>ap_amp*0.9,1,"first");
            risephase10_90_y = risephase_y(rise_fp:rise_lp);
            riseslop10_90 = polyfit(0.1:0.1:length(risephase10_90_y)/10,risephase10_90_y,1);

            decay_fp = find((decayphase_y - threshold_point.y)<ap_amp*0.9,1,'first');
            decay_lp = find((decayphase_y - threshold_point.y)<ap_amp*0.1,1,'first');
            decayphase10_90_y = decayphase_y(decay_fp:decay_lp);
            decayslop10_90 = polyfit(0.1:0.1:length(decayphase10_90_y)/10,decayphase10_90_y,1);

            % calculate decay time and decay slope

            % define baseline RMP
                    % settime = 400-str2num(obj.setbaseline.String,'Evaluation','restricted')*10;
            settime = 400-str2num(obj.mousebaseline.String,'Evaluation','restricted')*10;
            
             [itmax, itlocs]=max(diff(smooth(y(1:settime),3)));

            baseline_d = y(itlocs);
            
            if isempty(obj.rmline)
                obj.rmline = yline(obj.ax_AP,y(itlocs),'-.b','LineWidth',1);
            else
                obj.rmline.Value = y(itlocs);
            end

            % define AHP
            rhalf_y = obj.ap_y(apLoc:(apLoc+1000));
            AHP_M = min(rhalf_y);


            %Draw AP50 line
            APD = ap_amp/2 + threshold_point.y;

            in_APD = [APD, 1];
            if 1==length(in_APD)
                disp(APD)
            end
            [a, b] = obj.find_line(line_L, in_APD);
            point_L.y = APD;
            point_L.x = ((APD - b)/a+300)/10;
            in_APD(2) = 2;
            [a, b] = obj.find_line(line_R, in_APD);
            point_R.y = APD;
            point_R.x = ((APD - b)/a + 400)/10;
            if isempty(obj.line_APD50)
                obj.line_APD50 = line(obj.ax_AP,'XData', [point_L.x, point_R.x], 'YData',[point_L.y, point_R.y], 'LineWidth', 1.5, 'Color','red');
            else
                obj.line_APD50.XData = [point_L.x, point_R.x];
                obj.line_APD50.YData = [point_L.y, point_R.y];
            end

            hold(obj.ax_AP,'off');

            %plot AP in overlap ax
            hold(obj.ax_overlap, 'on');
            offset_x = threshold_point.x - obj.base_point.x;
            offset_y = threshold_point.y - obj.base_point.y;
            merge.x = x - offset_x;
            merge.y = y - offset_y  ;

            plot(obj.ax_overlap, merge.x, merge.y,'-','LineWidth',1,'Color',[0.7 0.7 0.7]);
            if isempty(obj.apMerge_y)
                obj.apMerge_y = merge.y;
            else
                obj.apMerge_y = mean(cat(1,obj.apMerge_y, merge.y), 1);
                if isempty(obj.AP_merge)
                    obj.AP_merge = line(obj.ax_overlap,'XData',merge.x, 'YData', obj.apMerge_y, 'Color','red','LineWidth',1.5);
                else
                    obj.AP_merge.YData = obj.apMerge_y;
                end
                uistack(obj.AP_merge,'top');
            end

            % plot phase slope
            hold(obj.ax_phase,'on');
            phase_y = y(uint16(offset_x*10 + 20):uint16(500 + offset_x*10)) - offset_y;
            phaseplot_x = phase_y(1:end-1);
            phaseplot_y = diff(phase_y)*10;
            plot(obj.ax_phase, phaseplot_x, phaseplot_y,'-','LineWidth',1,'Color',[0.7 0.7 0.7]);
            if isempty(obj.pl_m_y)
                obj.pl_m_y = phaseplot_y;
                obj.pl_m_x = phaseplot_x;
                obj.phase_merge = line(obj.ax_phase,'XData', phaseplot_x, 'YData', obj.pl_m_y, 'Color', 'blue', 'LineWidth', 1.5);
            else
                obj.pl_m_y = mean(cat(1,obj.pl_m_y, phaseplot_y),1);
                obj.pl_m_x = mean(cat(1,obj.pl_m_x, phaseplot_x),1);
                obj.phase_merge.XData = obj.pl_m_x;
                obj.phase_merge.YData = obj.pl_m_y;
            end
            uistack(obj.phase_merge,'top');
            hold(obj.ax_overlap, 'off');
            % calculate AP result
            obj.data_Amplitude = ap_amp;
            obj.data_APD50 = point_R.x - point_L.x;
            % obj.data_AHP = threshold_point.y - AHP_M;
            % data_baselineAHP = baseline_d - AHP_M;
            obj.data_RMP = baseline_d;
            % calculare result table
            formatSpec = '%.2f';
            dataarray = [obj.data_RMP, threshold_point.y, obj.data_Amplitude, obj.data_APD50, AHP_M, risetime,decaytime, riseslop, decayslop, riseslop10_90(1),  decayslop10_90(1)];
            Data_t = obj.gettablecell(dataarray);
           if anaNo==1
               obj.tablearray = dataarray;
               obj.tableData = [Data_t;cell(1,11);Data_t];
                obj.table_row = [];
                obj.data_table.Data = obj.tableData;
                obj.table_row(1) = 1;
                obj.data_table.RowName = {'Mean','SE',obj.table_row};

           else
                obj.tablearray = cat(1,obj.tablearray,dataarray);
                obj.tableData = [obj.tableData;Data_t];
                meandata = obj.gettablecell(mean(obj.tablearray));
                stddata = obj.gettablecell(std(obj.tablearray)/sqrt(anaNo));
                obj.tableData(1,:) = meandata;
                obj.tableData(2,:) = stddata;
                obj.data_table.Data = obj.tableData;
                obj.table_row(anaNo) = anaNo;
                obj.data_table.RowName = {'Mean','SE',obj.table_row};
            end

        end
        function data = gettablecell(obj, dataarray,~)
            formatSpec = '%.2f';
            for i = 1:11
                data{i} = num2str(dataarray(i),formatSpec);

            end
        end
        function runoneback(obj,~,~)  % for mouse Neuron runone analyze Ap

            if obj.locs(1)<400
                anaNo = 2;
                obj.AP_count.String = num2str(2);
            elseif 0==obj.AP_count.Value
                anaNo = 1;
            else
                anaNo = obj.AP_count.Value - 1;
                obj.AP_count.Value = anaNo;
                if anaNo>length(obj.locs)|anaNo==0
                    warndlg('AP analysis is done','Warning');
                    return;
                end

            end
            peak_no = length(obj.locs);
            if anaNo>peak_no
                warndlg('AP analysis is done','Warning');
                return;
            end

            apLoc = obj.locs(anaNo);
            y = obj.ap_y((apLoc-400):(apLoc+300));

            x = 0.1:0.1:(length(y)/10);
            if isempty(obj.line_ap)
                obj.line_ap = line(obj.ax_AP,'XData', x, 'YData', y, 'LineWidth', 1.5);
            else
                obj.line_ap.XData = x;
                obj.line_ap.YData = y;
            end
            obj.ax_AP.Box = 'off';
            obj.ax_AP.XLabel.String = 'Time (ms)';
            obj.ax_AP.YLabel.String = 'Membrane Potential (mV)';
            hold(obj.ax_trace,'on');
            %show peak point

            if isempty(obj.trace_AP_mark)
                obj.trace_AP_mark = drawpoint(obj.ax_trace, Position=[obj.locs(anaNo)/10000, obj.pks(anaNo)]);
            else
                obj.trace_AP_mark.Position = [obj.locs(anaNo)/10000, obj.pks(anaNo)];
            end
            hold(obj.ax_trace,'off');
            obj.ap_single_y = obj.ap_y((apLoc-100):apLoc);
            line_L = obj.ap_single_y;
            line_R = obj.ap_y(apLoc:(apLoc +100));
            obj.ap_baseline_y = y(1:400);
            hold(obj.ax_AP,'on');
            % find and show threshold point.
            data_threshold_locs = find(diff(obj.ap_single_y)>0.6,1,"first")-2; % to find threshold location.
            if isempty(obj.base_point)
                obj.base_point.x = (data_threshold_locs + 300)/10;
                obj.base_point.y = obj.ap_single_y(data_threshold_locs);
                threshold_point.x = (data_threshold_locs+300)/10;
                threshold_point.y = obj.ap_single_y(data_threshold_locs);
                obj.threshpoint = drawpoint(obj.ax_AP,Position=[threshold_point.x, threshold_point.y], Color='green');

            else
                threshold_point.x = (data_threshold_locs+300)/10;
                threshold_point.y = obj.ap_single_y(data_threshold_locs);
                obj.threshpoint.Position = [threshold_point.x, threshold_point.y];
            end
            % calculate rise time and rise slope
           risephase_y = line_L(data_threshold_locs:100);
            riseslop = max(diff(risephase_y))*10;
            risetime = length(risephase_y)/10;

             % calculate decay time and decay slope
            decaythresh_plocs = find(line_R<threshold_point.y, 1);
            decayphase_y = line_R(1:decaythresh_plocs);
            decayslop = min(diff(decayphase_y))*10;
            decaytime = length(decayphase_y)/10;

            % define AP amplitude between threshold and peak
            ap_amp = obj.pks(anaNo) - threshold_point.y;
            %% calculate 10-90% slope
            rise_fp = find((risephase_y - threshold_point.y)>ap_amp*0.1,1,"first");
            rise_lp = find((risephase_y - threshold_point.y)>ap_amp*0.9,1,"first");
            risephase10_90_y = risephase_y(rise_fp:rise_lp);
            riseslop10_90 = polyfit(0.1:0.1:length(risephase10_90_y)/10,risephase10_90_y,1);

            decay_fp = find((decayphase_y - threshold_point.y)<ap_amp*0.9,1,'first');
            decay_lp = find((decayphase_y - threshold_point.y)<ap_amp*0.1,1,'first');
            decayphase10_90_y = decayphase_y(decay_fp:decay_lp);
            decayslop10_90 = polyfit(0.1:0.1:length(decayphase10_90_y)/10,decayphase10_90_y,1);

           

            % define baseline RMP
                    % settime = 400-str2num(obj.setbaseline.String,'Evaluation','restricted')*10;
            settime = 400-str2num(obj.mousebaseline.String,'Evaluation','restricted')*10;
            
             [itmax, itlocs]=max(diff(y(1:settime)));
            baseline_d = y(itlocs);
            
           

            if isempty(obj.rmline)
                obj.rmline = yline(obj.ax_AP,y(itlocs),'-.b','LineWidth',1);
            else
                obj.rmline.Value = y(itlocs);
            end

            % define AHP
            rhalf_y = obj.ap_y(apLoc:(apLoc+1000));
            AHP_M = min(rhalf_y);


            %Draw AP50 line
            APD = ap_amp/2 + threshold_point.y;

            in_APD = [APD, 1];
            if 1==length(in_APD)
                disp(APD)
            end
            [a, b] = obj.find_line(line_L, in_APD);
            point_L.y = APD;
            point_L.x = ((APD - b)/a+300)/10;
            in_APD(2) = 2;
            [a, b] = obj.find_line(line_R, in_APD);
            point_R.y = APD;
            point_R.x = ((APD - b)/a + 400)/10;
            if isempty(obj.line_APD50)
                obj.line_APD50 = line(obj.ax_AP,'XData', [point_L.x, point_R.x], 'YData',[point_L.y, point_R.y], 'LineWidth', 1.5, 'Color','red');
            else
                obj.line_APD50.XData = [point_L.x, point_R.x];
                obj.line_APD50.YData = [point_L.y, point_R.y];
            end

            hold(obj.ax_AP,'off');

            %plot AP in overlap ax
            hold(obj.ax_overlap, 'on');
            offset_x = threshold_point.x - obj.base_point.x;
            offset_y = threshold_point.y - obj.base_point.y;
            merge.x = x - offset_x;
            merge.y = y - offset_y  ;

            plot(obj.ax_overlap, merge.x, merge.y,'-','LineWidth',1,'Color',[0.7 0.7 0.7]);
            if isempty(obj.apMerge_y)
                obj.apMerge_y = merge.y;
            else
                obj.apMerge_y = mean(cat(1,obj.apMerge_y, merge.y), 1);
                if isempty(obj.AP_merge)
                    obj.AP_merge = line(obj.ax_overlap,'XData',merge.x, 'YData', obj.apMerge_y, 'Color','red','LineWidth',1.5);
                else
                    obj.AP_merge.YData = obj.apMerge_y;
                end
                uistack(obj.AP_merge,'top');
            end

            % plot phase slope
            hold(obj.ax_phase,'on');
            phase_y = y(uint16(offset_x*10 + 20):uint16(500 + offset_x*10)) - offset_y;
            phaseplot_x = phase_y(1:end-1);
            phaseplot_y = diff(phase_y)*10;
            plot(obj.ax_phase, phaseplot_x, phaseplot_y,'-','LineWidth',1,'Color',[0.7 0.7 0.7]);
            if isempty(obj.pl_m_y)
                obj.pl_m_y = phaseplot_y;
                obj.pl_m_x = phaseplot_x;
                obj.phase_merge = line(obj.ax_phase,'XData', phaseplot_x, 'YData', obj.pl_m_y, 'Color', 'blue', 'LineWidth', 1.5);
            else
                obj.pl_m_y = mean(cat(1,obj.pl_m_y, phaseplot_y),1);
                obj.pl_m_x = mean(cat(1,obj.pl_m_x, phaseplot_x),1);
                obj.phase_merge.XData = obj.pl_m_x;
                obj.phase_merge.YData = obj.pl_m_y;
            end
            uistack(obj.phase_merge,'top');

            hold(obj.ax_overlap, 'off');
            % calculate AP result
            obj.data_Amplitude = ap_amp;
            obj.data_APD50 = point_R.x - point_L.x;
            % obj.data_AHP = threshold_point.y - AHP_M;
            % data_baselineAHP = baseline_d - AHP_M;
            obj.data_RMP = baseline_d;
            % calculare result table
            formatSpec = '%.2f';
            dataarray = [obj.data_RMP, threshold_point.y, obj.data_Amplitude, obj.data_APD50, AHP_M, risetime,decaytime, riseslop, decayslop, riseslop10_90(1),  decayslop10_90(1)];
            Data_t = obj.gettablecell(dataarray);
           if anaNo==1
               obj.tablearray = dataarray;
               obj.tableData = [Data_t;cell(1,12);Data_t];
                obj.table_row = [];
                obj.data_table.Data = obj.tableData;
                obj.table_row(1) = 1;
                obj.data_table.RowName = {'Mean','SE',obj.table_row};

           else
                obj.tablearray = obj.tablearray(1:anaNo,:)
                obj.tableData = obj.tableData(1:anaNo+2,:)
                meandata = obj.gettablecell(mean(obj.tablearray));
                stddata = obj.gettablecell(std(obj.tablearray)/sqrt(anaNo));
                obj.tableData(1,:) = meandata;
                obj.tableData(2,:) = stddata;
                obj.data_table.Data = obj.tableData;
                obj.table_row(anaNo+1) = [];
                obj.data_table.RowName = {'Mean','SE',obj.table_row};
            end


        end
        %%  run for BWM action potential analysis
        function runonebwmforward(obj, ~, ~)  % for C.elegans BWM runone analyze A

            if 0==str2num(obj.AP_count.String) & obj.locs(1)>100
                anaNo = 1;
                ppmsval=0;
                cla(obj.ax_overlap);
                obj.AP_merge = []; 
                cla(obj.ax_phase);

                obj.pl_m_y = [];
            elseif obj.locs(1)<100
                anaNo = 2;    
                ppmsval = obj.PPms(anaNo-1);
                % obj.AP_merge.YData = [];
                % obj.phase_merge.YData = [];
            else
                anaNo = str2num(obj.AP_count.String) + 1; 
                if anaNo>length(obj.locs)
                    warndlg('AP analysis is done','Warning');
                    return;
                end  
                ppmsval = obj.PPms(anaNo-1);
            end
            
            obj.AP_count.String = num2str(anaNo);

            apLoc = uint32(10*obj.locs(anaNo));
            y = obj.ap_y((apLoc-1000):(apLoc+1000));
            x = 0.1:0.1:(length(y)/10);
            if isempty(obj.line_ap)
                obj.line_ap = line(obj.ax_AP,'XData', x, 'YData', y, 'LineWidth', 1.5);
            else
                obj.line_ap.XData = x;
                obj.line_ap.YData = y;
            end
            hold(obj.ax_trace,'on');
            if isempty(obj.trace_AP_mark)
                obj.trace_AP_mark = drawpoint(obj.ax_trace, Position=[obj.locs(anaNo)/1000, obj.pks(anaNo)]);
            else
                obj.trace_AP_mark.Position = [obj.locs(anaNo)/1000, obj.pks(anaNo)];
            end
            hold(obj.ax_trace,'off');

            obj.ap_single_y = obj.ap_y((apLoc-1000):apLoc);
            line_L = obj.ap_single_y;
            line_R = obj.ap_y(apLoc:(apLoc +1000));
            obj.ap_baseline_y = y(1:1000);%

            bmw_threshold_set = 100 - str2num(obj.bmw_threshold.String);
            hold(obj.ax_AP,'on');
            % find and show threshold point.
            if isempty(obj.threshpoint)
                threshold_point.x = bmw_threshold_set;
                threshold_point.y = obj.ap_single_y(bmw_threshold_set*10);
                obj.threshpoint = drawpoint(obj.ax_AP,Position=[threshold_point.x, threshold_point.y], Color='green');
            else
                threshold_point.x = bmw_threshold_set;
                threshold_point.y = obj.ap_single_y(bmw_threshold_set*10);
                obj.threshpoint.Position = [threshold_point.x, threshold_point.y];
            end
            % calculate rise time and rise slope
            risephase_y = line_L(700:1000);
            riseslop = max(diff(risephase_y))*10;
            risetime = length(risephase_y)/10;

             % calculate decay time and decay slope
            decayphase_y = line_R(1:300);
            decayslop = min(diff(decayphase_y))*10;
            decaytime = length(decayphase_y)/10;

            % define AP amplitude between threshold and peak
            ap_amp = obj.pks(anaNo) - threshold_point.y;
            %% calculate 10-90% slope
            rise_fp = find((risephase_y - threshold_point.y)>ap_amp*0.1,1,"first");
            rise_lp = find((risephase_y - threshold_point.y)>ap_amp*0.9,1,"first");
            risephase10_90_y = risephase_y(rise_fp:rise_lp);
            riseslop10_90 = polyfit(0.1:0.1:length(risephase10_90_y)/10,risephase10_90_y,1);

            decay_fp = find((decayphase_y - threshold_point.y)<ap_amp*0.9,1,'first');
            decay_lp = find((decayphase_y - threshold_point.y)<ap_amp*0.1,1,'first');
            decayphase10_90_y = decayphase_y(decay_fp:decay_lp);
            decayslop10_90 = polyfit(0.1:0.1:length(decayphase10_90_y)/10,decayphase10_90_y,1);

           

            % % define baseline
            % settime = 400-str2num(obj.setbaseline.String,'Evaluation','restricted')*10;
            % baseline_d = y(settime);
            % if isempty(obj.rmline)
            %     obj.rmline = yline(obj.ax_AP,y(settime),'-.b','LineWidth',1);
            % else
            %     obj.rmline.Value = y(settime);
            % end

             % define the RMP or baseline
            % obj.data_RMP = threshold_point.y;

            baseline_beginpoint = str2num(obj.bwmbaseline.String)*10;
            [bwmitsmin, bwmitslocs] = min(abs(diff(y(1:baseline_beginpoint))));
            itsy = y(bwmitslocs);
            if isempty(obj.bwmrmpline)
                obj.bwmrmpline = yline(obj.ax_AP,itsy,'-.b','LineWidth',1);
            else
                obj.bwmrmpline.Value = itsy;
            end
            obj.data_RMP = itsy;

            % define AHP
            rhalf_y = obj.ap_y(apLoc:(apLoc+1200));
            AHP_M = min(rhalf_y);


            %Draw AP50 line
            APD = ap_amp/2 + threshold_point.y;

            in_APD = [APD, 1];
            if 1==length(in_APD)
                disp(APD)
            end
            [a, b] = obj.find_line(line_L, in_APD);
            point_L.y = APD;
            point_L.x = ((APD - b)/a)/10;
            in_APD(2) = 2;
            [a, b] = obj.find_line(line_R, in_APD);
            point_R.y = APD;
            point_R.x = ((APD - b)/a+1000)/10;
            if isempty(obj.line_APD50)
                obj.line_APD50 = line(obj.ax_AP,'XData', [point_L.x, point_R.x], 'YData',[point_L.y, point_R.y], 'LineWidth', 1.5, 'Color','red');
            else
                obj.line_APD50.XData = [point_L.x, point_R.x];
                obj.line_APD50.YData = [point_L.y, point_R.y];
            end

            hold(obj.ax_AP,'off');

            %plot AP in overlap ax
            hold(obj.ax_overlap, 'on');
            %offset_x = threshold_point.x - obj.base_point.x;
            if anaNo==1
                merge.y =y;
            else
                merge.y = y-(obj.ap_y(anaNo) - obj.ap_y(anaNo-1));
            end
            merge.x = x;
            plot(obj.ax_overlap, merge.x, merge.y,'-','LineWidth',1,'Color',[0.7 0.7 0.7]);
            if isempty(obj.apMerge_y)
                obj.apMerge_y = merge.y;
            else
                obj.apMerge_y = mean(cat(1,obj.apMerge_y, merge.y), 1);
                if isempty(obj.AP_merge)
                    obj.AP_merge = line(obj.ax_overlap,'XData',merge.x, 'YData', obj.apMerge_y, 'Color','red','LineWidth',1.5);
                else
                    obj.AP_merge.YData = obj.apMerge_y;
                end
                uistack(obj.AP_merge,'top');
            end

            % plot phase slope
            hold(obj.ax_phase,'on');
            % phase_y = y(uint16(offset_x*10 + 20):uint16(500 + offset_x*10)) - offset_y;
            phase_y = y;
           phaseplot_x = phase_y(1:end-1);

            phaseplot_y = diff(phase_y)*10;
            plot(obj.ax_phase, phaseplot_x, phaseplot_y,'-','LineWidth',1,'Color',[0.7 0.7 0.7]);
            if isempty(obj.pl_m_y)
                obj.pl_m_y = phaseplot_y;
                obj.pl_m_x = phaseplot_x;
                obj.phase_merge = line(obj.ax_phase,'XData', phaseplot_x, 'YData', smooth(obj.pl_m_y,3), 'Color', 'blue', 'LineWidth', 1.5);
            else
                obj.pl_m_y = mean(cat(1,obj.pl_m_y, phaseplot_y),1);
                obj.pl_m_x = mean(cat(1,obj.pl_m_x, phaseplot_x),1);
                obj.phase_merge.XData = obj.pl_m_x;
                obj.phase_merge.YData = smooth(obj.pl_m_y, 3);
            end
            uistack(obj.phase_merge,'top');

            hold(obj.ax_overlap, 'off');
            % calculate AP result
            obj.data_Amplitude = ap_amp;
            obj.data_APD50 = point_R.x - point_L.x;
            % obj.data_AHP = threshold_point.y - AHP_M;
            % data_baselineAHP = threshold_point.y - AHP_M;
            % calculare result table
            
           formatSpec = '%.2f';
            dataarray = [obj.data_RMP, threshold_point.y, obj.data_Amplitude, obj.data_APD50, AHP_M, risetime,decaytime, riseslop, decayslop, riseslop10_90(1),  decayslop10_90(1)];
            Data_t = obj.gettablecell(dataarray);
            % obj.tableData = [Data_t;cell(1,12);Data_t];
           if anaNo==1
               obj.tablearray = dataarray;
               obj.tableData = [Data_t;cell(1,12);Data_t];
                obj.table_row = [];
                obj.data_table.Data = obj.tableData;
                obj.table_row(1) = 1;
                obj.data_table.RowName = {'Mean','SE',obj.table_row};

           else
                obj.tablearray = cat(1,obj.tablearray,dataarray);
                obj.tableData = [obj.tableData;Data_t];
                meandata = obj.gettablecell(mean(obj.tablearray));
                stddata = obj.gettablecell(std(obj.tablearray)/sqrt(anaNo));
                obj.tableData(1,:) = meandata;
                obj.tableData(2,:) = stddata;
                obj.data_table.Data = obj.tableData;
                obj.table_row(anaNo) = anaNo;
                obj.data_table.RowName = {'Mean','SE',obj.table_row};
            end


        end
        function runonebwmback(obj, ~, ~)  % for C.elegans BWM runone analyze A

            if 0==str2num(obj.AP_count.String) & obj.locs(1)>100
                anaNo = 1;
                cla(obj.ax_overlap);
                obj.AP_merge = []; 
                cla(obj.ax_phase);
                obj.pl_m_y = [];
            elseif obj.locs(1)<100
                anaNo = 2;    
            else
                anaNo = str2num(obj.AP_count.String) - 1; 
                obj.AP_count.String = num2str(anaNo);
                if anaNo==0
                    
                    warndlg('Please redo again !','Warning');
                    return;
                end  
            end
            
            

            apLoc = uint32(10*obj.locs(anaNo));
            y = obj.ap_y((apLoc-1000):(apLoc+1000));
            x = 0.1:0.1:(length(y)/10);
            if isempty(obj.line_ap)
                obj.line_ap = line(obj.ax_AP,'XData', x, 'YData', y, 'LineWidth', 1.5);
            else
                obj.line_ap.XData = x;
                obj.line_ap.YData = y;
            end
            hold(obj.ax_trace,'on');
            if isempty(obj.trace_AP_mark)
                obj.trace_AP_mark = drawpoint(obj.ax_trace, Position=[obj.locs(anaNo)/1000, obj.pks(anaNo)]);
            else
                obj.trace_AP_mark.Position = [obj.locs(anaNo)/1000, obj.pks(anaNo)];
            end
            hold(obj.ax_trace,'off');

            obj.ap_single_y = obj.ap_y((apLoc-1000):apLoc);
            line_L = obj.ap_single_y;
            line_R = obj.ap_y(apLoc:(apLoc +1000));
            obj.ap_baseline_y = y(1:1000);%

            bmw_threshold_set = 100 - str2num(obj.bmw_threshold.String);
            hold(obj.ax_AP,'on');
            % find and show threshold point.
            if isempty(obj.threshpoint)
                threshold_point.x = bmw_threshold_set;
                threshold_point.y = obj.ap_single_y(bmw_threshold_set*10);
                obj.threshpoint = drawpoint(obj.ax_AP,Position=[threshold_point.x, threshold_point.y], Color='green');
            else
                threshold_point.x = bmw_threshold_set;
                threshold_point.y = obj.ap_single_y(bmw_threshold_set*10);
                obj.threshpoint.Position = [threshold_point.x, threshold_point.y];
            end
            % calculate rise time and rise slope
            risephase_y = line_L(700:1000);
            riseslop = max(diff(risephase_y))*10;
            risetime = length(risephase_y)/10;

             % calculate decay time and decay slope
            decayphase_y = line_R(1:300);
            decayslop = min(diff(decayphase_y))*10;
            decaytime = length(decayphase_y)/10;

            % define AP amplitude between threshold and peak
            ap_amp = obj.pks(anaNo) - threshold_point.y;
            %% calculate 10-90% slope
            rise_fp = find((risephase_y - threshold_point.y)>ap_amp*0.1,1,"first");
            rise_lp = find((risephase_y - threshold_point.y)>ap_amp*0.9,1,"first");
            risephase10_90_y = risephase_y(rise_fp:rise_lp);
            riseslop10_90 = polyfit(0.1:0.1:length(risephase10_90_y)/10,risephase10_90_y,1);

            decay_fp = find((decayphase_y - threshold_point.y)<ap_amp*0.9,1,'first');
            decay_lp = find((decayphase_y - threshold_point.y)<ap_amp*0.1,1,'first');
            decayphase10_90_y = decayphase_y(decay_fp:decay_lp);
            decayslop10_90 = polyfit(0.1:0.1:length(decayphase10_90_y)/10,decayphase10_90_y,1);


            baseline_beginpoint = str2num(obj.bwmbaseline.String)*10;
            [bwmitsmin, bwmitslocs] = min(abs(diff(y(1:baseline_beginpoint))));
            itsy = y(bwmitslocs)
            if isempty(obj.bwmrmpline)
                obj.bwmrmpline = yline(obj.ax_AP,itsy,'-.b','LineWidth',1);
            else
                obj.bwmrmpline.Value = itsy;
            end
            obj.data_RMP = itsy;

            % define AHP
            rhalf_y = obj.ap_y(apLoc:(apLoc+1200));
            AHP_M = min(rhalf_y);


            %Draw AP50 line
            APD = ap_amp/2 + threshold_point.y;

            in_APD = [APD, 1];
            if 1==length(in_APD)
                disp(APD)
            end
            [a, b] = obj.find_line(line_L, in_APD);
            point_L.y = APD;
            point_L.x = ((APD - b)/a)/10;
            in_APD(2) = 2;
            [a, b] = obj.find_line(line_R, in_APD);
            point_R.y = APD;
            point_R.x = ((APD - b)/a+1000)/10;
            if isempty(obj.line_APD50)
                obj.line_APD50 = line(obj.ax_AP,'XData', [point_L.x, point_R.x], 'YData',[point_L.y, point_R.y], 'LineWidth', 1.5, 'Color','red');
            else
                obj.line_APD50.XData = [point_L.x, point_R.x];
                obj.line_APD50.YData = [point_L.y, point_R.y];
            end

            hold(obj.ax_AP,'off');

            %plot AP in overlap ax
            hold(obj.ax_overlap, 'on');
            %offset_x = threshold_point.x - obj.base_point.x;
            if anaNo==1
                merge.y =y;
            else
                merge.y = y-(obj.ap_y(anaNo) - obj.ap_y(anaNo-1));
            end
            merge.x = x;
            plot(obj.ax_overlap, merge.x, merge.y,'-','LineWidth',1,'Color',[0.7 0.7 0.7]);
            if isempty(obj.apMerge_y)
                obj.apMerge_y = merge.y;
            else
                obj.apMerge_y = mean(cat(1,obj.apMerge_y, merge.y), 1);
                if isempty(obj.AP_merge)
                    obj.AP_merge = line(obj.ax_overlap,'XData',merge.x, 'YData', obj.apMerge_y, 'Color','red','LineWidth',1.5);
                else
                    obj.AP_merge.YData = obj.apMerge_y;
                end
                uistack(obj.AP_merge,'top');
            end

            % plot phase slope
            hold(obj.ax_phase,'on');
            % phase_y = y(uint16(offset_x*10 + 20):uint16(500 + offset_x*10)) - offset_y;
            phase_y = y;
           phaseplot_x = phase_y(1:end-1);

            phaseplot_y = diff(phase_y)*10;
            plot(obj.ax_phase, phaseplot_x, phaseplot_y,'-','LineWidth',1,'Color',[0.7 0.7 0.7]);
            if isempty(obj.pl_m_y)
                obj.pl_m_y = phaseplot_y;
                obj.pl_m_x = phaseplot_x;
                obj.phase_merge = line(obj.ax_phase,'XData', phaseplot_x, 'YData', obj.pl_m_y, 'Color', 'blue', 'LineWidth', 1.5);
            else
                obj.pl_m_y = mean(cat(1,obj.pl_m_y, phaseplot_y),1);
                obj.pl_m_x = mean(cat(1,obj.pl_m_x, phaseplot_x),1);
                obj.phase_merge.XData = obj.pl_m_x;
                obj.phase_merge.YData = smooth(obj.pl_m_y,3);
            end
            uistack(obj.phase_merge,'top');

            hold(obj.ax_overlap, 'off');
            % calculate AP result
            obj.data_Amplitude = ap_amp;
            obj.data_APD50 = point_R.x - point_L.x;
            % obj.data_AHP = threshold_point.y - AHP_M;
            % data_baselineAHP = threshold_point.y - AHP_M;
            obj.data_RMP = threshold_point.y;

            % calculare result table

            formatSpec = '%.2f';
            
            dataarray = [obj.data_RMP, threshold_point.y, obj.data_Amplitude, obj.data_APD50, AHP_M, risetime,decaytime, riseslop, decayslop, riseslop10_90(1),  decayslop10_90(1)];
            Data_t = obj.gettablecell(dataarray);
            % obj.tableData = [Data_t;cell(1,12);Data_t];
           if anaNo==1
               obj.tablearray = dataarray;
               obj.tableData = [Data_t;cell(1,12);Data_t];
                obj.table_row = [];
                obj.data_table.Data = obj.tableData;
                obj.table_row(1) = 1;
                obj.data_table.RowName = {'Mean','SE',obj.table_row};

           else
                obj.tablearray = obj.tablearray(1:anaNo,:)
                obj.tableData = obj.tableData(1:anaNo+2,:)
                meandata = obj.gettablecell(mean(obj.tablearray));
                stddata = obj.gettablecell(std(obj.tablearray)/sqrt(anaNo));
                obj.tableData(1,:) = meandata;
                obj.tableData(2,:) = stddata;
                obj.data_table.Data = obj.tableData;
                obj.table_row(anaNo+1) = [];
                obj.data_table.RowName = {'Mean','SE',obj.table_row};
            end



        end
        function [a, b] = find_APD(~, curve, APD)
            i = 1;
            if 1 ==APD(2)
                while true
                    if curve(i)>APD(1)
                        coor_2.y = curve(i);
                        coor_2.x = i;
                        coor_1.y = curve(i-1);
                        coor_1.x = i-1;
                        break;
                    end
                    i = i+1;
                end
                a = coor_2.y - coor_1.y;% slope
                b = coor_2.y - a*coor_2.x; % line formula b
            else
                while true
                    if curve(i)<APD(1)
                        coor_2.y = curve(i);
                        coor_2.x = i;
                        coor_1.y = curve(i-1);
                        coor_1.x = i-1;
                        break;
                    end
                    i = i+1;
                end
                a = coor_2.y - coor_1.y;
                b = coor_2.y - a*coor_2.x;
            end

        end
        function [a,b] = find_line(~,curve,APD)
            %% to find AP50 and then draw line
            i = 1;
            if 1 ==APD(2)
                while true
                    if curve(i)>APD(1)
                        coor_2.y = curve(i);
                        coor_2.x = i;
                        coor_1.y = curve(i-1);
                        coor_1.x = i-1;
                        break;
                    end
                    i = i+1;
                end
                a = coor_2.y - coor_1.y; %slope
                b = coor_2.y - a*coor_2.x; % b value of line
            else
                while true
                    if curve(i)<APD(1)
                        coor_2.y = curve(i);
                        coor_2.x = i;
                        coor_1.y = curve(i-1);
                        coor_1.x = i-1;
                        break;
                    end
                    i = i+1;
                end
                a = coor_2.y - coor_1.y;
                b = coor_2.y - a*coor_2.x;
            end

        end
        function pasteData(obj,~,~)
            % toreset(obj);
            if obj.neuron_box.Value ==1
                obj.neuron_checkbox;
            end
            if obj.neuron_box.Value==0 && obj.bmw_box.Value==0
                warndlg('Plese select AP type', 'AP type option');
                return;
            end
            cla(obj.ax_trace);

            cla(obj.ax_overlap);
            obj.AP_merge = [];
            cla(obj.ax_phase);
            obj.pl_m_y = [];
            obj.trace_AP_mark =[];
            obj.AP_count.Value = 0;


            obj.ppvalue = 0;
            obj.ap_y  = transpose(str2num(clipboard('paste'),Evaluation="restricted"));
            data_length = length(obj.ap_y)-1 ;
            obj.ap_x = 0:0.0001:(data_length/10000);
            min_y = 10*floor(min(obj.ap_y)/10);
            max_y = 10*ceil(max(obj.ap_y)/10)+10;
            plot(obj.ax_trace, obj.ap_x, obj.ap_y);
            obj.ax_trace.YLim =[min_y,max_y];
            obj.ax_trace.XLim =[0,data_length/10000];
            obj.ax_trace.XTick = 0:1:ceil(data_length/10000);
            obj.ax_trace.TickDir = 'out';
            obj.ax_trace.TickLength = [0.002 0.025];
            obj.ax_trace.YLabel.String ='Membrane Potential (mV)';
            obj.ax_trace.XLabel.String = 'Time (s)';
            obj.ax_trace.Box = 'off';
            [obj.pks,obj.locs] = findpeaks(obj.ap_y, 'MinPeakHeight',10);
            %[obj.pks,obj.locs] = findpeaks(obj.ap_y, obj.ap_x, 'MinPeakHeight',obj.minipeak);
            hold(obj.ax_trace,"on");
 
            %itlength = length(obj.pks)
            obj.PPms = diff(obj.locs);
            obj.apfreq.Value = length(obj.pks)/(data_length/(10*1000));

        end
         function pasteDataBWM(obj,~,~)
             if obj.bmw_box.Value ==1
                 obj.bwm_checkbox;
             end
            if obj.neuron_box.Value==0 && obj.bmw_box.Value==0
                warndlg('Plese select AP type', 'AP type option');
                return;
            end
            obj.ppvalue = 0;
            obj.ap_y  = transpose(str2num(clipboard('paste'),Evaluation="restricted"));
            data_length = length(obj.ap_y)-1 ;
            obj.ap_x = 0:0.0001:(data_length/10000);
            min_y = 10*floor(min(obj.ap_y)/10);
            max_y = 10*ceil(max(obj.ap_y)/10)+10;
            plot(obj.ax_trace, obj.ap_x, obj.ap_y);
            obj.ax_trace.YLim =[min_y,max_y];
            obj.ax_trace.XLim = [0 data_length/10000];
            obj.ax_trace.XTick = 0:1:data_length/10000;
            obj.ax_trace.TickDir = 'out';
            obj.ax_trace.TickLength = [0.002 0.025];
            obj.ax_trace.YLabel.String ='Membrane Potential (mV)';
            %obj.ax_trace.XLabel.String = 'Time (ms)';
            obj.ax_trace.Box = 'off';
            [obj.pks,locs] = findpeaks(obj.ap_y, 'MinPeakHeight',10,'MinPeakDistance',800);
            hold(obj.ax_trace,"on");
            obj.locs = locs/10;
            %itlength = length(obj.locs)
            obj.PPms = diff(obj.locs);
            itsfreq = length(obj.pks)/(data_length/(10*1000));
            obj.apfreq.Value = itsfreq;
            %obj.apfreq.String = num2str(length(obj.pks)/(data_length/(10*1000)));

        end
        function neuron_checkbox(obj,~,~)
                toreset(obj);
                obj.minipeak = 30;
                obj.neuron_gap = 1200;
                obj.ax_AP.XLim = [0 70];
                obj.ax_AP.YLim = [-70 70];
                obj.ax_AP.XTick = 0:10:70;
                obj.ax_AP.YTick = -70:20:70;
                obj.ax_phase.YTick = -120:40:300;
                obj.ax_phase.YLim = [-120 300];
                obj.ax_phase.XLim = [-80 80];
                obj.ax_phase.XTick = -80:20:80;
                obj.ax_overlap.YLim = [-70 70];
                obj.ax_overlap.XLim = [0 70];
                obj.ax_overlap.XTick = 0:10:70;
                obj.ax_overlap.YTick = -70:20:70;
                obj.runoneAP.ButtonPushedFcn = @obj.runone;
                obj.anaBtn.ButtonPushedFcn = @obj.runAna;
                obj.pasteBtn.Callback = @obj.pasteData;
                obj.runonebackbtn.ButtonPushedFcn = @obj.runoneback;
                obj.rmline = [];
                obj.bmw_box.Value = 0;
        end
        function bwm_checkbox(obj,~,~)
            toreset(obj);
                obj.minipeak = 30;
                obj.bmw_gap = 400;
                obj.ax_AP.XLim = [0 200];
                obj.ax_AP.YLim = [-40 40];
                obj.ax_AP.XTick = 0:20:200;
                obj.ax_AP.YTick = -40:10:40;
                obj.runoneAP.Callback = @obj.runonebwmforward;
                obj.runonebackbtn.Callback = @obj.runonebwmback;
                obj.bwmrmpline = [];


                obj.anaBtn.Callback = @obj.runAnaBWM;
                obj.pasteBtn.Callback = @obj.pasteDataBWM;

                obj.ax_overlap.XLim = [0 200];
                obj.ax_overlap.YLim = [-40 40];
                obj.ax_overlap.XTick = 0:40:200;
                obj.ax_overlap.YTick = -40:10:40;

                obj.ax_phase.XLim = [-40 40];
                obj.ax_phase.YLim = [-20 20];
                obj.ax_phase.XTick = -40:10:40;
                obj.ax_phase.YTick = -20:5:20;
                obj.data_table.Data = [];
                obj.data_table.RowName ={'Mean','SE'};
                obj.neuron_box.Value =0;
        end
       
        function exportdata(obj,~,~)
            phasedata = cat(1,obj.pl_m_x,obj.pl_m_y).';
            apdata = cat(1,obj.AP_merge.XData, obj.AP_merge.YData).';
            colname = {'MP(mV)','slope(mV/ms)','Time(ms)', 'MP(mV)'};
            trow = num2str(size(obj.data_table.Data,1)+2);
            apno = size(obj.data_table.Data, 1);
            apnono = transpose(1:(apno-2));
            % winopen data.xlsx;
            try
                ExcelApp = actxGetRunningServer('Excel.Application');
            catch iserror
                colheader = {['AP#'],['RMP (mV)'], ['Threshold (mV)'], ['Amp (mV)'], ['APD50 (ms)'],['AHP (mV)'],['Rise time (ms)'],['Decay time (ms)'],['Rise slope (mV/ms)'],['Decay slope (mV/ms)'], ['RiseSlope(10-90%)(mV/ms)'], ['DecaySlope(10-90%)(mV/ms)'],[''],['Membrane Potential (mV)'],['Slope (mV/ms)'],[''],['Time (ms)'], ['Membrane Potential (mV)']};
                writecell(colheader,'data.xlsx','Sheet',1,'Range','B1');
                writecell(obj.data_table.Data(1:2,:),'data.xlsx','Sheet',1,'Range','C2');
                writecell(obj.data_table.Data(3:end,:),'data.xlsx','Sheet',1,'Range','C5');
                writematrix(round(phasedata,2),'data.xlsx','Sheet',1,'Range','O2');
                writematrix(round(apdata,2),'data.xlsx','Sheet',1,'Range','R2');
                writecell({['mean'];['SE']},'data.xlsx','Sheet',1,'Range','A2');
                writematrix(apnono,'data.xlsx','Sheet',1,'Range','B5');
                winopen data.xlsx;
                return;
            end
            ActiveWorkbook = ExcelApp.ActiveWorkbook;
            ActiveSheet = ExcelApp.ActiveSheet;
            
            ActiveSheet.Range('A2:A3').Value = {['mean'];['SE']};
            ActiveSheet.Range(['B5:B',num2str(apno+2)]).Value = apnono;
            ActiveSheet.Range('B1:T1').Value={['AP#'],['RMP (mV)'], ['Threshold (mV)'], ['Amp (mV)'], ['APD50 (ms)'],['AHP (mV)'],['Rise time (ms)'],['Decay time (ms)'],['Rise slope (mV/ms)'],['Decay slope (mV/ms)'], ['RiseSlope(10-90%)(mV/ms)'], ['DecaySlope(10-90%)(mV/ms)'],[''],['Membrane Potential (mV)'],['Slope (mV/ms)'],[''],['Time (ms)'], ['Membrane Potential (mV)']};
            ActiveSheet.Range(['C2:M3']).Value= obj.data_table.Data(1:2,:);
            ActiveSheet.Range(['C5:M',trow]).Value= obj.data_table.Data(3:end,:);
            ActiveSheet.Range(['O2:P',num2str(size(phasedata,1))]).Value= round(phasedata,2);
            ActiveSheet.Range(['R2:S',num2str(size(apdata,1))]).Value= round(apdata,2);
        end

        function toreset(obj, ~, ~)
                cla(obj.ax_AP);
                cla(obj.ax_trace);
                cla(obj.ax_overlap);
                obj.AP_merge = [];
                cla(obj.ax_phase);
                obj.pl_m_y = [];
                obj.trace_AP_mark =[];
                obj.AP_count.Value = 0;
                obj.line_ap = [];
                obj.threshpoint = [];
                obj.line_APD50 = [];
                obj.apfreq.Value = 0;
                obj.apMerge_y = [];
                obj.data_table.Data = [];
        end


    end
end