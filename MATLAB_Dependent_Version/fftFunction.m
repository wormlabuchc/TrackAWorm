function [freq,time,selectedBendAngles] = fftFunction(filename,selectedBend,fs,framesToAnalyze,doPlot)

if nargin==4
    doPlot=0;
end

[~,~,splineData,~] = parseSplineFile(filename);

x = splineData(1:2:end,:); y = splineData(2:2:end,:);

if ~strcmp(framesToAnalyze,'all')
    x = x(framesToAnalyze(1):framesToAnalyze(2),:);
    y = y(framesToAnalyze(1):framesToAnalyze(2),:);
end

wormBendAngles = NaN([size(x,1) 11]);

for i=1:size(x,1)
    frameAngles = findWormAngles(x(i,:),y(i,:));
    wormBendAngles(i,:) = frameAngles;
end

selectedBendAngles = wormBendAngles(:,selectedBend);

H = abs(fft(selectedBendAngles)/length(selectedBendAngles));

df = fs/(length(H)-1);
f = 0:df:fs;

if doPlot
    axes(figure);
    plot(f(1:floor(end/2)),abs(H(1:floor(end/2))))
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    title('Frequency spectrum')
end

time = (0:length(selectedBendAngles)-1)/fs;

lowerLim = find(f>0.1);
lowerLim = lowerLim(1);

H(1:lowerLim) = 0;
halfH = H(1:round(end/2));
peakPower = max(halfH);
freq = f(halfH==peakPower);
time = time(1:length(selectedBendAngles));

