function [x,y,edge]=findSegment(x1,y1,x2,y2);

i=15;
done=0;
x=[x1(1)];
y=[y1(1)];
width=[];
edge=[];
w=40;
branchFound=0;
while ~done
   slope=[mean(diff(x1(i:i+5))) mean(diff(y1(i:i+5)))];
   perpSlope=[slope(2) -slope(1)]; perpSlope=perpSlope/norm(perpSlope);
   ln=2:w;
   lnx=x1(i)+perpSlope(1)*ln;
   lny=y1(i)+perpSlope(2)*ln;
   [X0,Y0,I,J] = intersections(x2,y2,lnx,lny,1);
   if length(I)>1
       I=min(I);
   end
   if isempty(I)
       branchFound=1;
   else
       I=round(I);
       if length(I)>1
           disp('more than one intersection found');
           I=min(I);
       end
       wid=ptDist(x1(i),y1(i),x2(I),y2(I));
       if i==15;
           width=[width wid];
       else
           avgWidth=mean(width);
           if wid<avgWidth*1.5
               width=[width wid];
           else
               branchFound=1;
           end
       end
   end
   
   if branchFound
       done=1;
   else
       [mx,my]=midpoint(x1(i),y1(i),x2(I),y2(I));
       i=i+5;
       w=round(mean(width)*2);
       x=[x mx];
       y=[y my];
       newEdge=[i;I];
       edge=[edge newEdge];
   end
   
end