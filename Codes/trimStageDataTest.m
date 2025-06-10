function stageData = trimStageDataTest(stageData)

for i=1:length(stageData)
    row = stageData(i,:);
    row = abs(row);
    row = sum(row);
    if row == 0
        stageData = stageData(1:i-1,:);
        break
    end
end