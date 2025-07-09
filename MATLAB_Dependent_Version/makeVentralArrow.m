


function [startPt,normalArrowComponents] = makeVentralArrow(currentFrame,x,y,ventralDir)

currentVentralDir = ventralDir(currentFrame);

xHeadSegment = x(1:end);
yHeadSegment = y(1:end);



switch currentVentralDir

    case 1

        normalArrowComponents = [-(yHeadSegment(end)-yHeadSegment(1)) -(xHeadSegment(end)-xHeadSegment(1))];

    case 2
       
        
        normalArrowComponents = [(yHeadSegment(end)-yHeadSegment(1)) (xHeadSegment(end)-xHeadSegment(1))];
        

        
end

normalArrowComponents = normalArrowComponents/norm(normalArrowComponents);

startPt = [x(7),y(7)];