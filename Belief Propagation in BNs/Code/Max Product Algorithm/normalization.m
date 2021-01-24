function B = normalization(A)
B = zeros(2, 1);

TEMP_1 = A(1);
TEMP_2 = A(2);

B(1) = TEMP_1/(TEMP_1 + TEMP_2);
B(2) = TEMP_2/(TEMP_1 + TEMP_2);

return

end