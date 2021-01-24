function F = SetValueOfAssignment(F, A, v, VO)

if (nargin == 3)
    indx = AssignmentToIndex(A, F.card);
else
    map = zeros(length(F.var), 1);
    for i = 1:length(F.var)
        map(i) = find(VO == F.var(i));
    end
    indx = AssignmentToIndex(A(map), F.card);
end

F.val(indx) = v;
