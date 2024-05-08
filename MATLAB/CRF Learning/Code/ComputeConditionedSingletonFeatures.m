%% Third Party Code for Feature Fucntions

% Creatures feature structs for indicator features on single values on y.
% They are "conditioned," since different elements of the weight vector are
% used depending on the actual observation.
function features = ComputeConditionedSingletonFeatures (X, modelParams)


    [len, featureSize] = size(X);

    K = modelParams.numHiddenStates;              % 26
    L = modelParams.numObservedStates;            % 2

    numFeatures = len * K * featureSize;          % len * 26 * 32 (size of image)
    features(numFeatures) = EmptyFeatureStruct(); 

    featureIdx = 0;

    for hiddenSt = 1:K  % 1:26
        for featureNum = 1:featureSize  % 1:32
            for v = 1:len  % 1:len                  
                featureIdx = featureIdx + 1;
                obs = X(v, featureNum);
                features(featureIdx).var = v;
                features(featureIdx).assignment = hiddenSt;
                features(featureIdx).paramIdx = sub2ind([L featureSize K], obs, featureNum, hiddenSt);
            end
        end
    end

end
