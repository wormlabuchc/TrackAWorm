classdef SleepRecorder < handle
   properties
      Value {mustBeNumeric}
      vid  %camera videoinput handle
      ax       %axes handle
      connect  %connect camera handle
      disconnect
      labelcam
      img
      imgpre
      imgpreview
      preview_h
      record_h
      src
      exposure
      filepath
      duration
      interval
      light
      light_h
      onoff
   end
   methods
       function obj = SleepRecorder         % it is a constructor funciton
           gui = uifigure('Name','SleepRecorder','Position',[10 50 1200 768],'Resize','on');
           gui.MenuBar = 'none';
           gui.ToolBar = 'none';
           sleeplayout = uigridlayout(gui);
           sleeplayout.RowHeight = {500,'1x'};
           sleeplayout.ColumnWidth ={300,'1x'};
           setpanel = uipanel(sleeplayout,'BorderType','none');
           setpanel.Layout.Row = 1;
           setpanel.Layout.Column = 1;
           % create axes in figure gui
           obj.ax = uiaxes(sleeplayout,'Position',[0.2 0.02 0.78 0.95],'Box','on','XTick',[],'YTick',[]);
           obj.ax.Units = 'pixels';
           obj.ax.Toolbar.Visible = 'off';
           obj.ax.Layout.Row = [1 2];
           obj.ax.Layout.Column = 2;
           uilabel(setpanel,"Text",'Sleep Recorder','Position',[50 400 150 30],'FontSize',20,'FontWeight','bold');
           %connect camera button

           % obj.connect_camera = uicontrol(setpanel,'Style', 'pushbutton', 'Position', [50 340 90 25],'FontName', 'arial','FontSize',10,...
           %     'FontWeight', 'normal', 'Callback', @obj.ConnectCamera, 'String', 'Connect');
           % obj.disconnect = uicontrol(setpanel,'Style', 'pushbutton', 'Position', [170 340 90 25],'FontName', 'arial','FontSize',10,...
           %     'FontWeight', 'normal', 'Callback', @obj.ConnectCamera, 'String', 'Disconnect');
           obj.connect = uibutton(setpanel,'push','text','Connect','Position', [50 340 90 25],'ButtonPushedFcn',@obj.ConnectCamera,'Enable','on');
           obj.disconnect = uibutton(setpanel,'push','text','Disconnect','Position', [175 340 90 25],'ButtonPushedFcn',@obj.disconnectcam,'Enable','off');
           obj.labelcam = uilabel(setpanel,"Text",'Camera','Position',[130 310 60 22],'FontSize',14,'FontWeight','normal','FontName','arial','FontColor','r');
           
           %exposure time
           uicontrol(setpanel,'Style', 'text', 'Position', [50 280 140 18],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal','String', 'Exposure Time','HorizontalAlignment','left');
           obj.exposure = uicontrol(setpanel,'Style', 'popupmenu', 'Position', [170 280 55 20],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal','String', ["3.5" "10" "30" "50" "100" "200"], 'Value',4,'HorizontalAlignment','right');
           uilabel(setpanel,"Text",'ms','Position',[230 280 40 22],'FontSize',14,'FontWeight','normal','FontName','arial');

           % interval edit box
           uicontrol(setpanel,'Style', 'text', 'Position', [50 240 140 20],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal','String', 'Frame Interval','HorizontalAlignment','left');
           obj.interval = uicontrol(setpanel,'Style', 'edit', 'Position', [170 240 55 20],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal','String','10');
            uilabel(setpanel,"Text",'sec','Position',[230 240 40 22],'FontSize',14,'FontWeight','normal','FontName','arial');

           % Duration edit box
           uicontrol(setpanel,'Style', 'text', 'Position', [50 200 140 20],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal','FontName','arial','String', 'Record Duration','HorizontalAlignment','left');
           obj.duration = uicontrol(setpanel,'Style', 'edit', 'Position', [170 200 55 20],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal','String','10');
           uilabel(setpanel,"Text",'hrs','Position',[230 200 40 22],'FontSize',14,'FontWeight','normal','FontName','arial');


           % save file edit box
           uicontrol(setpanel,'Style', 'pushbutton', 'Position', [50 150 160 25],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal','String', 'Set Image Holder','Callback',@obj.saveto);
           obj.filepath = uicontrol(setpanel,'Style', 'edit', 'Position', [50 120 200 25],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal');

           %preview button
           obj.preview_h = uicontrol(setpanel,'Style', 'togglebutton', 'Position', [50 70 200 25],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal', 'Callback', @obj.previewvid, 'String', 'Preview');

           
           %record button
           obj.record_h = uicontrol(setpanel,'Style', 'togglebutton', 'Position', [50 10 200 25],'FontName', 'arial','FontSize',10,...
               'FontWeight', 'normal', 'Callback', @obj.record, 'String', 'Record');
                 
       end
       function ConnectCamera(obj,~,~)
           try
               obj.vid = videoinput('tisimaq_r2013_64', 1, 'RGB24 (1440x1080)');     
               % v = videoinput("tisimaq_r2013_64", 1, "RGB24 (1024x768)");
               obj.src = getselectedsource(obj.vid);
               obj.src.Sharpness=4;
               obj.src.ExposureAuto='Off';
               % obj.connect_camera.ForegroundColor = 'g';
               start(obj.vid);
               obj.disconnect.Enable = 'on';
               obj.connect.Enable = 'off';
               obj.labelcam.FontColor = 'g';
           catch
               errordlg('Fail to connect camera !!!','Camera error');
           end
       end
       function disconnectcam(obj,~,~)
           obj.disconnect.Enable = 'off';
           obj.connect.Enable = 'on';
           obj.labelcam.FontColor = 'r';
                delete(obj.vid);
           
       end
      function previewvid(obj, ~, ~)
          switch obj.exposure.Value
              case 1
                  exposure_time = 0.0035;
              case 2
                  exposure_time = 0.01;
              case 3
                  exposure_time = 0.03;
              case 4
                  exposure_time = 0.05;
              case 5
                  exposure_time = 0.1;
              case 6
                  exposure_time = 0.2;
          end             
              set(obj.src,'Exposure',exposure_time)
              axis(obj.ax,'tight');
              
              number=1;
              while obj.preview_h.Value ==1
                      obj.preview_h.ForegroundColor = 'r';
                      obj.record_h.Value ==0
                      obj.record_h.ForegroundColor = [0 0 0];
                       img = getsnapshot(obj.vid);
                      if isempty(obj.imgpreview)
                       obj.imgpreview = imshow(img,'Parent',obj.ax);
                      else
                          obj.imgpreview.CData = img;
                      end
                      pause(0.1);
              end
              stop(obj.vid);
              obj.preview_h.ForegroundColor = [0 0 0];
      end
      function record(obj, ~, ~)
              if obj.preview_h.Value ==1 && obj.record_h.Value ==1
                  obj.preview_h.Value =0;
                  obj.preview_h.ForegroundColor = [0 0 0];
                  stop(obj.vid);
              end
              
              triggerconfig(obj.vid, 'manual');

              obj.vid.FramesPerTrigger = 1;
              if isempty(obj.filepath.String)
                  errordlg('Please set file path','Filepath error');
                  return;
              end
              obj.record_h.ForegroundColor = 'r';

              number=1;
              imgarray = dir ([obj.filepath.String '/*.jpg']);
              if  numel(imgarray)>number
                  number=numel(imgarray);
              end
              record_time = str2double(obj.duration.String)*360;
              while obj.record_h.Value
                  if record_time<number
                      quit;
                  end 
                  tic;
                   pause(0.05);
                  img = getsnapshot(obj.vid);
                  img = insertText(img,[1350 5],num2str(number),'FontSize',36,'TextColor','white','BoxColor','black');
                  img = rgb2gray(img);
                  imwrite(img,strcat(obj.filepath.String,'\worm',num2str(number),'.jpg'));
                  img = insertText(img,[5 5],'recording','FontSize',26,'TextColor','red');

                  if isempty(obj.imgpre)
                  obj.imgpre = imshow(img,'Parent',obj.ax);
                  else
                  set(obj.imgpre,'CData',img);                     
                  end
                  drawnow;
                  number=number+1;
                  runtime=toc;
                  run_interval = str2double(obj.interval.String) - runtime;
                  pause(run_interval);
              end
              % stop(obj.vid);
              obj.record_h.ForegroundColor = [0 0 0];
      end
      function saveto(obj, ~, ~)
          if ( isempty(obj.filepath.String))
              obj.filepath.String='c:\';
          end
          obj.filepath.String=uigetdir(obj.filepath.String) 
      end


      function delete(obj)
          
          delete(obj.vid);
      end
   end
end