clear all
clc
%%  Combining Datasets;
CRF_model_parameters.numHiddenStates = 26;   % Cardinality of hidden variables Y is 26 (26 posible letters)
CRF_model_parameters.lambda = 0.003;
CRF_model_parameters.numObservedStates = 2;  % pixels takes values 1 or 0, therefore, only two observed states.
load('Dataset_1.mat');

% Processing Dataset_2 for training the CRF model;
load('Dataset_2.mat');
for iter_allwords = 1:length(allWords)
    image = [];
    truth = [];
    for iter_image = 1:3
        test = allWords{iter_allwords, 1}(iter_image).img;
        temp = test(1:2:end,1:2:end);
        dummy_reshape = reshape(temp, [1, 32]);
        image = [image; dummy_reshape];   
        truth = [truth allWords{iter_allwords, 1}(iter_image).groundTruth];
    end
    trainAugment(iter_allwords).X = image;
    trainAugment(iter_allwords).X = trainAugment(iter_allwords).X + 1;
    trainAugment(iter_allwords).y = truth;
end 
for iter = 101:320
    trainAugment(iter).X = trainData(iter-100).X;
    trainAugment(iter).y = trainData(iter-100).y;
end
%% Training the CRF model with desired number of iterations
number_of_training_iterations = 1000;

[cost, thetaOPT] = LRTrainSGD(trainData, CRF_model_parameters, number_of_training_iterations); 
%% Already trained prior; Optimal theta parameter, Predicting Anmol

load('anmolb.mat')
CRF_model_parameters.numHiddenStates = 26;   % Cardinality of hidden variables Y is 26 (26 posible letters)
CRF_model_parameters.lambda = 0.003;
CRF_model_parameters.numObservedStates = 2;

featureSet = GenerateAllFeatures(anmol, CRF_model_parameters); % Struct with fields
% Convert from Features (from featureSet) to Factors!
factornum = 1;
factors(1) = struct('var',featureSet.features(1).var,'card',CRF_model_parameters.numHiddenStates*ones(1,length(featureSet.features(1).var)),'val',zeros(1,CRF_model_parameters.numHiddenStates^length(featureSet.features(1).var)));
L = length(featureSet.features); % for each feature

% Filling in factor values;
for i = 1:L
    
    factorbelong = 0;
    
    for j = 1:factornum
        if (length(featureSet.features(i).var)==length(factors(j).var)) && (sum(featureSet.features(i).var==factors(j).var)==length(factors(j).var))
            factorbelong=j;
        end
    end
    
    if factorbelong == 0
        
        factornum = factornum + 1;
        factors(factornum) = struct('var',featureSet.features(i).var, 'card',CRF_model_parameters.numHiddenStates*ones(1,length(featureSet.features(i).var)), 'val',zeros(1,CRF_model_parameters.numHiddenStates^length(featureSet.features(i).var)));
        factorbelong = factornum;
        
    end
    
    indx = AssignmentToIndex(featureSet.features(i).assignment, CRF_model_parameters.numHiddenStates*ones(1,length(featureSet.features(i).var)));
    
    % Filling factor values
    factors(factorbelong).val(indx) = factors(factorbelong).val(indx) + thetaOPT(featureSet.features(i).paramIdx);

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

display('--------------------------------------------------------------')
[value, index] = max(calibrated.cliqueList(1).val);
IndexToAssignment(index, [26, 26])

[value, index] = max(calibrated.cliqueList(2).val);
IndexToAssignment(index, [26, 26])

[value, index] = max(calibrated.cliqueList(3).val);
IndexToAssignment(index, [26, 26])

[value, index] = max(calibrated.cliqueList(4).val);
IndexToAssignment(index, [26, 26])

[value, index] = max(calibrated.cliqueList(5).val);
IndexToAssignment(index, [26, 26])
