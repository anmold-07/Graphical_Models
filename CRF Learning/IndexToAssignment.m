% IndexToAssignment Convert index to variable assignment.

function A = IndexToAssignment(I, D)

D = D(:)';  % ensure that D is a row vector
A = mod(floor(repmat(I(:) - 1, 1, length(D)) ./ repmat(cumprod([1, D(1:end - 1)]), length(I), 1)), ...
        repmat(D, length(I), 1)) + 1;
  
end
