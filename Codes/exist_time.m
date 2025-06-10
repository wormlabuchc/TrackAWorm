function isFieldResult = exist_time (timesData, reducedframerate)
% inStruct is the name of the structure or an array of structures to search
% fieldName is the name of the field for which the function searches
isFieldResult = 0;
f = fieldnames(timesData);
for i=1:length(f)
if(strcmp(f{i},strtrim(reducedframerate)))
isFieldResult = 1;
return;
elseif isstruct(timesData.(f{i}))
isFieldResult = exist_time(timesData.(f{i}), reducedframerate);
if isFieldResult
return;
end
end
end