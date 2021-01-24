% function [nll, grad] = sample_negative_log_likelihood(X, y, theta, modelParams)
% returns the negative log-likelihood and its gradient, given a CRF with parameters theta,
% on data (X, y)
% Outputs:
% nll          Negative log-likelihood of the data.    (scalar)
% grad         Gradient of nll with respect to theta   (numParams x 1 vector)

function [nll, grad] = sample_negative_log_likelihood(X, y, theta, modelParams)
    
featureSet = GenerateAllFeatures(X, modelParams); % Struct with fields
    
nll = 0;
grad = zeros(size(theta));   % 2366 parameters always.
            
% Convert from Features (from featureSet) to Factors!
factornum = 1;
factors(1) = struct('var',featureSet.features(1).var,'card',modelParams.numHiddenStates*ones(1,length(featureSet.features(1).var)),'val',zeros(1,modelParams.numHiddenStates^length(featureSet.features(1).var)));
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

% Weighted and Data Feature Counts
weighted_feature_counts = zeros(1,featureSet.numParams);
data_feature_counts = zeros(1,featureSet.numParams);

for i = 1:L
    countthat = 1;    
    % Find which features are fired for this data instance (X, y)
    for j = 1:length(featureSet.features(i).var)
        if y(featureSet.features(i).var(j)) ~= featureSet.features(i).assignment(j)
            countthat = 0; 
        end
    end
    
    % Only if feature true then add weight
    if countthat == 1
        weighted_feature_counts(featureSet.features(i).paramIdx) = weighted_feature_counts(featureSet.features(i).paramIdx) + theta(featureSet.features(i).paramIdx);
        data_feature_counts(featureSet.features(i).paramIdx) = data_feature_counts(featureSet.features(i).paramIdx) + 1;
    end
end

% Factors Available;
junction_tree = CreateJunctionTree(factors);
[calibrated, logZ] = JunctionTreeCalibrate(junction_tree, 0); % since require max_product

% Model Feature Counts
model_feature_counts = zeros(1, featureSet.numParams);

for i = 1:length(calibrated.cliqueList)
    calibrated.cliqueList(i).val = calibrated.cliqueList(i).val/sum(calibrated.cliqueList(i).val);
end

for i = 1:L   % for each feature compute marginal probability to calculate model expectation
    
    for j = 1:length(calibrated.cliqueList)
        countx = 0;
        for m = 1:length(featureSet.features(i).var)
            for n = 1:length(calibrated.cliqueList(j).var)
                if featureSet.features(i).var(m) == calibrated.cliqueList(j).var(n)
                    countx = countx + 1;
                end
            end
        end
        
        if countx == length(featureSet.features(i).var)
            use_this_clique_index = j;    % finding relevant clique for current iterate feature
            break;
        end     
    end
     
    if length(featureSet.features(i).var) == length(calibrated.cliqueList(use_this_clique_index).var) % if equal to clique size
        MARGINAL = calibrated.cliqueList(use_this_clique_index);  
        
    else % if not equal to clique size
        marg_out = setdiff(calibrated.cliqueList(use_this_clique_index).var, featureSet.features(i).var);
        MARGINAL = FactorMarginalization(calibrated.cliqueList(use_this_clique_index), marg_out);
    end
        
    indx = AssignmentToIndex(featureSet.features(i).assignment, MARGINAL.card);
    model_feature_counts(featureSet.features(i).paramIdx) = model_feature_counts(featureSet.features(i).paramIdx) + MARGINAL.val(indx);       
end

nll = logZ - sum(weighted_feature_counts) + (modelParams.lambda)/2*sum(theta.*theta);
grad = model_feature_counts - data_feature_counts + (modelParams.lambda)*theta;

end