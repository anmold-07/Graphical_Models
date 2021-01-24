function B = Sum_Marginalization(A, V)

[B.Var_Name, mapB] = setdiff(A.Var_Name, V);
B.Cardinality = A.Cardinality(mapB);
B.Probability_Values = zeros(1, prod(B.Cardinality));

assignments = conv_to_assignment(1:length(A.Probability_Values), prod(A.Cardinality)); 
indxB = conv_to_index(assignments(:, mapB), B.Cardinality);               

for i=1:prod(B.Cardinality)
    for j=1:prod(A.Cardinality)
        if indxB(j)==i
            B.Probability_Values(i)=B.Probability_Values(i)+A.Probability_Values(j);
        end
    end
end 

end