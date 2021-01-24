function [P, logZ] = JunctionTreeCalibrate(P, isMax)

    % Cliques in tree
    N = length(P.cliqueList);

    if (nargout > 1)
        unnormalizedMessages = repmat(struct('var', [], 'card', [], 'val', []), N, N);
        doLogZ = true;
    else
        doLogZ = false;
    end

    % Storing Messages passed as Factors representation
    messages = repmat(struct('var', [], 'card', [], 'val', []), N, N);

    if isMax == 1                            % Max-Sum Algorithm, Convert factors to log space
        for i = 1 : length(P.cliqueList)
            P.cliqueList(i).val = log(P.cliqueList(i).val);
        end
    end

    % These will make sure that the same message is not passed twice in a row
    lastCliqueOne = 0;
    lastCliqueTwo = 0;

    while (1)
        % Find the clique that is ready, compute the message for that clique,
        % and add that message to the queue
        [cliqueOne, cliqueTwo] = GetNextCliques(P, messages);
        if (cliqueOne == 0) || (cliqueTwo == 0)
            % There are no ready cliques, so stop
            break
        end
        if (lastCliqueOne == cliqueOne) && (lastCliqueTwo == cliqueTwo)
            % Do not pass the same message twice in a row, so stop
            break
        end
        lastCliqueOne = cliqueOne;
        lastCliqueTwo = cliqueTwo;
        
        currentMessage = P.cliqueList(cliqueOne);
        
        if (doLogZ)
            currentUnnormalizedMessage = P.cliqueList(cliqueOne);
        end
        
        for i = 1:N
            % Iterate through edges and compute the outgoing message
            if i == cliqueTwo
                % Do not consider this edge
                continue
            end
            
            if isMax == 0 % Perform sum product message passing
                currentMessage = FactorProduct(currentMessage, messages(i, cliqueOne)); 
                % Return currentMessage for first iteration since messages empty
                if (doLogZ)
                    currentUnnormalizedMessage = FactorProduct(currentUnnormalizedMessage, unnormalizedMessages(i, cliqueOne));
                end 
                
            else
                % Compute the sum because doing max-sum message passing
                currentMessage = FactorSum(currentMessage, messages(i, cliqueOne));
            end            
        end
        
        to_marginalize_out = setdiff(P.cliqueList(cliqueOne).var, P.cliqueList(cliqueTwo).var);
        if isMax == 0 % Doing sum-product
            messages(cliqueOne,cliqueTwo) = FactorMarginalization(currentMessage, to_marginalize_out);
            messages(cliqueOne,cliqueTwo).val = messages(cliqueOne,cliqueTwo).val/sum(messages(cliqueOne,cliqueTwo).val);
            if (doLogZ)
                unnormalizedMessages(cliqueOne, cliqueTwo) = FactorMarginalization(currentUnnormalizedMessage, to_marginalize_out);
            end
            
        else % Use FactorMaxMarginalization to get the marginals
            messages(cliqueOne,cliqueTwo) = FactorMaxMarginalization(currentMessage, to_marginalize_out);
        end
    end

% Compute the product of any two messages in the opposite direction over
% conencted edge. Take the resulting factor and the sum the entries. Proof
% in the report
    if (doLogZ)
        logZ = 0;
        for i = 1:N
            for j = 1:N
                if P.edges(i,j) == 1
                    break;
                end
            end
        end
        
        final = unnormalizedMessages(i, j);
        
        for ii = 1:N
            for jj = 1:N
                if P.edges(ii,jj) == 1
                    if ii == i && jj == j
                        
                    else                      
                        final = FactorProduct(final, unnormalizedMessages(ii,jj));
                    end
                end
            end
        end
        
        logZ = log(sum(final.val));
    else
        
        logZ = 0;
    end

    % Iterate through the incoming messages, multiply them by the initial potential, and normalize
    for i = 1:N
        for j = 1:N
            if isMax == 0   % Compute the factor product
                P.cliqueList(i) = FactorProduct(P.cliqueList(i), messages(j,i));
            else
                 % Compute the factor sum 
                P.cliqueList(i) = FactorSum(P.cliqueList(i), messages(j,i));
            end
        end
    end
end