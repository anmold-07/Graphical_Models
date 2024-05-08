clc 
clear all

keys = {'A', 'S', 'L', 'T', 'E', 'X', 'B', 'F'};
value = {1, 2, 3, 4, 5, 6, 7, 8};
Let_to_Num = containers.Map(keys, value);
Num_to_Let = containers.Map(value, keys);

probab.input(1) = struct('Var_Name', [Let_to_Num('A')], 'Cardinality', [2], 'Probability_Values', [0.6 0.4]);
probab.input(2) = struct('Var_Name', [Let_to_Num('S')], 'Cardinality', [2], 'Probability_Values', [0.8 0.2]);
probab.input(3) = struct('Var_Name', [Let_to_Num('L')], 'Cardinality', [2], 'Probability_Values', [0.8 0.2]);
probab.input(4) = struct('Var_Name', [Let_to_Num('T'), Let_to_Num('A')], 'Cardinality', [2, 2], 'Probability_Values', [0.8 0.2 0.3 0.7]);
probab.input(5) = struct('Var_Name', [Let_to_Num('E'), Let_to_Num('L'), Let_to_Num('T')], 'Cardinality', [2, 2, 2], 'Probability_Values', [0.8 0.2 0.7 0.3 0.6 0.4 0.1 0.9]);
probab.input(6) = struct('Var_Name', [Let_to_Num('X'), Let_to_Num('E')], 'Cardinality', [2, 2], 'Probability_Values', [0.8 0.2 0.1 0.9]);
probab.input(7) = struct('Var_Name', [Let_to_Num('B'), Let_to_Num('S')], 'Cardinality', [2, 2], 'Probability_Values', [0.7 0.3 0.3 0.7]);
probab.input(8) = struct('Var_Name', [Let_to_Num('F'), Let_to_Num('B'), Let_to_Num('E')], 'Cardinality', [2, 2, 2], 'Probability_Values', [0.9 0.1 0.8 0.2 0.7 0.3 0.2 0.8]);

% Boundary Initializations;
PI.A = struct('Var_Name', [Let_to_Num('A')], 'Cardinality', [2], 'Probability_Values', [0.6 0.4]);
LAMBDA.A = struct('Var_Name', [Let_to_Num('A')], 'Cardinality', [2], 'Probability_Values', [1 1]);

PI.L = struct('Var_Name', [Let_to_Num('L')], 'Cardinality', [2], 'Probability_Values', [0.8 0.2]);
LAMBDA.L = struct('Var_Name', [Let_to_Num('L')], 'Cardinality', [2], 'Probability_Values', [1 1]);

PI.S = struct('Var_Name', [Let_to_Num('S')], 'Cardinality', [2], 'Probability_Values', [0.8 0.2]);
LAMBDA.S = struct('Var_Name', [Let_to_Num('S')], 'Cardinality', [2], 'Probability_Values', [1 1]);

% Evindence Initializations;
PI.X = struct('Var_Name', [Let_to_Num('X')], 'Cardinality', [2], 'Probability_Values', [0 1]);
LAMBDA.X = struct('Var_Name', [Let_to_Num('X')], 'Cardinality', [2], 'Probability_Values', [0 1]);

PI.F = struct('Var_Name', [Let_to_Num('F')], 'Cardinality', [2], 'Probability_Values', [1 0]);
LAMBDA.F = struct('Var_Name', [Let_to_Num('F')], 'Cardinality', [2], 'Probability_Values', [1 0]);

% Forming PI(T)
temp = Product(probab.input(4), PI.A);
PI.T = Max_Marginalization(temp, [Let_to_Num('A')]);

% Computing PI(E)
temp = Product(probab.input(5), Product(PI.T, PI.L));
PI.E = Max_Marginalization(temp,[Let_to_Num('L'), Let_to_Num('T')]);

% Computing PI(B)
temp = Product(probab.input(7), PI.S);
PI.B = Max_Marginalization(temp,[Let_to_Num('S')]);

% Computing LAMBDA(B)
temp = Product(probab.input(6), LAMBDA.X);
LAMBDA_X_TO_E = Max_Marginalization(temp, [Let_to_Num('X')]);
PI_E_TO_F = Product(PI.E, LAMBDA_X_TO_E);

temp = Product(probab.input(8), PI_E_TO_F);
temp_1 = Max_Marginalization(temp, [Let_to_Num('E')]);
temp_2 = Product(temp_1, LAMBDA.F);
LAMBDA.B = Max_Marginalization(temp_2, [Let_to_Num('F')]);

% Computing LAMBDA(E)
temp = Product(probab.input(8), PI.B);
temp_1 = Max_Marginalization(temp, [Let_to_Num('B')]);
temp_2 = Product(temp_1, LAMBDA.F);
LAMBDA_F_TO_E = Max_Marginalization(temp_2, [Let_to_Num('F')]);
LAMBDA.E = Product(LAMBDA_F_TO_E, LAMBDA_X_TO_E);

% Computing LAMBDA(T)
temp = Product(probab.input(5), PI.L);
temp_1 = Max_Marginalization(temp, [Let_to_Num('L')]);
temp_2 = Product(temp_1, LAMBDA.E);
LAMBDA_E_TO_T = Max_Marginalization(temp_2, [Let_to_Num('E')]);
LAMBDA.T = LAMBDA_E_TO_T;

% Computing LAMBDA(S)
temp = Product(probab.input(7), LAMBDA.B);
LAMBDA_B_TO_S = Max_Marginalization(temp, [Let_to_Num('B')]);
LAMBDA.S = LAMBDA_B_TO_S;

% Computing LAMBDA(L)
temp = Product(probab.input(5), PI.T);
temp_1 = Max_Marginalization(temp, [Let_to_Num('T')]);
temp_2 = Product(temp_1, LAMBDA.E);
LAMBDA_T_TO_E = Max_Marginalization(temp_2, [Let_to_Num('E')]);
LAMBDA.L = LAMBDA_T_TO_E;

% Computing LAMBDA(A)
temp = Product(probab.input(4), LAMBDA.T);
LAMBDA_T_TO_A = Max_Marginalization(temp, [Let_to_Num('T')]);
LAMBDA.A = LAMBDA_T_TO_A;

% Calculating Beliefs;
most_probable_assignment = [];

temp = Product(LAMBDA.A, PI.A);
A_1 = normalization(temp.Probability_Values);
[value, index] = max(A_1);
display(strcat('Random Variable '," ", Num_to_Let(1), ' takes MPE assignment ', " ",  string(rem(index, 2))))

temp = Product(LAMBDA.S, PI.S);
S_2 = normalization(temp.Probability_Values);
[value, index] = max(S_2);
display(strcat('Random Variable '," ", Num_to_Let(2), ' takes MPE assignment'," ", string(rem(index, 2))))

temp = Product(LAMBDA.L, PI.L);
L_3 = normalization(temp.Probability_Values);
[value, index] = max(L_3);
display(strcat('Random Variable '," ", Num_to_Let(3), ' takes MPE assignment'," ", string(rem(index, 2))))

temp = Product(LAMBDA.T, PI.T);
T_4 = normalization(temp.Probability_Values);
[value, index] = max(T_4);
display(strcat('Random Variable '," ", Num_to_Let(4), ' takes MPE assignment'," ", string(rem(index, 2))))

temp = Product(LAMBDA.E, PI.E);
E_5 = normalization(temp.Probability_Values);
[value, index] = max(E_5);
display(strcat('Random Variable', " ", Num_to_Let(5), ' takes MPE assignment'," ", string(rem(index, 2))))

temp = Product(LAMBDA.B, PI.B);
B_7 = normalization(temp.Probability_Values);
[value, index] = max(B_7);
display(strcat('Random Variable', " ", Num_to_Let(7), ' takes MPE assignment'," ", string(rem(index, 2))))

