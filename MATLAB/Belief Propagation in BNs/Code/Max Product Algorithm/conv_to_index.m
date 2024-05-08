function index = conv_to_index(A, len)
% Given Input Vector Consisting of Sequence 
size_temp = size(A);

for j = 1:size_temp(1)
    temp = 0; 
     for i = 1:size_temp(2)
        temp = temp + (A(j, i) - 1)*(2^(i-1));
     end
   index(j, 1) = temp + 1;
end

end