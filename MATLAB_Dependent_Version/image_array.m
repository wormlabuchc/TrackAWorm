% a=imread('R_img00001.jpeg');
% b=imread('R_img00002.jpeg');
% c=imread('R_img00003.jpeg');

imagefiles = dir('*.jpeg'); 
class(imagefiles)
nfiles = length(imagefiles); 
database=[];
for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   database(:,:,ii) = currentimage;
end
class(database)
%database = database(:,:,2:7);
N_images=size(database,3);
low = min(min(min(database)))
high = max(max(max(database)))

%imshow(database(:,:,5),[low,high])


h=struct;
h.f=figure;
h.ax=axes('Parent',h.f,...
    'Units','Normalized',...
    'Position',[0.1 0.1 0.6 0.8]);
h.slider=uicontrol('Parent',h.f,...
    'Units','Normalized',...
    'Position',[0.8 0.1 0.1 0.8],...
    'Style','Slider',...
    'BackgroundColor',[1 1 1],...
    'Min',1,'Max',N_images,'Value',1,...
    'Callback',@sliderCallback);
%store image database to the guidata struct as well
h.database=database;
guidata(handles.win,h)
%trigger a callback
sliderCallback(h.slider)

function sliderCallback(hObject,eventdata,handles)
h=guidata(hObject);
count=round(get(hObject,'Value'))
low = min(min(min(h.database)));
high = max(max(max(h.database)));
current=h.database(:,:,count);
%montage(current,'Parent',h.ax);
imshow(current,[low,high],'Parent',h.ax);
end

