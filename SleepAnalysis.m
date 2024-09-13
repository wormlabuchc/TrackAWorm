classdef SleepAnalysis < handle
    properties (Access = public)
        Value {mustBeNumeric}
        gui  %camera videoinput handle
        ax1       %axes handle
        ax2
        ax3
        ax4
        img_show1
        imshow2
        imshow3
        imshow4
        filepath_h
        filepath_edit
        beginimg
        currentimg
        image
        background
        h_plot
        pointhandle = struct;
        speed
        itsrun = true;

        calibration
        chamberID
        load_h
        mask_h
        mask
        coef
        rect_handle
        rect_crop
        rect =struct;
        circle =struct;
        mcircle = struct;
        chamber = struct;
        circle_checkbox

        rect_checkbox
        pointPosition
        speed_vector = zeros(1,1440);
        h_speed
        %analysis button
        fastbtn
        backfastbtn
        %browse image sequence
        right_toggle
        back_toggle
        backBtn
        dataTable
        dataname
        uitablecolname = {};
    end
    methods

        function obj = SleepAnalysis         % it is a constructor funciton
            load('setting.mat','chamber')
            obj.gui = uifigure('Name','SleepApp','Position',[10 50 1200 760],'NumberTitle','off','Resize','on');
            setlayout = uigridlayout(obj.gui);
            setlayout.RowHeight = {'1x','1x'};
            setlayout.ColumnWidth = {330,'2x','1x','1x'};
            % create axes in figure obj.gui

            obj.ax1 = uiaxes(setlayout,'Position',[420 440 660 450],'XTick',[], 'YTick',[],'Box','on','XLim',[0 720],'YLim',[0 540]);
            obj.ax1.Toolbar.Visible = 'off'; 
            obj.ax1.Layout.Row = 1;
            obj.ax1.Layout.Column = 2;
            setpanel = uipanel(setlayout,'BorderType','line');
            setpanel.Layout.Row = [1 2];
            setpanel.Layout.Column = 1;
           
            
            %uicontextmenu for ax2

            obj.ax2 = uiaxes(setlayout,'Position',[380 20 900 380],'XLim',[0 4],'XTick',0:1:4, 'YTick',0:50:300,'Box','on')
            obj.ax2.YLabel.String = 'Speed (µm/10s)';
            obj.ax2.XLabel.String = 'Time (hours)';
            obj.ax2.YLim = [-5 300];
            obj.ax2.Toolbar.Visible = 'off';
            obj.ax2.Layout.Row = 2;
            obj.ax2.Layout.Column = [2 3];



            obj.ax4 = uiaxes(setlayout,'Position',[1100 455 420 420],'XTick',[], 'YTick',[],'Box','on');
            obj.ax4.Toolbar.Visible = 'off';
            obj.ax4.Layout.Row = 1;
            obj.ax4.Layout.Column = [3 4];
            uicontrol(setpanel,'Style', 'text', 'Position', [80 680 180 30],'FontName', 'arial','FontSize',12,...
                'FontWeight', 'bold','String', 'Sleep Analyzer','FontSize',18);
            % load image  
            obj.filepath_h = uibutton(setpanel, 'push', 'Position',[50 620 200 25], 'Text','Load  an Image Folder','fontsize',12,'FontWeight','bold','ButtonPushedFcn', @obj.filepath);
            obj.filepath_edit = uieditfield(setpanel,'text','Position',[65 583 200 25],'FontSize',12);
            %ROI button
            %Direction button
            right_button = imread('icon/right-button.jpg');
            left_button = imread('icon/left-button.jpg');
            up_button = imread('icon/up-button.jpg');
            down_button = imread('icon/down-button.jpg');
            plus_circle = imread('icon/plus-circle.jpg');
            minus_circle = imread('icon/minus-circle.jpg');
            obj.rect.x = 10;
            obj.rect.y = 66;
            obj.rect.side = 232;
            %circle
            obj.circle.x = 114;
            obj.circle.y = 114;
            obj.circle.radius = 106;
            
             %image brower
            
            uilabel(setpanel,"Text",'Locate the Starting Frame of Sleep','Position',[50 550 300 20],'FontSize',14);
            uibtng = uibuttongroup(setpanel,'Position',[65 500 170 35]);
            obj.back_toggle = uibutton(uibtng, 'state', 'Position',[5 5 40 25], 'Text','<<','ValueChangedFcn', @obj.backbrowse_fast,'FontSize',14,...
                'FontWeight', 'bold','FontName', 'arial');
            uibutton(uibtng, 'push', 'Position',[45 5 40 25], 'Text','<','ButtonPushedFcn', @obj.backbrowse,'FontSize',14,...
                'FontWeight', 'bold','FontName', 'arial');
            uibutton(uibtng, 'push', 'Position',[85 5 40 25], 'Text','>','ButtonPushedFcn', @obj.rightbrowse,'FontSize',14,...
                'FontWeight', 'bold','FontName', 'arial');
            obj.right_toggle =uibutton(uibtng,'state', 'Position', [125 5 40 25],'WordWrap','on','FontName', 'arial','FontSize',14,...
                'FontWeight', 'bold','Text', '>>','ValueChangedFcn',@obj.rightbrowse_fast);
            % uibutton(setpanel,'push','Text','Start Frame','Position',[235 540 80 25],'ButtonPushedFcn',@obj.resetimg);
            uilabel(setpanel,"Text",'Current Frame','position',[65 473 120 20]);
            obj.currentimg = uieditfield(setpanel,'numeric','Position',[195 473 40 20],'Value',100,'Editable','off');
         uilabel(setpanel,"Text",'Frame to Start Analysis','position',[65 443 300 20]);
            obj.beginimg = uieditfield(setpanel,'numeric','Position',[195 443 40 20],'FontSize',12,'Value',100,'ValueChangedFcn',@obj.resetimg);

            
           % ROI adjustment button
            uibutton(setpanel, 'push', 'Position',[50 400 200 25], 'Text','Select ROI','fontsize',12,'FontWeight','bold','ButtonPushedFcn', @obj.roi_callback);
            uibtnadjust = uibuttongroup(setpanel,'Position',[65 290 110 92]);
            uibutton(uibtnadjust, 'push', 'Position',[70 33 30 25], 'Text','','Icon',right_button,'fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.rightMove);
            uibutton(uibtnadjust, 'push', 'Position',[5 33 30 25], 'Text','','Icon',left_button,'Fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.leftMove);
            uibutton(uibtnadjust, 'push', 'Position',[37 60 30 25], 'Text','','Icon',up_button,'fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.upMove);
            uibutton(uibtnadjust, 'push', 'Position',[37 5 30 25], 'Text','','Icon',down_button,'Fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.downMove);
            
            % adjustment circle button
            uibutton(setpanel, 'push', 'Position',[50 250 200 25], 'Text','Encircle Chamber','fontsize',12,'FontWeight','bold','ButtonPushedFcn', @obj.circle_mask);
            circleadjust = uibuttongroup(setpanel,'Position',[65 140 160 92]);
            uibutton(circleadjust, 'push', 'Position',[70 33 30 25], 'Text','','Icon',right_button,'fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.circleRightMove);
            uibutton(circleadjust, 'push', 'Position',[5 33 30 25], 'Text','','Icon',left_button,'Fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.circleLeftMove);
            uibutton(circleadjust, 'push', 'Position',[37 60 30 25], 'Text','','Icon',up_button,'fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.circleUpMove);
            uibutton(circleadjust, 'push', 'Position',[37 5 30 25], 'Text','','Icon',down_button,'Fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.circleDownMove);
            uibutton(circleadjust, 'push', 'Position',[120 60 30 25], 'Text','','Icon',plus_circle,'fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.increaseDia);
            uibutton(circleadjust, 'push', 'Position',[120 5 30 25], 'Text','','Icon',minus_circle,'Fontsize',14,'FontWeight','bold','ButtonPushedFcn', @obj.decreaseDia);


            % calibration box
            uilabel(setpanel,"Text",'Chamber Diameter','Position',[240 180 100 40],'FontSize',12,'WordWrap','on');
            obj.chamberID = uieditfield(setpanel,'numeric','Position',[240 155 40 20],'FontSize',12,'Value',chamber.id);
            uilabel(setpanel,"Text",'µm','Position',[282 155 20 20],'FontSize',12);
            uibutton(setpanel, 'push', 'Position',[50 100 150 25], 'Text','Calibrate','fontsize',12,'FontWeight','bold','ButtonPushedFcn', @obj.calapply);
            obj.calibration = uieditfield(setpanel,'numeric','Position',[210 102 40 20],'FontSize',12,'Value',chamber.cali);
            uilabel(setpanel,"Text",'µm/pixel','Position',[255 102 50 25],'FontSize',12);


            
            % analysis buttons

            obj.fastbtn =uibutton(setpanel,'state', 'Position', [50 60 150 25],'WordWrap','on','FontName', 'arial','FontSize',12,...
                'FontWeight', 'bold','Text', 'Analyze','ValueChangedFcn',@obj.fastAna);
            uilabel(setpanel,'Text','Animal ID :','Position',[65 20 100 25]);
            obj.dataname = uieditfield(setpanel,'Position',[134 22 40 20]);

            %Export data to excel
            obj.dataTable = uitable(setlayout,'Units','pixels','Position',[1305 53 210 340],'ColumnName',{'Item1','Item2','Item3','Item4','Item5','Item6'},'ColumnWidth','fit');
            obj.dataTable.Layout.Row =2;
            obj.dataTable.Layout.Column = 4;
            tablecm = uicontextmenu(obj.gui);
            itm = uimenu(tablecm,'Text','Export to Excel','MenuSelectedFcn',@obj.exporttoexcel);
            obj.dataTable.ContextMenu = tablecm;
            %uibutton(obj.gui,'push','Position',[1370 20 100 25],'Text','Export to Excel','ButtonPushedFcn',@obj.exporttoexcel);
            cm = uicontextmenu(obj.gui);
            m1 = uimenu(cm,'Text','Send to Table','MenuSelectedFcn',@obj.sendtotable);
            % m2 = uimenu(cm,'Text','Copy to Clipboard');
            % m3 = uimenu(cm,'Text','Go to Analysis');
            obj.ax2.ContextMenu = cm;
        end
        function filepath(obj,~,~)
            filepath=uigetdir('D:\sleep\');
            % set(obj.imagepath,'String',strcat(filepath,'\'));
            obj.filepath_edit.Value = strcat(filepath,'\');
            obj.image= imread(strcat(get(obj.filepath_edit,'Value'),'worm',num2str(obj.currentimg.Value),'.jpg'));
            img = imresize(obj.image,0.5);
            obj.img_show1 = imshow(img,'Parent',obj.ax1,'Border','tight','InitialMagnification','fit');
        end
        function calapply(obj, ~, ~)
            obj.mcircle.center = obj.mask.Center;
            obj.mcircle.radius = obj.mask.Radius;
            obj.calibration.Value = obj.chamberID.Value/(obj.mcircle.radius*2);
            chamber.id = obj.chamberID.Value;
            chamber.cali = obj.calibration.Value;
            save('setting.mat','chamber');
        end
        function load_file(obj, ~, ~)
        end
        function circle_boxchanged(obj,cbx,~)
            val = cbx.Value;
            if val
                obj.rect_checkbox.Value = 0;
            end
        end
        function rect_boxchanged(obj,cbx,~)
            val = cbx.Value;
            if val
                obj.circle_checkbox.Value = 0;
            end
        end
        function roi_callback(obj,~,~)
            if isempty(obj.rect_handle)
                obj.rect_handle = drawrectangle(obj.ax1, 'Position', [obj.rect.x, obj.rect.y, obj.rect.side, obj.rect.side], 'Color', 'green');
            end
        end
        function mask_img(obj, ~, ~)
            
            obj.rect_crop = imcrop(obj.image,obj.rect_handle.Position);
            if isobject(obj.imshow4)
                set(obj.imshow4, 'CData', obj.rect_crop);
            else
                obj.imshow4 = imshow(obj.rect_crop, 'Parent',obj.ax4);
            end
            if isempty(obj.mask)
                obj.mask = drawcircle(obj.ax4,'Center',[obj.circle.x, obj.circle.y],'Radius',obj.circle.radius,'Color','blue',...
                    'LineWidth',1,'Label', '1');
                % obj.pointPosition = obj.mask.Center;
            end
        end
        function circle_mask(obj,~,~)
            obj.rightbrowse;
            obj.mask_img;
        end
        function rightMove(obj, ~, ~)
            obj.rect_handle.Position(1) = obj.rect_handle.Position(1) + 2;
        end
        function leftMove(obj, ~, ~)
            obj.rect_handle.Position(1) = obj.rect_handle.Position(1) - 2;
        end
        function upMove(obj, ~, ~)
            obj.rect_handle.Position(2) = obj.rect_handle.Position(2) - 2;
        end
        function downMove(obj, ~, ~)
            obj.rect_handle.Position(2) = obj.rect_handle.Position(2) + 2;
        end
        function increaseDia(obj, ~, ~)
            obj.mask.Radius =  obj.mask.Radius + 2;
        end
        function decreaseDia(obj, ~, ~)
            obj.mask.Radius =  obj.mask.Radius - 2;
        end

        function   circleUpMove(obj,~,~)
            obj.mask.Center(2) = obj.mask.Center(2) -2;
        end

        function   circleDownMove(obj,~,~)
            obj.mask.Center(2) = obj.mask.Center(2) + 2;
        end
        function   circleLeftMove(obj,~,~)
            obj.mask.Center(1) = obj.mask.Center(1) - 2;
        end
        function   circleRightMove(obj,~,~)
            obj.mask.Center(1) = obj.mask.Center(1) + 2;
        end






        function resetimg(obj,~,~)
            obj.currentimg.Value = obj.beginimg.Value;
            obj.beginimg.BackgroundColor = 'g';
            pause(0.2);
            obj.beginimg.BackgroundColor = 'w';

            img = imread(strcat(obj.filepath_edit.Value,'worm',num2str(obj.currentimg.Value),'.jpg'));
            obj.image = imresize(img, 0.5);
            insertText(obj.image,[50 20],num2str(obj.currentimg.Value),'FontSize',36,'TextColor','black');
            set(obj.img_show1,'CData',obj.image);
            drawnow;

            obj.h_speed.YData = [];
        end
        function tryAna(obj, ~, ~)

            newimg1 = imgaussfilt(imcomplement(obj.rect_crop),2);
            %coef = 2*(get(obj.coef,'Value'));
            coef = 2;
            mask = createMask(obj.mask);
            obj.background = regionfill(newimg1,mask);
            newimg = (newimg1 - uint8(obj.background))*coef;
            con = contourc(double(newimg), 1);   % to calculate the contour of C.elegans
            cont_1 = obj.convertcontour(con);

            % if isobject(obj.imshow3)
            %     set(obj.imshow3, 'CData',obj.rect_crop);
            % else
            %     obj.imshow3 = imshow(obj.rect_crop,'Parent',obj.ax3);
            % end
            hold(obj.ax4,'on');
            if isobject(obj.h_plot)
                obj.h_plot.XData = cont_1(1,:);
                obj.h_plot.YData = cont_1(2,:);
            else
                obj.h_plot = plot(obj.ax4, cont_1(1,:), cont_1(2,:), 'red','LineWidth',1);
            end
            obj.pointPosition = (mean(cont_1, 2))';
            if isobject(obj.pointhandle)
                obj.pointhandle.Position = obj.pointPosition;
            else
                obj.pointhandle = drawpoint(obj.ax4,'Position',obj.pointPosition,'Color','g');
            end

            %obj.mask.Center = obj.pointPosition;
            hold(obj.ax2,'on');
            listno = obj.currentimg.Value - obj.beginimg.Value;
            if (listno == 0)
                obj.speed(1,:) = obj.pointPosition;
            else
                obj.speed((listno + 1),:) = obj.pointPosition;
                pixel_distance = obj.twopointdis(obj.speed((listno+1),:), obj.speed(listno,:));
                obj.speed_vector(listno) = obj.calibration.Value*pixel_distance;
                obj.speed_vector((listno + 1):end) = 0;
                if isobject(obj.h_speed)
                   obj.h_speed.YData = obj.speed_vector;
                else
                     obj.h_speed = plot(obj.ax2,1/360:1/360:1440/360,obj.speed_vector,'r');
                end
                

            end
        end
        function backwardAna(obj, ~, ~)
            if obj.currentimg.Value==obj.beginimg.Value
                return;
            else
                obj.backbrowse;
                obj.roi_callback;
                obj.mask_img;
                obj.tryAna;
            end 


        end
        function forwardAna(obj, ~, ~)
            if (obj.currentimg.Value==obj.beginimg.Value)&&obj.itsrun
                obj.itsrun = false;
                obj.roi_callback;
                obj.mask_img;
                obj.tryAna;
            else
                obj.rightbrowse;
                obj.itsrun = true;
                obj.roi_callback;
                obj.mask_img;
                obj.tryAna;
            end

            
        end

        function fastAna(obj, ~, ~)
            while obj.fastbtn.Value
                listno = obj.currentimg.Value - obj.beginimg.Value;
                if listno>1440
                    break;
                end
             obj.forwardAna;
            end
        end 
        function backfastAna(obj,~,~)
            while obj.backfastbtn.Value
                if obj.currentimg.Value==obj.beginimg.Value
                    break;
                end
                obj.backwardAna;
            end

        end
        function rightbrowse(obj, ~, ~)
            if obj.currentimg.Value<obj.beginimg.Value
                obj.currentimg.Value = obj.beginimg.Value;
            end
            set(obj.currentimg,'Value', obj.currentimg.Value+1);
            img = imread(strcat(obj.filepath_edit.Value,'worm',num2str(obj.currentimg.Value),'.jpg'));
            obj.image = imresize(img, 0.5);            
            insertText(obj.image,[50 20],num2str(obj.currentimg.Value),'FontSize',36,'TextColor','black');

            set(obj.img_show1,'CData',obj.image);
            drawnow;
        end
        function rightbrowse_fast(obj, ~, ~)

            while get(obj.right_toggle,'Value')

                obj.rightbrowse;
            end

        end
        function backbrowse(obj,~,~)

            if obj.currentimg.Value==obj.beginimg.Value
                return;
            end
            obj.currentimg.Value = obj.currentimg.Value - 1;
            img = imread(strcat(num2str(obj.filepath_edit.Value),'worm',num2str(obj.currentimg.Value),'.jpg'));
            obj.image = imresize(img, 0.5);            
            insertText(obj.image,[50 20],num2str(obj.currentimg.Value),'FontSize',36,'TextColor','black');

            set(obj.img_show1,'CData',obj.image);
            drawnow;
    
        end
        function backbrowse_fast(obj,~,~)
            while get(obj.back_toggle,'Value')
                if obj.currentimg.Value==obj.beginimg.Value
                    set(obj.back_toggle,'Value',0);
                    break;
                end
                obj.backbrowse;

            end
        end

        function distance = twopointdis(obj,point1,point2)
            X1 = point1(1);
            Y1 = point1(2);
            X2 = point2(1);
            Y2 = point2(2);
            distance=sqrt(((X1-X2)^2)+(Y1-Y2)^2);
        end
        function outputArg = convertcontour(obj, inputArg, ~)
            % to convert the output of contourc to contour line array;
            %   Detailed explanation goes here
            [~, col] = size(inputArg);
            i=1;
            setserial = zeros(1,10);
            while i<col

                colno = i+ sum(setserial);
                if colno>col
                    [M I] = max(setserial);
                    if I ==1
                        outcol = 2;
                    else
                        outcol = sum(setserial(1:(I-1))) + I+1;
                    end
                    outputArg = inputArg(:,outcol:(outcol+M-1));
                    break;
                else
                    setserial(i) = inputArg(2,colno);
                    i = i+1;
                end
            end

        end
        function saveto(obj, ~, ~)
            % if ( isempty(obj.filepath.String))
            %     obj.filepath.String='c:\';
            % end
            % obj.filepath.String=uigetdir(obj.filepath.String)
            % if isempty(get(handles.groupname,'String'))
            %     warndlg('Please set name for data','NO NAME');
            %     return;
            % end
            % [row col] = size(get(handles.speedtable,'Data'));
            % if row<10
            %     sptable = handles.speed_vector';
            %                 spname = get(handles.groupname,'String');
            % colName(1) = {spname};
            % else
            %     sptable = [get(handles.speedtable,'Data') handles.speed_vector'];
            %     %     spname = [get(handles.speedtable,'ColumnName') get(handles.groupname,'String')];
            %     colName = get(handles.speedtable,'ColumnName');
            %     [col_len, ~] = size(get(handles.speedtable,'ColumnName'));
            %     colName(col_len+1)= {get(handles.groupname,'String')};
                
            % end
            % set(handles.speedtable,'Data',sptable,'ColumnName',colName);


        end
        function copyto(obj, ~,~)
            clipboard("copy",obj.speed_vector);
        end
        function gotoana(obj, ~,~)

        end
        function exporttoexcel(obj,~,~)
            try
                ExcelApp = actxGetRunningServer('Excel.Application');
            catch iserror
                % colheader = {['AP#'],['RMP (mV)'], ['Threshold (mV)'], ['Amp (mV)'], ['APD50 (ms)'],['AHP (mV)'],['Rise time (ms)'],['Decay time (ms)'],['Rise slope (mV/ms)'],['Decay slope (mV/ms)'], ['RiseSlope(10-90%)(mV/ms)'], ['DecaySlope(10-90%)(mV/ms)'],[''],['Membrane Potential (mV)'],['Slope (mV/ms)'],[''],['Time (ms)'], ['Membrane Potential (mV)']};
                % writecell(colheader,'data.xlsx','Sheet',1,'Range','B1');
                % writecell(obj.data_table.Data(1:2,:),'data.xlsx','Sheet',1,'Range','C2');
                % writecell(obj.data_table.Data(3:end,:),'data.xlsx','Sheet',1,'Range','C5');
                % writematrix(round(phasedata,2),'data.xlsx','Sheet',1,'Range','O2');
                % writematrix(round(apdata,2),'data.xlsx','Sheet',1,'Range','R2');
                % writecell({['mean'];['SE']},'data.xlsx','Sheet',1,'Range','A2');
                % writematrix(apnono,'data.xlsx','Sheet',1,'Range','B5');
                writecell(obj.dataTable.ColumnName,'data.xlsx','Sheet',1,'Range','A1')
               writematrix(obj.dataTable.Data,'data.xlsx','Sheet',1,'Range','A2');
                winopen data.xlsx;
                return;
            end
            % ActiveWorkbook = ExcelApp.ActiveWorkbook;
            % ActiveSheet = ExcelApp.ActiveSheet;
            % 
            % ActiveSheet.Range('A2:A3').Value = {['mean'];['SE']};
            % ActiveSheet.Range(['B5:B',num2str(apno+2)]).Value = apnono;
            % ActiveSheet.Range('B1:T1').Value={['AP#'],['RMP (mV)'], ['Threshold (mV)'], ['AP Amp (mV)'], ['APD50 (ms)'],['AHP (mV)'],['Rise time (ms)'],['Decay time (ms)'],['Rise slope (mV/ms)'],['Decay slope (mV/ms)'], ['RiseSlope(10-90%)(mV/ms)'], ['DecaySlope(10-90%)(mV/ms)'],[''],['Membrane Potential (mV)'],['Slope (mV/ms)'],[''],['Time (ms)'], ['Membrane Potential (mV)']};
            % ActiveSheet.Range(['C2:M3']).Value= obj.data_table.Data(1:2,:);
            % ActiveSheet.Range(['C5:M',trow]).Value= obj.data_table.Data(3:end,:);
            % ActiveSheet.Range(['O2:P',num2str(size(phasedata,1))]).Value= round(phasedata,2);
            % ActiveSheet.Range(['R2:S',num2str(size(apdata,1))]).Value= round(apdata,2);

        end
        function sendtotable(obj,~,~)
            if isempty(obj.dataname.Value)
                uialert(obj.gui,'Please set data name !','Need more information.')
            else
                obj.uitablecolname{end+1} = obj.dataname.Value
                obj.dataTable.ColumnName = obj.uitablecolname;
                obj.dataTable.Data(:,end+1) = transpose(obj.speed_vector);
            end
            
        end
        function connectlight(obj,~,~)
            try
            obj.light = daq("ni");
            addoutput(obj.light,"myDAQ1","Port0/Line7","Digital");
            obj.light_h.ForegroundColor = 'r';
        catch
            errordlg('Fail to connect light','Light source');
        end
        end
        function onofflight(obj,~,~)
            if obj.onoff.Value==1

                write(obj.light,1);
                obj.onoff.String = 'Off';
            else
                write(obj.light,0);
                obj.onoff.String = 'On';
            end
        end
        function delete(obj)

        end
    end
end

