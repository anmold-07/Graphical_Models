function [i, j] = GetNextCliques(P, messages)

ready = 0;

for i = 1:size(P.edges, 1)
    for j = 1:size(P.edges, 2)
        
        
        if P.edges(i,j) == 0  % No edge between cliques 
            continue
        end
        
        if (~isempty(messages(i,j).var)) % message already sent
            continue
        end
        
        messageIndexes = setdiff(find(P.edges(:, i) == 1), j);
        emptyFound = 0;
        
        for k = 1:length(messageIndexes)
            % Iterate through other incoming edges
            if isempty(messages(messageIndexes(k), i).var)
                % Not ready
                emptyFound = 1;
                break
            end
        end
        
        if emptyFound == 0
            % All necessary messages have been sent
            ready = 1;
            return;
        end
        
    end
end

i = 0;
j = 0;

return
