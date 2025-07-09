%oscillationscript
[x,y]=plotWormPath(filename,1:13);
close(gcf)
bend=[];
for i=1:length(x(:,1));
    bends=wormBends2(x(i,:),y(i,:));
    bend=[bend;bends];
end
% theta=bend(:,seg);
theta=bend;
oscillations=0;
dt=1/fs;
for i=2:length(theta);
    d=(theta(i)-theta(i-1))/dt;
    if i~=2;
        if lastD*d<0    %if there is a sign change
            oscillations=oscillations+1;
        end
    end
    lastD=d;
end
totalTime=length(theta)*dt;
oscillationsPerSec=oscillations/totalTime;
disp(oscillationsPerSec);
        
