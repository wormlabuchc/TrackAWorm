function cross=crosses(x,y,x2,y2)
try
    if nargin==2
        [X0,Y0] = intersections(x,y,0);
    elseif nargin==4
        [X0,Y0,I,J] = intersections(x,y,x2,y2,0);
    end
    if ~isempty(X0)
        cross=1;
    else
        cross=0;
    end
catch
    cross=0;
end
