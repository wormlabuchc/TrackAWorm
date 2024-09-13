tempA = imaqhwinfo('tisimaq_r2013_64');
tempA = tempA.DeviceInfo;
tempA = tempA.SupportedFormats;

compPics = cell([3 6]);

axes(figure);

for i=[1:18]
    
    if i>6
        tempi = i+4;
    else
        tempi = i;
    end
    
    disp([num2str(tempi) ' - ' tempA{i}]);
    vid = videoinput('tisimaq_r2013_64',1,tempA{tempi});
    compPics{i} = getsnapshot(vid);
    res = size(compPics{i});
    imshow(compPics{i});
    text(res(1)/2,res(2)/2,num2str(i),'Color','r','FontSize',20);
    f = getframe(gca);
    compPics{i} = f.cdata(:,:,:);
   
end


montage(compPics);