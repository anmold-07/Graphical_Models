%% Third Party Code to store feature functions

function features = ComputeUnconditionedSingletonFeatures (len, modelParams)
% Creates indicator features on assignments to single variables in the
% sequence.

nSingleFeatures = len * modelParams.numHiddenStates;  % len * 26
features(nSingleFeatures) = EmptyFeatureStruct();     % sample struct

K = modelParams.numHiddenStates; % 26 
featureIdx = 0;

for st = 1:K   % 1:26
    paramVal = st; 
    for v = 1:len   % 1:3 example
        featureIdx = featureIdx + 1;    % 
        features(featureIdx).var = v;   
        features(featureIdx).assignment = st;
        features(featureIdx).paramIdx = paramVal;

    end
end

end
