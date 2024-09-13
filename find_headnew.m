function [imgcon,headpt] = find_head(rawimg)
    img = imgTransform(rawimg);
    C = contourc(double(img),1);
    [imy,imx] = size(rawimg);
    [cont_1,headpt] = convertcontour(C,imx,imy);
    imgcon.x = cont_1(1,:);
    imgcon.y = cont_1(2,:);
end
function [outputArg, trackpt] = convertcontour(contarray, imx,imy)
% to convert the output of contourc to contour line array;
%   Detailed explanation goes here
    lineCol = contarray(2,1);
    contarray = contarray(:,2:lineCol+1);
    lineVector = zeros(2,lineCol); % create the line vector
    [minX,minXInd] = min(contarray(1,:));
    [maxX,maxXInd] = max(contarray(1,:));
    [minY,minYInd] = min(contarray(2,:));
    [maxY,maxYInd] = max(contarray(2,:));
    if 0==minX
        lineVector(:,1)= contarray(:,minXInd);
    elseif 0==minY
        lineVector(:,1)= contarray(:,minYInd);
    elseif maxX==imx
        lineVector(:,1)= contarray(:,maxXInd);
    elseif maxY==imy
        lineVector(:,1)= contarray(:,maxYInd);
    else
    end
    i=1;
    while i<lineCol 
    difVector = contarray(:,1+i) - lineVector(:,i);
    [~,disInd] = min(sqrt(sum(difVector.^2)));
    lineVector(:,i+1) = contarray(:,disInd+i); 
    i = i+1;
    end
    outputArg = lineVector;
   lineVector = imresize(lineVector,[2,lineCol/4]);
    lineout = lineVector;
    diffx =  diff(lineout(1,:));
    diffy = diff(lineout(2,:));
   disarray =sqrt( diffx.^2+ diffy.^2);
   curvaturVal = abs(diff((diffy./disarray)));
   peakloc = find(curvaturVal>0.5,10);
   trackpt = lineVector(:,peakloc(8));
%    dx = 1:size(curvaturVal,2);
%    plot(dx,curvaturVal,'-');

end
function imgf = imgTransform(rawimg)
        img = imadjust(rawimg);
        img = imcomplement(img);
        img = imfill(img,8,'holes');
        img = imgaussfilt(img,1);
        img = imbinarize(img);
        imgf = bwareafilt(img,1);
end