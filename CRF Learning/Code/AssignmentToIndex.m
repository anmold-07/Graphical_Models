function I = AssignmentToIndex(A, D)

D = D(:)'; 

if (any(size(A) == 1))
    I = cumprod([1, D(1:end - 1)]) * (A(:) - 1) + 1;
else
    I = sum(repmat(cumprod([1, D(1:end - 1)]), size(A, 1), 1) .* (A - 1), 2) + 1;
end

end
