function assignment = conv_to_assignment(index, length_of_assignment)
assignment = [];
for i = 1:length(index)
    temp = flip(de2bi(index(i)-1,log(length_of_assignment)/log(2),'left-msb')) + 1;
    assignment = [assignment; temp];
end

end