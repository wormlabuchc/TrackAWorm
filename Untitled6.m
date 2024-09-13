function GaussianSlider()
clear
clc
close all
handles.Image = imread('peppers.png');
handles.fig = figure;
handles.axes1 = axes('Units','pixels','Position',[50 100 400 400]);
handles.slider = uicontrol('Style','slider','Position',[50 50 400 20],'Min',3,'Max',15,'Value',3);
handles.Listener = addlistener(handles.slider,'Value','PostSet',@(s,e) gaussian_blur(handles));
imshow(handles.Image,'Parent',handles.axes1);
guidata(handles.fig);
    function gaussian_blur(handles)
        slider_value = round(get(handles.slider,'Value'));
        h = fspecial('gaussian',slider_value,slider_value);
        handles.Image=imfilter(handles.Image,h,'conv');
        axes(handles.axes1);
        imshow(handles.Image)
    end
end
