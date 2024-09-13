function dir=isClockwise(x,y)
%This function must be able to determine whether a series of consecutive
%points are sweeping in a clockwise or counterclockwise direction.

c=0;
cc=0;

for i=2:length(x)-1
    
    va =[x(i)-x(i-1) y(i)-y(i-1) 0];
    vb =[x(i+1)-x(i) y(i+1)-y(i) 0];
    vaCrossvb = cross(va,vb);
    
    if vaCrossvb(3)>0
        cc=cc+1;
    elseif vaCrossvb(3)<0
        c=c+1;
    end
end

if c>cc
    dir=1;
else
    dir=0;
end