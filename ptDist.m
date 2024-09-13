function d=ptDist(x1,y1,x2,y2)
try
d=sqrt((x1-x2)^2+(y1-y2)^2);
catch
    disp('stopped')
    d=0;
end