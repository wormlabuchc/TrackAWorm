rowNums = floor((frameFileNumbers-1)/framerate);
fileList = listBmpsInFolder(splineFile(1:end-11));

fig1 = axes(figure);
fig2 = axes(figure);

axis(fig1,'equal');
axis(fig2,'equal');
hold(fig1,'on');
hold(fig2,'on');

res = size(imread(fileList{1}));

% tempx = x/calib;
% tempy = res(1) - y/calib;

prevRow = NaN;
xMov = 0; yMov = 0;

pause(3)
j = 1;

while j==1

    for i=1:length(fileList)
        
        drawnow
        
        hold(fig1,'off');
        
%         image(fig1,imread(fileList{i}));
        
        hold(fig1,'on');

        
%         if i>1
%             plot(fig1,tempx(i-1,:),tempy(i-1,:),'.b');
%             plot(fig1,mean(tempx(i-1,:)),mean(tempy(i-1,:)),'xb');
%         end
%         
%         
%         plot(fig1,tempx(i,:),tempy(i,:),'.r');
%         plot(fig1,mean(tempx(i,:)),mean(tempy(i,:)),'xr');
%         

        
        
%         cog = [mean(tempx(i,:)),mean(tempy(i,:))];
%         
%         if i>1
%             oldcog = [mean(tempx(i-1,:)),mean(tempy(i-1,:))];
%         end
%         
        
        %     ////////////////////////
        
        xMov = sum(stageData(1:rowNums(i)+1,1));
        yMov = sum(stageData(1:rowNums(i)+1,2));
        
%         if i==30
%             disp(xMov);
%             disp(yMov);
%         end
%         
%         xTempMov = stageData(rowNums(i)+1,1)/calib;
%         yTempMov = stageData(rowNums(i)+1,2)/calib;
        
        
%         if mod(i,15) == 1 && i>1
%             
%             plot(fig1,tempx(i-1,:)+xTempMov,tempy(i-1,:)-yTempMov,'.g');
%             plot(fig1,mean(tempx(i-1,:))+xTempMov,mean(tempy(i-1,:))-yTempMov,'xg');
%             
%             quiver(fig1,mean(tempx(i-1,:)),mean(tempy(i-1,:)),xTempMov,-yTempMov)
%             
%             pause(2)
%             
%         end
        
        xcomp = mean(x(i,:)) + xMov;
        ycomp = mean(res(1)*calib-y(i,:)) - yMov;
        
        plot(fig2,xcomp,ycomp,'x');
        
        prevX = xcomp; prevY = ycomp;
        prevRow = rowNums(i);
        
        drawnow
      
        
    end
    
    j = 2;
    
end


'j'