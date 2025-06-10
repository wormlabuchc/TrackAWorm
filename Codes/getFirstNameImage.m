function firstName = getFirstNameImage(pathname)
%Check if folder exists
% if exist(pathname,'dir') ~=7
%     error('Folder not found')
% end
%List files in the folder
files= dir([pathname, filesep, '*.jpeg']);

%Check if there are any images in the folder
if isempty(files)
    error('No images found')
end
%Extract the name of the first image
firstName = files(1).name;
%fprintf('Name of the first image: %s\n', firstName);
end
