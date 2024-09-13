function [cogs,xLocs,yLocs,areas]=findIslands(img)  %cogs is centroid of each island; xLocs/yLocs describe location of the island; area describes area of the island

backgroundColor=mode(mode(img));  %assumes background is predominant feature
foregroundColor=1-backgroundColor;  %assumes you have binary image

islands=[];
%Now scan along the x axis until you find your first foreground colored
%point
for y=1:length(img(:,1))
    for x=1:length(img(1,:))
        if img(x,y)==foregroundColor
            
        
        
        
    end
end
    
    









function adjacent=isAdjacent(x1,y1,x2,y2)
if ptDist(x1,y1,x2,y2)==1
    adjacent=1;
else
    adjacent=0;
end