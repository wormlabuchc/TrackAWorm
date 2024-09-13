function filelist = listJpegsInFolder(path)

% Generates a cell array of *.bmp's in path

comp=computer;
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end

list = dir([path slash '*.jpeg']);
filelist = cell([length(list) 1]);

for i=1:length(list)
    filelist{i} = [path slash list(i).name];
end