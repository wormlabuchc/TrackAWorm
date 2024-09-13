function fixNumbers(imagePath)

comp=computer; 
if ~strcmp(comp,'PCWIN64') && ~strcmp(comp,'PCWIN32')
    slash='/';
else
    slash='\';
end

list=dir([imagePath slash '*.jpeg']);
filelist=[];
filelistFull=[];
lengths=[];
for i=1:size(list)
    filelistFull=[filelistFull; {[imagePath slash list(i).name]}];
    filelist=[filelist; {list(i).name}];
    name=list(i).name;
    sname=size(name);
    len=sname(2);
    lengths=[lengths len];
end

maxLength=max(lengths);
if mean(lengths)==maxLength
    disp('Lengths are correct');
else
    button = questdlg('File lengths do not agree.  Usually this is caused by very long recordings (>9999 frames)  Fix filenames?');
    if strcmp(button,'Yes')
        for i=1:size(filelist,1)
            filename=filelist{i};
            nameLength=size(filename,2);
            if nameLength<maxLength
                lengthDiff=maxLength-nameLength;
                extraZeros=[];
                for j=1:lengthDiff
                    extraZeros=[extraZeros '0'];
                end

                pos=findstr(filename,'img');
                newName=[filename(1:pos+2) extraZeros filename(pos+3:end)];
                newNameFull=[imagePath slash newName];
                oldNameFull=filelistFull{i};
                movefile(oldNameFull,newNameFull);
            end
        end
        disp('Filenames fixed.')
    end
end




