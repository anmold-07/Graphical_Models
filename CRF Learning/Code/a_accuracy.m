% Compute Word predictions; length(testData)
clc
clear all
%% Combining Training data from various sources;
keys = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
value = {1, 2, 3, 4, 5, 6, 7, 8, 9 ,10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26};
Let_to_Num = containers.Map(keys, value);
Num_to_Let = containers.Map(value, keys);

%% Accracy Calculation on test Data;

a_word_accuracy = 0;
a_charac_accuracy = 0;
CRF_model_parameters.numHiddenStates = 26;   % Cardinality of hidden variables Y is 26 (26 posible letters)
CRF_model_parameters.lambda = 0.003;
CRF_model_parameters.numObservedStates = 2;
featureSet = GenerateAllFeatures(testData, CRF_model_parameters); % Struct with fields

for dummy_iter = 1:length(testData)
       
    
factornum = 1;
factors(1) = struct('var',featureSet.features(1).var,'card',CRF_model_parameters.numHiddenStates*ones(1,length(featureSet.features(1).var)),'val',zeros(1,CRF_model_parameters.numHiddenStates^length(featureSet.features(1).var)));
L = length(featureSet.features); % for each feature

% Filling in factor values from feature values;
for i = 1:L
    
    factorbelong = 0;
    
    for j = 1:factornum
        if (length(featureSet.features(i).var)==length(factors(j).var)) && (sum(featureSet.features(i).var==factors(j).var)==length(factors(j).var))
            factorbelong=j;
        end
    end
    
    if factorbelong == 0
        
        factornum = factornum + 1;
        factors(factornum) = struct('var',featureSet.features(i).var, 'card',modelParams.numHiddenStates*ones(1,length(featureSet.features(i).var)), 'val',zeros(1,modelParams.numHiddenStates^length(featureSet.features(i).var)));
        factorbelong = factornum;
        
    end
    
    indx = AssignmentToIndex(featureSet.features(i).assignment, modelParams.numHiddenStates*ones(1,length(featureSet.features(i).var)));
    
    % Filling factor values
    factors(factorbelong).val(indx) = factors(factorbelong).val(indx) + theta(featureSet.features(i).paramIdx);

end

% Exponentiaitng the factor values since dealing with log-linear model
for i=1:factornum
    for j=1:length(factors(i).val)
        factors(i).val(j)=exp(factors(i).val(j));
    end
end

% Factors Available;
junction_tree = CreateJunctionTree(factors);
[calibrated, logZ] = JunctionTreeCalibrate(junction_tree, 1); % since require max_product


% Character Level Accuracy;
dummy_characters = [];
for iter = 1:length(calibrated.cliqueList)    
    [value, index] = max(calibrated.cliqueList(iter).val);
    temp = IndexToAssignment(index, [26, 26]);
    dummy_characters = [dummy_characters temp];
end 
dummy_characters(2) = [];

dummy_sum = sum(dummy_characters == testData(dummy_iter).y);
if dummy_sum == 3
    a_word_accuracy = a_word_accuracy + 1;  
end
    a_charac_accuracy = a_charac_accuracy + dummy_sum;

end    

a_charac_accuracy = a_charac_accuracy*100/(3*80);
a_word_accuracy = a_word_accuracy*100/80;