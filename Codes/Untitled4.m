%Load an example image
a=imread('cameraman.tif');
%Replicate 100 times
database=repmat(a,1,1,100);
N_images=size(database,3);
%prepare figure and guidata struct
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
guidata(h.f,h)
%trigger a callback
sliderCallback(h.slider)
function sliderCallback(hObject,eventdata)
h=guidata(hObject);
count=round(get(hObject,'Value'));
IM=h.database(:,:,1:count);
IM=permute(IM,[1 2 4 3]);%montage needs the 3rd dim to be the color channel
montage(IM,'Parent',h.ax);
end