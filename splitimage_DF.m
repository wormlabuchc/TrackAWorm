
function [cog] = splitimage_DF(image)
%im = 'C:\Anusha\Worm dark field imaging\5R.tif';
rgbImage = image;
[rows, columns, numberOfColorChannels] = size(rgbImage);
if numberOfColorChannels > 1
	grayImage = rgb2gray(rgbImage); % Take green channel.
else
	grayImage = rgbImage; % It's already gray scale.
end
binaryImage = false(rows, columns);
bim = imbinarize(grayImage,.4);
binaryImage(1:rows, round(columns/2):columns) = bim(1:rows,round(columns/2):columns);
grayImage(~binaryImage) = 0;
props = regionprops(binaryImage, grayImage, 'WeightedCentroid');
if ~isempty(props)
    cog = props.WeightedCentroid;
else
    cog = [1536, 1024];
end
