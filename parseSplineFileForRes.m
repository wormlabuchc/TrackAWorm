function res = parseSplineFileForRes(splineFile)
comp = computer;
    if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
        slash = '/';
    else
        slash = '\';
    end

splineData = importdata(splineFile);
splineData=splineData.data;

dataFields = length(splineData(1,:));


switch dataFields
  
%     OLDER VERSION WITHOUT RESOLUTION
    case 28
        [path,name,~]=fileparts(splineFile);
        name = strrep(name,'_spline','');
        newPath=fullfile(path,name);
        %Get the name of the first image in the folder
        firstImage = getFirstNameImage(newPath);
        imagePath = [newPath slash firstImage];

        %Get image information
        imageInfo = imfinfo(imagePath);

        %Extract height and width information
        width = imageInfo.Width;
        height = imageInfo.Height;
        res = [width height];
        % prompt = {'Enter vertical resolution in px:','Enter horizontal resolution in px:'};
        % title = 'No resolution detected';
        % dims = [1 70];
        % definput = {'384','512'};
        % 
        % answer = inputdlg(prompt,title,dims,definput);
        % 
        % res = [str2double(answer{1}),str2double(answer{2})];
        
%     NEW VERSION WITH RESOLUTION
    case 29
        
        res = splineData(:,29:29);
        res = fliplr(res(1:2,1)');
        
end