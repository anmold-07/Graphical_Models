function B = FactorMaxMarginalization(A, V)

if (isempty(A.var) || isempty(V)), B = A; return; end

[B.var, mapB] = setdiff(A.var, V);                         % Creating the resulting variable after marginalization and the MAP from A to resulting;

if isempty(B.var)
  error('empty scope');
end

B.card = A.card(mapB);
B.val = zeros(1, prod(B.card));

assignments = IndexToAssignment(1:length(A.val), A.card); % Getting the table respresentation from which the assignments are to be done that is the parent;
indxB = AssignmentToIndex(assignments(:, mapB), B.card);  % Getting the indices in which the assignments are to be modifed

for i = 1:prod(B.card)
    for j = 1:prod(A.card)
        if indxB(j) == i
            B.val(i) = max(B.val(i), A.val(j));
        end
    end
end    
end
