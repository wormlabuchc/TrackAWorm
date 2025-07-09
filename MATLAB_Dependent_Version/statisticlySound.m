function isTrue = statisticlySound(xclOrig,yclOrig,prevX,prevY,margin)
splineDifferenceX = xclOrig - prevX;
splineDifferenceY = yclOrig - prevY;

percentDifferenceX = splineDifferenceX ./ xclOrig;
percentDifferenceY = splineDifferenceY ./ yclOrig;

percentDifferenceX = abs(percentDifferenceX);
percentDifferenceY = abs(percentDifferenceY);

isTrue = ~([(percentDifferenceX>.margin) (percentDifferenceY>.margin)]);

isTrue = mean(isTrue);