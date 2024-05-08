function C = Product(A, B)

C.Var_Name = union(A.Var_Name, B.Var_Name); 

[dummy, mapA] = ismember(A.Var_Name, C.Var_Name);    
[dummy, mapB] = ismember(B.Var_Name, C.Var_Name);

C.Cardinality = zeros(1, length(C.Var_Name));
C.Cardinality(mapA) = A.Cardinality;
C.Cardinality(mapB) = B.Cardinality;  

assignments = conv_to_assignment(1:prod(C.Cardinality), prod(C.Cardinality));  % Creating the assignment table for each index of the DESIRED .val representation

assignments(:, mapA);
assignments(:, mapB);

indxA = conv_to_index(assignments(:, mapA), A.Cardinality);  % in order to access values as given in A structure
indxB = conv_to_index(assignments(:, mapB), B.Cardinality);

for i=1:prod(C.Cardinality)
    C.Probability_Values(i)=A.Probability_Values(indxA(i))*B.Probability_Values(indxB(i));
end

end
