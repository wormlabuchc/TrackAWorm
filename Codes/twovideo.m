% load the images

images     = cell(450,1);

for i = 1:450

 

    filename = "C:\Users\vedantham\Documents\Wormtracker_data\Sample recordings\wt_3\R_img" + sprintf('%05d',i) + ".jpeg";

    img = imread(filename);

    img= cat(3,img,img,img);

    img = insertText(img,[10 10],'wt_D2');

   

 

    filename2 = "C:\Users\vedantham\Documents\Wormtracker_data\Sample recordings\wt_2\L_img" + sprintf('%05d',i) + ".jpeg";

    img2 = imread(filename2);

    img2 = cat(3,img2,img2,img2);

    img2 = insertText(img2,[10 10],'ty11_D2');

    images{i} =[img;img2];

end

 

% create the video writer

 writerobj = VideoWriter('C:\Users\vedantham\Documents\Wormtracker_data\Sample recordings\sample.avi','Motion JPEG AVI');

writerobj.FrameRate =15;

open(writerobj);

 

%wirte the frames to the video

for u = 1:450

    %convert the image to a frame

    frame = im2frame(images{u});

    writeVideo(writerobj,frame);

end

close(writerobj)