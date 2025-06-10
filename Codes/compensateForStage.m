function [xcl,ycl]=compensateForStage(xcl,ycl,frameNumber,stageMovement,framerate,rawrate)

% rawrate
% framerate
%xcl, ycl are row vectors;
%     frameRate;
% if rawrate==15 && (frameRate==5 || frameRate==3 ||frameRate==1)
%     rowNum=fix((frameNumber-2)/frameRate)+1;
% else
%     rowNum=fix((frameNumber-1)/frameRate)+1;
% end
% if framerate==15 
if framerate==5||framerate==1||framerate==3
    rowNum=fix((frameNumber-1)/framerate)+1;
    xStageMovement=stageMovement(:,1);
    yStageMovement=stageMovement(:,2);
    xMove=sum(xStageMovement(1:rowNum));
    yMove=sum(yStageMovement(1:rowNum));
    xcl=xcl+xMove;
    ycl=ycl+yMove;   
else 
    rowNum=fix((frameNumber-2)/rawrate)+1;
    xStageMovement=stageMovement(:,1);
    yStageMovement=stageMovement(:,2); 
    xMove=sum(xStageMovement(1:rowNum));
    yMove=sum(yStageMovement(1:rowNum)); 
    xcl=xcl+xMove;
    ycl=ycl+yMove;

end
                       

%rowNum=fix((frameNumber-1.5)/framerate)+1;

    %xStageMovement=stageMovement(:,1);
    %yStageMovement=stageMovement(:,2);
    %[frameNumber,rowNum,size(stageMovement)]
    %xMove=sum(xStageMovement(1:rowNum));
    %yMove=sum(yStageMovement(1:rowNum));

   %[xcl(:,1),ycl(:,1)]
    %[xMove(:,1),yMove(:,1)]
    %xcl=xcl+xMove;
    %xcl=xMove;
    %ycl=ycl+yMove;
%ycl=yMove;
   
    


