%temp script for correcting spline files

filelist=dir('C:\Documents and Settings\Zhaowen Wang\Desktop\wormtracker\6-3-10 - fixed tail\*.txt');
calibx=3.6364;
caliby=3.6364;
labels=[{'%%Head'} {'%%Node 2'} {'%%3'} {'%%4'} {'%%5'} {'%%6'} {'%%7'} {'%%8'} {'%%9'} {'%%10'} {'%%11'} {'%%12'} {'%%Tail'}];

for i=1:length(filelist)
    currFile=['C:\Documents and Settings\Zhaowen Wang\Desktop\wormtracker\6-3-10 - fixed tail\' filelist(i).name];
    data=load(currFile);
    data=data*calibx;
    savePath=['C:\Documents and Settings\Zhaowen Wang\Desktop\wormtracker\6-3-10 - fixed tail\corrected spline files\' filelist(i).name];
    saveDataMatrix(labels,data,savePath);
end