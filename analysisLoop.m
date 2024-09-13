crossData=[];
manualNeeded = zeros([1 length(filelist)]);
thresholdMem = [threshold threshold];
threshold = threshold*[1 .9 .8 .7 .6];

res = size(imread(filelist{1}));


for i=1:length(filelist)
    
    t=1;
    attempt=1;
    done=0;
    %percentComplete=(num2str(i)./num2str(length(filelist)))*100;
    disp(['Processing frame ' num2str(i) ' of ' num2str(length(filelist))]);
    percentComplete=['Processing frame ' num2str(i) ' of ' num2str(length(filelist))];
    set(handles.percentComplete,'String',percentComplete);
    %percentComplete= (i/ length(filelist))*100;
    %set(handles.percentComplete, 'String', sprintf('Percent Complete: %.2f%%', percentComplete));
    %set(handles.slideCompletion,'Value',percentComplete);
    file = filelist{i};
    
%     RESOLUTION OF EACH IMAGE

    
%     LOOP UNTIL PROPER XCL/YCL SET IS FOUND
    
    while ~done
        
        drawnow
        
        try
            if ~isempty(prevX) %ALL ITERATIONS AFTER THE FIRST
                [xcl,ycl,xCross,yCross]=mainProcess3(file,0,clow,chigh,threshold(t),prevX,prevY);
                                          %run automated search for spline
            else %FIRST ITERATION
                [xcl,ycl,xCross,yCross]=mainProcess3(file,0,clow,chigh,threshold(t));
              
            end

            if i==1 && ~exist('inBatchMode','var') %FIRST ITERATION - let the user check the computer's work if not in batch mode
                
                prevX=[]; prevY=[];
                fig=figure;
                imshow(imread(file));
                hold on
                plot(xcl,res(1)-ycl+1,'c.');
                plot(xcl(1),res(1)-ycl(1)+1,'cx','MarkerSize',12);
                hold off
                choice = questdlg('Swap?','Initial Head Recognition','Keep','Swap','Keep');
                switch choice
                    case 'Keep'
                    case 'Swap'
                        [xcl,ycl,xCross,yCross]=mainProcess3(file,1,clow,chigh,threshold(t));
                end
                delete(fig)
            end
            
            wormLength = pathLength(xcl,ycl); %check the head and tail positions
            
            if i~=1
                
                if ptDist(xcl(1),ycl(1),lastHeadX,lastHeadY)>ptDist(xcl(end),ycl(end),lastHeadX,lastHeadY)
                    %fprintf('\nSwapping head with tail\n')
                    [xcl,ycl,xCross,yCross]=mainProcess3(file,1,clow,chigh,threshold(t),prevX,prevY);
                    %disp('Swapped head and tail')
                end
                
            end

            if sum(xcl)~=0 && sum(ycl)~=0 %if an acceptable spline is found, save it as prevX/prevY
                prevX=xcl;
                prevY=ycl;
            end

            lastHeadX = xcl(1); lastHeadY = ycl(1);  %store the last head position for the next iteration of the loop
            done=1;
            fprintf('Successfully produced spline\n\n\n');
            
        catch
            disp('Analysis failed--Trying again')
            %Analysisfailed='Analysis failed--Trying again';
            %set(handles.percentComplete,'String',Analysisfailed);
            disp(['Attempt: ' num2str(attempt)])
            %Attemptnow=strcat('Attempt: ', num2str(attempt));
            %set(handles.percentComplete,'String',Attemptnow);
            attempt=attempt+1;
            if attempt==2
                t=2;    
                %t is the variable that describes which multiplier of threshold to use, typically 0.9, then 1.1, then 0.8, then 1.2.
            elseif attempt==3
                t=3;
            elseif attempt==4
                t=4;
            elseif attempt==5
                t=5;
            elseif attempt>5   %skip if 5 attempts fail
                xcl=zeros(1,13);	%come back later to do these manually. everything gets set to zero
                ycl=zeros(1,13);
                done=1;
                manualNeeded(i) = 1;
                fprintf('\n\n');
            end
        end
        
        if exist('xcl','var') %|| mean(xcl==[0 0 0 0 0 0 0 0 0 0 0 0 0])~=1
            thresholdMem(mod(i,2)+1) = threshold(t);
            splineData(2*i-1:2*i,:)=[xcl;ycl];
        end
        

    end
    crossData=[crossData; xCross; yCross];
    if attempt ~= 1 && attempt <= 5 && thresholdMem(1) == thresholdMem(2)
        threshold = [threshold(t) threshold(1:t-1) threshold(t+1:end)];
        fprintf('\nChanged threshold\n');
    end
        
end
 