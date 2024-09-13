ht=get(handles.winOrig,'PlotBoxAspectRatio'); ht=ht(2);
xlow=min(xcl(end,:))*.9;
xhigh=max(xcl(end,:))*1.1;
ylow=min(ycl(end,:))*.9;
yhigh=max(ycl(end,:))*1.1;
axes(handles.winContrast);
xlim([xlow xhigh]); ylim([ht-yhigh ht-ylow]);