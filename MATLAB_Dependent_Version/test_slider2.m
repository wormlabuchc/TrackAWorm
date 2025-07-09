imagefiles=dir('*.jpeg');
N_images=length(imagefiles);
for i=1:N_images
    currentfilename = imagefiles(i).name;
   currentimage = imread(currentfilename);
end


%Load an example image
% a=imread('cameraman.tif');
% %Replicate 100 times
% database=repmat(a,1,1,4);
% N_images=size(database,3);
%prepare figure and guidata struct
% h=struct;
% h.f=figure;
% h.ax=axes('Parent',h.f,...
%     'Units','Normalized',...
%     'Position',[0.1 0.1 0.6 0.8]);
% h.slider=uicontrol('Parent',h.f,...
%     'Units','Normalized',...
%     'Position',[0.8 0.1 0.1 0.8],...
%     'Style','Slider',...
%     'BackgroundColor',[1 1 1],...
%     'Min',1,'Max',N_images,'Value',1,...
%     'Callback',@sliderCallback);
% %store image database to the guidata struct as well
% h.images=currentimage;
% size(h.images)
% guidata(h.f,h)
% % %trigger a callback
% % sliderCallback(h.slider)
% % function sliderCallback(hObject,eventdata)
% % h=guidata(hObject);
% % count=round(get(hObject,'Value'));
% % IM=h.images(:,:,1:count);
% % 
% % end
