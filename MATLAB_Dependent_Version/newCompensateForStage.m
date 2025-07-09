function [xclComp,yclComp] = newCompensateForStage(xcl,ycl,frameFileNumber,stageMovement,frameRate,res,calib)

% ROW NUM IS THE LAST STAGE MOVEMENT TO OCCOUR BEFORE THE FRAME WAS RECORDED
rowNum = floor((frameFileNumber-1)/frameRate);

rowNum = min([rowNum length(stageMovement)]); % TO PREVENT ERROR FROM ANY EXTRA FRAMES, MAY BE UNNECESSARY

xMove = sum(stageMovement(1:rowNum+1,1));    % STAGE MOVEMENT IS EXPRESSED IN UM
yMove = sum(stageMovement(1:rowNum+1,2));

% if frameFileNumber==30
%     disp('a');
%     disp(xMove);
%     disp(yMove);
%     disp('-');
% end

% IF CODE BELONGS THE ANY OF THE FIRST TWO FRAMES OF EACH SECOND INTERVAL,
% WITH THE EXCEPTION OF THE VERY FIRST SECOND INTERVAL OF THE RECORDING, IT
% IS REMOVED -- THE STAGE HAS NOT FINISHED MOVING BY THAT POINT

% if ~ismember(frameFileNumber,1:15) && (mod(frameFileNumber,15)==0 || (mod(frameFileNumber,15)==1) || (mod(frameFileNumber,15)==2) || (mod(frameFileNumber,15)==3))
if 1~=1
    xclComp = NaN(size(xcl));
    yclComp = NaN(size(ycl));
else
    xclComp = xcl + xMove;
    yclComp = (res(1)*calib)-ycl-yMove;
end