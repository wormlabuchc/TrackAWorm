imagefiles=dir('*.jpeg');
N_images=length(imagefiles);
for i=1:N_images
    currentfilename = imagefiles(i).name;
   currentimage = imread(currentfilename);
end
h=struct;
h.f=figure;
h.ax=axes('Parent',h.f,...
    'Units','Normalized');
h.slider=uicontrol('Parent',h.f,...
    'Units','Normalized',...
    'Position',[0.8 0.1 0.1 0.8],...
    'Style','Slider',...
    'BackgroundColor',[1 1 1],...
    'Min',1,'Max',N_images,'Value',1,...
    'Callback',@sliderCallback);

%store image database to the guidata struct as well
h.images=imagefiles;
guidata(h.f,h)

%trigger a callback
sliderCallback(h.slider)

function sliderCallback(hObject,eventdata)
h=guidata(hObject);
count=round(get(hObject,'Value'));
% IM=h.database(:,:,1:count);
% IM=permute(IM,[1 2 4 3]);%montage needs the 3rd dim to be the color channel
imshow(currentImage,'Parent',handles.win);
end