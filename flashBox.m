function flashBox(varargin)

% THIS FUNTION ACCEPTS COLORS AND HANDLES TO FLASH, IN THE SYNTAX:
% flashBox('color1',handles11,..handles1n,...'colorn',handlesn1,....handlesnn');

% FIND INDICES OF COLOR ARGUMENTS
indsOfColors = cellfun(@ischar,varargin);
indsOfColors = find(indsOfColors);

% FIND START AND ENDPOINTS THAT CONTAIN INDICES OF GROUPS OF HANDLES
indsHandlesSeq = [(indsOfColors(1:end)+1)',[indsOfColors(2:end)-1,nargin]'];

% FOR EACH COLOR ELEMENT, SET FOLLOWING HANDLE GROUPS' COLOR
for i=1:length(indsOfColors)
    
    for j=indsHandlesSeq(i,1):indsHandlesSeq(i,2)
        
        set(varargin{j},'BackgroundColor',varargin{indsOfColors(i)})
        
    end
    
end

pause(.25);

% RESET ALL HANDLES IN EACH GROUP TO WHITE
for i=1:length(indsOfColors)
    
    for j=indsHandlesSeq(i,1):indsHandlesSeq(i,2)
        
        set(varargin{j},'BackgroundColor','w')
        
    end
    
end