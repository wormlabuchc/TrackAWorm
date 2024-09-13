function h=stimGraph(a,b,c)

lengths=[length(a) length(b) length(c)];

h=figure('Name','Protocol Overview','NumberTitle','off');
if length(a)~=length(b) || length(a)~=length(c) || length(b)~=length(c)
    
    maxLength=max(lengths);
    if length(a)<maxLength
        lengthDiff=maxLength-length(a);
        z=zeros(1,lengthDiff);
        a=[a num2str(z)];
        a=removeSpaces(a);
    end
    if length(b)<maxLength
        lengthDiff=maxLength-length(b);
        z=zeros(1,lengthDiff);
        b=[b num2str(z)];
        b=removeSpaces(b);
    end 
    if length(c)<maxLength
        lengthDiff=maxLength-length(c);
        z=zeros(1,lengthDiff);
        c=[c num2str(z)];
        c=removeSpaces(c);
    end 
        
end
x=0:length(a);

na=[];
nb=[];
nc=[];
lasta=0;
lastb=0;
lastc=0;
xa=[];
xb=[];
xc=[];

for i=x(1:end-1)
    aNum=str2double(a(i+1));
    if aNum~=lasta
        xa=[xa x(i+1) x(i+1)];
        na=[na lasta aNum];
    else
        xa=[xa x(i+1)];
        na=[na aNum];
    end
    lasta=aNum;
end
if lasta==1
    xa=[xa x(end) x(end)];
    na=[na 1 0];
else
    xa=[xa x(end)];
    na=[na 0];
end

for i=x(1:end-1)
    bNum=str2double(b(i+1));
    if bNum~=lastb
        xb=[xb x(i+1) x(i+1)];
        nb=[nb lastb bNum];
    else
        xb=[xb x(i+1)];
        nb=[nb bNum];
    end
    lastb=bNum;
end
if lastb==1
    xb=[xb x(end) x(end)];
    nb=[nb 1 0];
else
    xb=[xb x(end)];
    nb=[nb 0];
end

for i=x(1:end-1)
    cNum=str2double(c(i+1));
    if cNum~=lastc
        xc=[xc x(i+1) x(i+1)];
        nc=[nc lastc cNum];
    else
        xc=[xc x(i+1)];
        nc=[nc cNum];
    end
    lastc=cNum;
end
if lastc==1
    xc=[xc x(end) x(end)];
    nc=[nc 1 0];
else
    xc=[xc x(end)];
    nc=[nc 0];
end

subplot(3,1,1)
plot(xa,na,'LineWidth',2);
xlim([0 x(end)])
ylim([-.1 1.1])
set(gca,'YTick',[0 1]);
set(gca,'YTickLabel',[{'Off'};{'On'}]);
ylabel('Channel 1')
title({'Protocol Overview';''}, 'FontSize', 14)


subplot(3,1,2)
plot(xb,nb,'LineWidth',2);
xlim([0 x(end)])
ylim([-.1 1.1])
set(gca,'YTick',[0 1]);
set(gca,'YTickLabel',[{'Off'};{'On'}]);
ylabel('Channel 2')

subplot(3,1,3)
plot(xc,nc,'LineWidth',2);
xlim([0 x(end)])
ylim([-.1 1.1])
xlabel('Time(sec)')
set(gca,'YTick',[0 1]);
set(gca,'YTickLabel',[{'Off'};{'On'}]);
ylabel('Channel 3')

function strOut=removeSpaces(str)
strOut=[];
L=length(str);
for i=1:L
    if ~isspace(str(i))
        strOut=[strOut str(i)];
    end
end
