function length = pathLength(x,y)

xDist = diff(x);
yDist = diff(y);
xyDist = ((xDist.^2) + (yDist.^2)).^(1/2);
length = sum(xyDist);