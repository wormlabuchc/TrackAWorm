currentVentralDir=ventralDir(frame);
headx=x(1:2);
heady=y(1:2);

if currVentralDir~=0
    switch currVentralDir
        case 2 %right (starboard)
            perpDir=[3*diff(heady) -3*diff(headx)];

        case 1 %left (port)
            perpDir=[-3*diff(heady) 3*diff(headx)];

    end
    startPt=[mean(headx) mean(heady)];
    stopPt=[startPt(1)+perpDir(1) startPt(2)+perpDir(2)];
    startPt=[startPt(1) 480-startPt(2)+1];
    stopPt=[stopPt(1) 480-stopPt(2)+1];
%     startPt=[startPt(1) 480-startPt(2)+1];
    arrow(startPt,stopPt,'Length',7);
end