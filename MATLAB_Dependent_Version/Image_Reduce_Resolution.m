% Define the image folder
imageFolder = 'C:\Recordings\wt_100percent_04';

% Get list of only .jpeg files (ignoring .txt and others)
imageFiles = dir(fullfile(imageFolder, '*.jpeg'));

% Loop through each image file
for k = 1:length(imageFiles)
    % Full path to the image
    fullImagePath = fullfile(imageFolder, imageFiles(k).name);
    
    % Read and resize
    img = imread(fullImagePath);
    img_resized = imresize(img, 0.5);  % Reduce resolution by half
    
    % Overwrite the original image with the resized version
    imwrite(img_resized, fullImagePath);
end

disp('All .jpeg images have been resized by half and overwritten.');
