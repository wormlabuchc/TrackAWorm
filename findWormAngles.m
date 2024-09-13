function angles = findWormAngles(x,y)

angles = NaN([1 11]);

for i = 2:12

    a = ptDist(x(i-1),y(i-1),x(i),y(i));
    b = ptDist(x(i+1),y(i+1),x(i),y(i));
    c = ptDist(x(i+1),y(i+1),x(i-1),y(i-1));

    angleC = acos((a^2+b^2-c^2)/2/a/b);
    angleC = angleC*180/pi;
    angleC = 180-angleC;

    va = [x(i-1)-x(i) y(i-1)-y(i) 0];
    vb = [x(i+1)-x(i) y(i+1)-y(i) 0];
    
    aCrossb = cross(va,vb);
    
    if aCrossb(3)<0
        angleC = -angleC;
    end

    angles(i-1) = angleC;
    
end