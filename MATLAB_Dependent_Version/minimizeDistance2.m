function [closestx,closesty,pointNum]=minimizeDistance2(vector,xSeq,ySeq,x0,y0)
vector=vector/norm(vector);
angle=zeros(1,length(xSeq));
for i=1:length(xSeq)
    dx=xSeq(i)-x0;
    dy=ySeq(i)-y0;
    vect=[dx dy]/norm([dx dy]);
    dotprod=dot(vector,vect);
    ang=acos(dotprod);
    ang=ang/pi*180;
    angle(i)=ang;
end
% figure;plot(angle);






[MAX,MIN]=peakdet(angle,5);
if isempty(MIN)
    disp('uhoh')
end
if mean(MIN(:,2)<10==MIN(:,2))==1 && length(MIN(:,2))~=1
    indices=MIN(:,1);
    dist=zeros(1:length(indices));
    for i=1:length(dist)
        d=norm([xSeq(indices(i))-x0 ySeq(indices(i))-y0]);
        dist(i)=d;
    end
    indNum=find(dist==min(dist));
else
    indNum=find(MIN(:,2)==min(MIN(:,2)));
end
pointNum=MIN(indNum,1);

closestx=xSeq(pointNum);
closesty=ySeq(pointNum);