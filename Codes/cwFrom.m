function cw=cwFrom(pt1,pt2,len)
if pt2>pt1 && pt2-pt1<len+pt1-pt2
    %pt2 is clockwise from pt1
    cw=1;
elseif pt2<pt1 && pt2+len-pt1<pt1-pt2
    %pt2 is clockwise from pt1
    cw=1;
elseif pt2<pt1 && pt1-pt2<pt2+len-pt1
    %pt2 is counterclockwise from pt1
    cw=0;
elseif pt2>pt1 && len-pt2+pt1<pt2-pt1
    %pt2 is counterclockwise from pt1   
    cw=0;
end
