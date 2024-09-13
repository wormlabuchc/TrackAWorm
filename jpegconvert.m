file = 'C:\Users\anagella\Dropbox\New Recordings\test4';
srcFiles = dir(strcat (file, '\*.bmp'));
for i = 1:450
    filename = strcat(file, '\', srcFiles(i).name);
    x = imread(filename);
    d = pad(num2str(i),5,'left','0');
    imwrite(x, strcat('C:\Users\anagella\Desktop\test4\img', d, '.jpeg'))
end