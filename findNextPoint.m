function [newPoint,newTheta,angDiff,width,edges]=findNextPoint(x1,y1,x2,y2,previousPoint,previousTheta,L)
done=0;
LL=round(length(x1)/5);
if LL<20
    LL=min([length(x1) length(x2)]);
end
x1o=x1; x2o=x2; y1o=y1; y2o=y2;

while ~done
    if ~isempty(previousTheta)
        dx=cos(previousTheta);
        dy=sin(previousTheta);
        previousVector=[dx dy]/norm([dx dy]);
        perpVector=[-previousVector(2);previousVector(1)];
        ln=perpVector*(-25:25);
        lnx=previousPoint(1)+ln(1,:);
        lny=previousPoint(2)+ln(2,:);

        [tempx,tempy,aCutoff,aa] = intersections(x1,y1,lnx,lny,0);  %all I care about is "aCutoff", the index of x1/y1 that intersects the perpendicular point
        [tempx,tempy,bCutoff,aa] = intersections(x2,y2,lnx,lny,0); %ditto for b
        aCutoff=round(aCutoff);bCutoff=round(bCutoff);
        aCutoff=min(aCutoff); bCutoff=min(bCutoff);
        plot(lnx,lny) 
        plot(x1(aCutoff),y1(aCutoff),'ko')
        plot(x2(bCutoff),y2(bCutoff),'ko')
        
        if isempty(aCutoff) || isempty(bCutoff) || mean([x1(aCutoff) y1(aCutoff)] == [x2(bCutoff) y2(bCutoff)])
            disp('straight line cutoff phase encountered an error')
            newPoint=[];
            newTheta=[];
            angDiff=[];
            width=[];
            edges=[];
            return
        else
            aCutoff=min(aCutoff);bCutoff=min(bCutoff);
            try
                x1=x1(aCutoff:aCutoff+LL);y1=y1(aCutoff:aCutoff+LL);
                x2=x2(bCutoff:bCutoff+LL);y2=y2(bCutoff:bCutoff+LL);
            catch
                x1=x1(aCutoff:end);y1=y1(aCutoff:end);
                x2=x2(bCutoff:end);y2=y2(bCutoff:end);
            end
            done=1;
        end

    else
        x1=x1(1:LL);
        y1=y1(1:LL);
        x2=x2(1:LL);
        y2=y2(1:LL);
        done=1;
    end

end

done=0;
tries=0;

while ~done
    thetas=0:2*pi/360:2*pi;
    dx=L*cos(thetas);
    dy=L*sin(thetas);
    curvex=previousPoint(1)+dx;
    curvey=previousPoint(2)+dy;
    plot(curvex,curvey)
    [tempx,tempy,a,aa] = intersections(x1,y1,curvex,curvey,0);  %all I care about is "a", the index of x1/y1 that intersects the curve
    [tempx,tempy,b,bb] = intersections(x2,y2,curvex,curvey,0);  %ditto

    if isempty(a) || isempty(b)
%         disp('curve cutoff phase encountered an error')
%         plot(lnx,lny)
%         L=L*1.25;
%         if tries==1
%             L=L*.5;
%         elseif tries==2
            newPoint=[];
            newTheta=[];
            angDiff=[];
            width=[];
            edges=[];
            return
%         end
%         tries=tries+1;

%         pause
    elseif ~isempty(a) && ~isempty(b)
        done=1;
    end
    
    
end

a=round(a); b=round(b); aa=round(aa); bb=round(bb);
angA=thetas(aa);
angA
angB=thetas(bb);
angB
plot(x1(a),y1(a),'rx')
plot(x2(b),y2(b),'rx')
width=ptDist(x1(a),y1(a),x2(b),y2(b));
[angA,angB]=reformatAngles(angA,angB);
if angB-angA<0
    angDiff=angB+2*pi-angA;
else
    angDiff=angB-angA;
end
angDiff*180/pi

newTheta=mod(angA+angDiff/2,2*pi);
dx=L*cos(newTheta);
dy=L*sin(newTheta);
newPoint=[previousPoint(1)+dx previousPoint(2)+dy];
edgeA=intersect(find(x1o==x1(a)),find(y1o==y1(a)));
edgeB=intersect(find(x2o==x2(b)),find(y2o==y2(b)));
edges=[edgeA edgeB];

function [angA,angB]=reformatAngles(ang1,ang2)
angs=[ang1,ang2];
ang1=min(angs);
ang2=max(angs);
angD=ang2-ang1;
angDReverse=ang1+2*pi-ang2;
if angDReverse<angD
    angA=ang2;
    angB=ang1;
else
    angA=ang1;
    angB=ang2;
end