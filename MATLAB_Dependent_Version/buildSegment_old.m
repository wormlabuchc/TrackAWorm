function [x,y]=buildSegment_old(xSeq,ySeq,xSeq2,ySeq2)
if  (corner<firstPoint && firstPoint-corner<corner+length(xSeq)-firstPoint)
    x1=fliplr(xSeq(corner:firstPoint));
    y1=fliplr(ySeq(corner:firstPoint)); 
    cornerSlope=[mean(diff(x1(end-10:end-5))) mean(diff(y1(end-10:end-5)))];
    cornerSlope=cornerSlope/norm(cornerSlope);
    perpSlope=[-cornerSlope(2) cornerSlope(1)];
    ln=5:40;
    lnx=xSeq(corner)+perpSlope(1)*ln;
    lny=ySeq(corner)+perpSlope(2)*ln;
    [X0,Y0,I,J] = intersections(xSeq,ySeq,lnx,lny,0); 
    if ~isempty(I)
        I=round(min(I));
        x2e=xSeq(firstPoint:end);
        x2i=[xSeq(firstPoint:end) xSeq(1:I)];
        if I<firstPoint
            x2=[xSeq(firstPoint:end) xSeq(1:I)];
            y2=[ySeq(firstPoint:end) ySeq(1:I)];
        else
            x2=xSeq(firstPoint:I);
            y2=ySeq(firstPoint:I);
        end
    else
        x2=[xSeq(firstPoint:end) xSeq(1:firstPoint-1)];
        y2=[ySeq(firstPoint:end) ySeq(1:firstPoint-1)];
    end
elseif (corner>firstPoint && firstPoint+length(xSeq)-corner<corner-firstPoint)
    x1=[fliplr(xSeq(1:firstPoint)) fliplr(xSeq(corner:end))];
    y1=[fliplr(ySeq(1:firstPoint)) fliplr(ySeq(corner:end))]; 
    cornerSlope=[mean(diff(x1(end-10:end-5))) mean(diff(y1(end-10:end-5)))];
    cornerSlope=cornerSlope/norm(cornerSlope);
    perpSlope=[-cornerSlope(2) cornerSlope(1)];
    ln=5:40;
    lnx=xSeq(corner)+perpSlope(1)*ln;
    lny=ySeq(corner)+perpSlope(2)*ln;
    [X0,Y0,I,J] = intersections(xSeq,ySeq,lnx,lny,0); 
    if ~isempty(I)
        I=round(min(I));
        x2=xSeq(firstPoint:I);
        y2=ySeq(firstPoint:I);
    else
        x2=[xSeq(firstPoint:end) xSeq(1:firstPoint-1)];
        y2=[ySeq(firstPoint:end) ySeq(1:firstPoint-1)];
    end
elseif (corner>firstPoint &&  corner-firstPoint<firstPoint+length(xSeq)-corner) 
    x1=xSeq(firstPoint:corner);
    y1=ySeq(firstPoint:corner);
    cornerSlope=[mean(diff(x1(end-10:end-5))) mean(diff(y1(end-10:end-5)))];
    cornerSlope=cornerSlope/norm(cornerSlope);
    perpSlope=[cornerSlope(2) -cornerSlope(1)];
    ln=5:40;
    lnx=xSeq(corner)+perpSlope(1)*ln;
    lny=ySeq(corner)+perpSlope(2)*ln;
    [X0,Y0,I,J] = intersections(xSeq,ySeq,lnx,lny,0); 
    I=round(min(I));
    if ~isempty(I)
        if firstPoint<I
            x2=[fliplr(xSeq(1:firstPoint)) fliplr(xSeq(I:end))];
            y2=[fliplr(ySeq(1:firstPoint)) fliplr(ySeq(I:end))];
        else
            x2=fliplr(xSeq(I:firstPoint));
            y2=fliplr(ySeq(I:firstPoint));
        end
    else
        x2=[fliplr(xSeq(1:firstPoint-1)) fliplr(xSeq(firstPoint:end))];
        y2=[fliplr(ySeq(1:firstPoint-1)) fliplr(ySeq(firstPoint:end))];
    end
elseif (corner<firstPoint && corner+length(xSeq)-firstPoint<firstPoint-corner)
    x1=[xSeq(firstPoint:end) xSeq(1:corner)];
    y1=[ySeq(firstPoint:end) ySeq(1:corner)];
    cornerSlope=[mean(diff(x1(end-10:end-5))) mean(diff(y1(end-10:end-5)))];
    cornerSlope=cornerSlope/norm(cornerSlope);
    perpSlope=[cornerSlope(2) -cornerSlope(1)];
    ln=5:40;
    lnx=xSeq(corner)+perpSlope(1)*ln;
    lny=ySeq(corner)+perpSlope(2)*ln;
    [X0,Y0,I,J] = intersections(xSeq,ySeq,lnx,lny,0); 
    if ~isempty(I)
        I=round(min(I));
        x2=fliplr(xSeq(I:firstPoint));
        y2=fliplr(ySeq(I:firstPoint));
    else
        x2=[fliplr(xSeq(1:firstPoint-1)) fliplr(xSeq(firstPoint:end))];
        y2=[fliplr(ySeq(1:firstPoint-1)) fliplr(ySeq(firstPoint:end))];
    end
   
end

if L==0
    [newX,newY]=midpoint(x1(end),y1(end),x2(end),y2(end));
    x=[xSeq(firstPoint) newX];
    y=[ySeq(firstPoint) newY];
elseif L~=0  
    previousPoint=[xSeq(firstPoint) ySeq(firstPoint)];
    points=previousPoint';
    thetas=[];
    angDiffs=[];
    widths=[];
    edges=[];
    previousTheta=[];
    done=0;

    while ~done
        done=checkIfDone(x1,y1,x2,y2,previousPoint,edges,L);
        if ~done
            [newPoint,newTheta,angDiff,width,edge]=findNextPoint(x1,y1,x2,y2,previousPoint,previousTheta,L)
            points=[points newPoint'];
            thetas=[thetas newTheta];
            angDiffs=[angDiffs angDiff];
            widths=[widths width];
            edges=[edges edge'];
            previousPoint=newPoint;
            previousTheta=newTheta;
            if length(thetas)~=0
                if angDiffs(end)>2*mean(angDiffs(1:end-1)) || widths(end)>2*mean(widths(1:end-1)) || isempty(newTheta) || isempty(newPoint)
                    done=1;
                end
            end

        end

    end
    x=points(1,:);
    y=points(2,:);
    [newX,newY]=midpoint(x1(end),y1(end),x2(end),y2(end));
    pd=ptDist(x(end),y(end),newX,newY);
    if pd>5 && pd<L
        x=[x newX];
        y=[y newY];
    end
end