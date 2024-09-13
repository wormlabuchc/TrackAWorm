function newSeq = processSequence(seq,repeat,rectime)

% FUNCTION GENERATES A BINARY SEQUENCE OF LENGTH EQUAL TO RECTIME BASED
% UPON A SEQUENCE OF FORMAT: [DURATION*VALUE(0/1),....], OR IS ALREADY
% FORMATTED, AND A NUMBER OF TIMES TO REPEAT THE SEQUENCE

if nargin==2
    rectime=[];
end

% REMOVE SPACES
seq = seq(seq~=' ');   

% IF SEQUENCE IS THE DURATION/VALUE FORMAT
if contains(seq,'*')
    
    seqSegments = strsplit(seq,',');
    newSeq = [];
    
    for i=1:length(seqSegments)
        
        currSegment = seqSegments{i};
        components = strsplit(currSegment,'*');
        components = [{str2double(components{1})} components(2)];
        
        for j=1:components{1}
            newSeq=strcat(newSeq,components{2});
        end
        
    end
    
% ELSE THE SEQUENCE IS ALREADY FORMATTED
else
    
    newSeq = seq;
    
end

% REPEAT repeat TIMES
newSeq = repmat(newSeq,1,repeat);

% PAD newSeq IF SHORTER THAN RECTIME, ELSE TRIM IT TO SIZE OF RECTIME
if ~isempty(rectime) && rectime>length(newSeq)
    
    newSeq = pad(newSeq,rectime,'0');
    
elseif ~isempty(rectime) && rectime<length(newSeq)
    
    newSeq = newSeq(1:rectime);
    
end