function [xFitMat,yFitMat] = getQuadAssumption(xComp,yComp,times)

idx = all(isnan(xComp),2);
idr = diff(find([1;diff(idx);1]));

xFrameGroups = mat2cell(xComp,idr(:),size(xComp,2));
yFrameGroups = mat2cell(yComp,idr(:),size(yComp,2));

times = mat2cell(times,idr(:),size(times,2));

xPolyFit = cell([length(xFrameGroups) length(xComp(:,1))]);
yPolyFit = cell([length(yFrameGroups) length(yComp(:,1))]);

xPolyFit = {}; yPolyFit = {};

for i=1:length(xFrameGroups)
    x = xFrameGroups{i};
    y = yFrameGroups{i};
    t = times{i};
    for j=1:length(xComp(i,:))
        if ~isnan(cell2mat(xFrameGroups(i,1)))
            xPolyFit{i,j} = polyfit(t,x(:,j),2);
            yPolyFit{i,j} = polyfit(t,y(:,j),2);
        end
    end
end

xFit = cell(size(xFrameGroups)); yFit = cell(size(yFrameGroups));

for i=1:length(xFrameGroups)
    t = times{i};
    for j=1:length(xComp(i,:))
        if ~isnan(cell2mat(xFrameGroups(i,1)))
            xValues = []; yValues = [];
            findQuadraticValues
            xFit{i,j} = xValues;
            yFit{i,j} = yValues;
        else
            xFit{i,j} = NaN([size(xFrameGroups{i,1},1) 1]);
            yFit{i,j} = NaN([size(yFrameGroups{i,1},1) 1]);
        end
    end
end

xFitMat = []; yFitMat = [];

for i=1:length(xFit(:,1))
    tempMatX = []; tempMatY = [];
    for j=1:length(xFit(i,:));
        tempMatX = [tempMatX, cell2mat(xFit(i,j))];
        tempMatY = [tempMatY, cell2mat(yFit(i,j))];
    end
    xFitMat = [xFitMat; tempMatX];
    yFitMat = [yFitMat; tempMatY];
end

    function findQuadraticValues
        xCoeff = xPolyFit{i,j};
        yCoeff = yPolyFit{i,j};
        xValues = t.^2 * xCoeff(1);
        xValues = xValues + t * xCoeff(2) + xCoeff(3);
        yValues = t.^2 * yCoeff(1);
        yValues = yValues + t * yCoeff(2) + yCoeff(3);
    end

end