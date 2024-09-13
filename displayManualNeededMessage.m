% function displayManualNeededMessage(handles)
% 
% % THIS FUNCTION UPADTES THE 'MANUAL NEEDED' MESSAGE ON batchTrack_gui AND
% % DRAWS RED FRAMES AROUND UNSUCCESSFUL FRAMES
% 
% manualNeeded = get(handles.manualNeededText,'UserData');
% framesNeeded = find(manualNeeded);
% numberNeeded = length(framesNeeded);
% 
% % CHOOSE APPROPRIATE FORMAT FOR MESSAGE BASED ON NUMBER OF FRAMES NEEDED
% 
% if ~numberNeeded
%     message = "No manual splines are currently needed.";
% elseif numberNeeded == 1
%     message = ['Manual spline needed at frame ' num2str(framesNeeded(1)) '.'];
% elseif numberNeeded == 2
%     message = ['Manual spline needed at frames ' num2str(framesNeeded(1)) ' and ' num2str(framesNeeded(2)) '.'];
% elseif ismember(numberNeeded,[3 4 5 6 7])
%     message = ['Manual spline needed at frames ' strjoin(string(framesNeeded(1:end)),',') ' and ' framesNeeded(end) '.'];
% else
%     message = ['Manual spline needed at frames ' strjoin(string(framesNeeded(1:7)),',') ' and ' num2str(length(framesNeeded(7:end))) ' other(s).'];
% end
% 
% message = strjoin(string(message));
% 
% % SET 'MANUAL NEEDED' MESSAGE PROPERTIES OR RESET TO DEFAULT
% 
% set(handles.manualNeededText,'String',message);
% 
% if ~numberNeeded
% 
%     set(handles.manualNeededText,'ForegroundColor','k');
%     set(handles.manualNeededText,'FontAngle','italic');
% 
% else
% 
%     set(handles.manualNeededText,'ForegroundColor','r');
%     set(handles.manualNeededText,'FontAngle','normal');
% 
% end