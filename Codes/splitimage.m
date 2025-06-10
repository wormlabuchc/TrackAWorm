function [xy] = splitimage(image)
rgbImage = image;
[rows, columns, numberOfColorChannels] = size(rgbImage);
if numberOfColorChannels > 1
    grayImage = rgb2gray(rgbImage); % Take green channel.
else
    grayImage = rgbImage; % It's already gray scale.
end
binaryImage = false(rows, columns);
bim = imbinarize(grayImage,.40);
binaryImage(1:rows, round(columns/2):columns) = bim(1:rows,round(columns/2):columns);
grayImage(~binaryImage) = 0;
x = 1 - binaryImage;
x(1:rows, 1:round(columns/2)) = false;
y = logical(x);
imc = imcomplement(grayImage);
props = regionprops(y, imc, 'WeightedCentroid');
xy = props.WeightedCentroid;
disp(xy);