function [ind,dist]=findClosestPoint(xi,yi,x,y)
d=zeros(1,length(x));
for i=1:length(x)
    d(i)=ptDist(xi,yi,x(i),y(i));
end
ind=find(d==min(d));
dist=d(ind);