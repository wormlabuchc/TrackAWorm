function [curvature,circlevdDirs,xyWorm,pointsSelectedIndices,wormCircles,wormCircleCenters] = wormCurvature(xSpline,ySpline,ventralDir,dontSegment)

xSpline = interp(xSpline,9); ySpline = interp(ySpline,9);
xSpline = xSpline(1:5:end); ySpline = ySpline(1:5:end);

xyWorm = [xSpline' ySpline'];

if ~dontSegment

    [Ir,~] = findInflectionPoints(xSpline,ySpline);

    r = zeros(1,length(Ir)-1);
    lastcDirection = 0;
    pointsSelectedIndices = [];

    for i=1:length(Ir)-1
        
        xSeg = xSpline(Ir(i):Ir(i+1));
        ySeg = ySpline(Ir(i):Ir(i+1));

        xy = [xSeg' ySeg'];
        
        circle = CircleFitByKasa(xy);
        a = circle(1); b = circle(2); r(i) = circle(3);
        
        thetas = 0:.05:2*pi;
        
        cx = a+r(i)*cos(thetas);
        cy = b+r(i)*sin(thetas);

        cDirection = isClockwise(xSeg,ySeg);

        if i~=1
            
            cDirectionChange = cDirection-lastcDirection;
            
            if cDirectionChange==0
                
                if i==2
                    pointsSelectedIndices=[pointsSelectedIndices(i-1,1) Ir(i+1)];
                    
                else
                    pointsSelectedIndices=[pointsSelectedIndices(1:end-1,:); pointsSelectedIndices(end,1) Ir(i+1)];
                end
                
            elseif cDirectionChange~=0
                
                pointsSelectedIndices = [pointsSelectedIndices; Ir(i) Ir(i+1)];
                lastcDirection = cDirection;
            end

        else
            lastcDirection=cDirection;
            pointsSelectedIndices=[Ir(1) Ir(2)];
            
        end
    end
 
elseif dontSegment
    
    pointsSelectedIndices=[1 length(xSpline)];
end

L = pathLength(xSpline,ySpline);
rPrime = cell([1 size(pointsSelectedIndices,1)]);

circlevdDirs = cell(length(pointsSelectedIndices),1);
wormCircles = cell(length(pointsSelectedIndices),1);
wormCircleCenters = cell(length(pointsSelectedIndices),1);

newPointsSelectedIndices = cell([length(pointsSelectedIndices)]);


for i=1:length(pointsSelectedIndices(:,1))
    
    segStart = pointsSelectedIndices(i,1);
    segEnd = pointsSelectedIndices(i,2);
    
    segmentPoints = segStart:segEnd;
    
    xSeg = xSpline(segmentPoints);
    ySeg = ySpline(segmentPoints);
    
    xySpline = [xSeg' ySeg'];
    
    circle = CircleFitByKasa(xySpline);
    a = circle(1); b = circle(2); r = circle(3);
    
    rL = r/L;
    wL = pathLength(xSeg,ySeg);
    
    if rL>0.01 && rL<.8 && wL>3
        
        if isClockwise(xSeg,ySeg) && ventralDir==1
%           DORSAL
            circlevdDirs{i} = -1;
        elseif isClockwise(xSeg,ySeg) && ventralDir==2
%           VENTRAL
            circlevdDirs{i} = 1;
        elseif ~isClockwise(xSeg,ySeg) && ventralDir==1
%           VENTRAL
            circlevdDirs{i} = 1;
        elseif ~isClockwise(xSeg,ySeg) && ventralDir==2
%           DORSAL
            circlevdDirs{i} = -1;
        elseif ventralDir==0
            circlevdDirs{i} = 0;
        end
        
        rPrime{i} = rL;
        
        thetas = 0:.05:2*pi;
        cx = a+r*cos(thetas);
        cy = b+r*sin(thetas);
        
        wormCircles{i} = [cx' cy'];
        wormCircleCenters{i} = [a b];
        
        newPointsSelectedIndices{i} = [segStart,segEnd];
        
    end
end

rPrime = rPrime(~cellfun('isempty',rPrime));
circlevdDirs = circlevdDirs(~cellfun('isempty',circlevdDirs));
wormCircles = wormCircles(~cellfun('isempty',wormCircles));
wormCircleCenters = wormCircleCenters(~cellfun('isempty',wormCircleCenters));

pointsSelectedIndices = newPointsSelectedIndices(~cellfun('isempty',newPointsSelectedIndices));
pointsSelectedIndices = cell2mat(pointsSelectedIndices);

rPrime = cell2mat(rPrime);

circlevdDirs = cell2mat(circlevdDirs)';

rLInverses = rPrime.^-1;

curvature = rLInverses;

function [inflectionPoints,polarity] = findInflectionPoints(x,y)

inflectionPoints = 1;
polarity=[];

for i=2:length(x)-1
    
    va = [x(i)-x(i-1) y(i)-y(i-1) 0];
    vb = [x(i+1)-x(i) y(i+1)-y(i) 0];
    vaCrossvb = cross(va,vb);
    crossSign = sign(vaCrossvb(3));

    if i==2
        
        lastCrossSign = crossSign;
        polarity = crossSign;
        
    elseif crossSign ~= lastCrossSign
        
        inflectionPoints = [inflectionPoints i];
        lastCrossSign = crossSign;
        polarity = [polarity crossSign];
    end
end

inflectionPoints=[inflectionPoints length(x)];