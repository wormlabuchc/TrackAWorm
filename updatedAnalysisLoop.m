crossData=[];
manualNeeded = zeros([1 length(filelist)]);
thresholdMem = [threshold threshold];
threshold = threshold*[1 .9 .8 .7 .6];

res = size(imread(filelist{1}));

splineDataX = zeros([size(splineData,1)/2 size(splineData,2)]);
splineDataY = splineDataX;

parfor i=1:length(filelist)
    
    t=1;
    attempt=1;
    done=0;
    
    disp(['Processing frame ' num2str(i) ' of ' num2str(length(filelist))]);
    
    file = filelist{i};
    
    
    while ~done
        
        drawnow
        
        try
            
            [xcl,ycl,xCross,yCross]=mainProcess3(file,0,clow,chigh,threshold(t));
            
            done=1;
            fprintf('Successfully produced spline\n\n\n');
            
            splineDataX(i,:) = xcl;
            splineDataY(i,:) = ycl;
            
        catch
            disp('Analysis failed--Trying again')
            done=1;
            
        end
        
    end
end