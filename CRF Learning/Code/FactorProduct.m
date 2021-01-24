
function C = FactorProduct(A, B)

% Check for empty factors
if (isempty(A.var)), C = B; return; end
if (isempty(B.var)), C = A; return; end

% Check that variables in both A and B have the same cardinality
[dummy, iA, iB] = intersect(A.var, B.var);                                       % Returns the variable dummy contaning INTERSECTION in order, 
if ~isempty(dummy)                                                               % not empty
	% A and B have at least 1 variable in common
	assert(all(A.card(iA) == B.card(iB)), 'mismatch'); % Cardinalty of respective inteseted variables
end

C.var = union(A.var, B.var);                                                    % Returning the union in order

[~, mapA] = ismember(A.var, C.var);    % Creating Maps
[~, mapB] = ismember(B.var, C.var);    % Creating Maps

C.card = zeros(1, length(C.var));
C.card(mapA) = A.card;
C.card(mapB) = B.card;                     % Setting cardinalties although some redundant

C.val = zeros(1, prod(C.card));

assignments = IndexToAssignment(1:prod(C.card), C.card);  % Creating the assignment table for each index of the DESIRED .val representation
indxA = AssignmentToIndex(assignments(:, mapA), A.card);  % in order to access values as given in A structure
indxB = AssignmentToIndex(assignments(:, mapB), B.card);  % in order to access values as given in B stucture

for i = 1:prod(C.card)
    C.val(i) = A.val(indxA(i))*B.val(indxB(i));
end

end
