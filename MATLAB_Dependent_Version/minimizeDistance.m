function [closestx,closesty,pointNum]=minimizeDistance(vector,x,y,x1,y1)   %use projection to find smallest point
a=[x-x1; y-y1];
b=vector;
proj=[];
lengthVectorProj=zeros(1,length(x));
perpendicularDist=zeros(1,length(x));
for i=1:length(x)
    p=dot(a(:,i),b)*b;    %vector projection of a on b
    lp=sqrt(p(1)^2+p(2)^2); %length of the vector projection
    lengtha=sqrt(a(1,i)^2+a(2,i)^2);
    pd=sqrt(lengtha^2-lp^2); %length of the perpendicular distance
    lengthVectorProj(i)=lp;
    perpendicularDist(i)=pd;
end




perpendicularDist=real(perpendicularDist);

[MAXTAB, MINTAB] = peakdet(perpendicularDist, 0.1);
if isempty(MINTAB)
    lowestPoint=length(x);
else
    lp=find(MINTAB(:,2)==min(MINTAB(:,2)));
    lowestPoint=MINTAB(lp,1);
    
end



% cp=find(perpendicularDist<1);   %candidate points
% cp=findMins(cp,perpendicularDist);
% lowestPoint=find(lengthVectorProj(cp)==min(lengthVectorProj(cp)));
% lowestPoint=cp(lowestPoint);
closestx=x(lowestPoint); 
closesty=y(lowestPoint);
pointNum=lowestPoint;

function cp=findMins(cp,perpDist)
temp=[];
cp=[cp(1) cp];
cpnew=[];
lcp=length(cp);
for i=2:lcp
    if cp(i)-cp(i-1)<2
        temp=[temp cp(i)];
    else
        minimum=find(perpDist(temp)==min(perpDist(temp)));
        minimum=temp(minimum);
        minimum=minimum(1);
        cpnew=[cpnew minimum];
        temp=cp(i);
    end
end
minimum=find(perpDist==min(perpDist(temp)));
cpnew=[cpnew minimum];
cpnew=unique(cpnew);    %I'm not sure why this is necessary.  Clearly there is some bug in the code
cp=cpnew;   %cp contains locations where perpDist is a minimum

