rowNums = floor((frameFileNumbers-1)/framerate);
fileList = listBmpsInFolder(splineFile(1:end-11));

fig1 = figure;
fig2 = figure;

axis(fig1,'equal');
axis(fig2,'equal');
hold(fig1,'equal');
hold(fig2,'equal');

res = size(imread(fileList{1}));

tempx = x/calib;
tempy = res(1) - y/calib;

for i=2:length(fileList)
    
    i
    
    hold(fig2,'off');
     
    imshow(fig2,imread(fileList{i}));
    
    hold(fig2,'on');
    
    plot(fig2,tempx(i-1,:),tempy(i-1,:),'.b');
    plot(fig2,tempx(i,:),tempy(i,:),'.r');
    
    cog = [mean(tempx(i,:)),mean(tempy(i,:))];
    oldcog = [mean(tempx(i-1,:)),mean(tempy(i-1,:))];
    
%     plot(cog(1),cog(2),'xr');
%     plot(oldcog(1),oldcog(2),'xb');
    
%     quiver(oldcog(1),oldcog(2),cog(1)-oldcog(1),cog(2)-oldcog(2))
%     
%     if rowNums(i)~=rowNums(i-1)
%         
%         stageMov = stageData(rowNums(i)+1,:)/calib;
%         quiver(oldcog(1),oldcog(2),-stageMov(1),stageMov(2));
%         
% %         pause(2);
%     end
    
    drawnow
    
    pause(0)
    
end

axes(figure)
axis equal 
hold on

hold on

prevRow = NaN;
xMov = 0; yMov = 0;


for i=2:length(fileList)
    
    xMov = sum(stageData(1:rowNums(i)+1,1)/calib);
    yMov = sum(stageData(1:rowNums(i)+1,2)/calib);

%     if mod(i,15) == 1 && i>1
%         
%         xMov = mean(tempx(i,:)) - mean(tempx(i-1,:)) + xMov
%         yMov = mean(tempy(i,:)) - mean(tempy(i-1,:)) + yMov
%         
%     end
    
    xcomp = mean(tempx(i,:)) + xMov;
    ycomp = mean(tempy(i,:)) + yMov;
    
    plot(xcomp,ycomp,'x');
    
    if i>1 && prevRow ~= rowNums(i)
        
%         quiver(xcomp-xMov,ycomp-yMov,xMov,yMov);
        
    end
    
    prevX = xcomp; prevY = ycomp;
    prevRow = rowNums(i);
    
end

