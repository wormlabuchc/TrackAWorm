%cursorscript
angles=[];
for i=1:length(cursor_info)
    a=cursor_info(i).Position(2);
    angles=[angles a];
end
posAngles=angles(angles>0);
negAngles=angles(angles<0);
excursion=mean(posAngles)-mean(negAngles)