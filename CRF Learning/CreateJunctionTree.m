function P = CreateJunctionTree(F)

C.nodes = {};
V = unique([F(:).var]);          % Total number of random variables Y_{i}
C.card = 26*ones(1, length(V));

C.factorList = F;

% Setting up the adjaceny matrix.
edges = zeros(length(V));

for i = 1:length(F)
    for j = 1:length(F(i).var)
        for k = 1:length(F(i).var)
            edges(F(i).var(j), F(i).var(k)) = 1;
        end
    end
end

cliquesConsidered = 0;

while cliquesConsidered < length(V)
    % Using Min-Neighbors where you prefer to eliminate the variable that has
    % the smallest number of edges connected to it. 
    % Everytime you enter the loop, you look at the state of the graph and 
    % pick the variable to be eliminated.    
    bestClique = 0;
    bestScore = inf;
    for i=1:size(edges,1)
        score = sum(edges(i,:));
        if score > 0 && score < bestScore
            bestScore = score;
            bestClique = i;
        end
    end

    cliquesConsidered = cliquesConsidered + 1;
    [F, C, edges] = EliminateVar(F, C, edges, bestClique);
end

% Setting the adjacency matrix for the resultant Junction tree
C.nodes(length(V)) = [];
edges = zeros(length(C.nodes), length(C.nodes));
for dummy_iter = 1:length(C.nodes)-1  
    indices = cell2mat(C.nodes(1, dummy_iter));
    edges(indices(1), indices(2)) = 1;
    edges(indices(2), indices(1)) = 1;
end
C.edges  = edges;

N = length(C.nodes);
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);

assignments = zeros(length(C.factorList), 1);
for i = 1:length(C.factorList)
    % Assign each factor to a clique
    for j = 1:N
        % Iterate through nodes until a node with all of the variables in
        % the clique has been found
        if isempty(setdiff(C.factorList(i).var, C.nodes{j}))
            % A clique with the variables has been indentified
            assignments(i) = j;
            break
        end
    end
end

% Determine the cardinaliteis for each node in the clique that will be
% created
cardinalities = zeros(1, length(unique([C.factorList(:).var])));
for i = 1:length(cardinalities)
    % Iterate through variables
    for j = 1:length(C.factorList)
        % Iterate through factors
        if ~isempty(find(C.factorList(j).var == i))
            % If the current variable is in the factor, find its
            % cardinality
            cardinalities(i) = C.factorList(j).card(find(C.factorList(j).var == i));
            break;
        end
    end
end

for i = 1:N
    % Iterate through nodes and put each node into the clique list
    P.cliqueList(i).var = C.nodes{i};
    P.cliqueList(i).card = cardinalities(C.nodes{i});
    P.cliqueList(i).val = ones(1, prod(P.cliqueList(i).card));
end

for i = 1:length(assignments)
    % Iterate through assignments and multiply the appropriate factors
    % in to the clique
    P.cliqueList(assignments(i)) = FactorProduct(P.cliqueList(assignments(i)), C.factorList(i));
end

P.edges = C.edges;