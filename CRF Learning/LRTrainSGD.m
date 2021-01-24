function [cost, thetaOpt] = LRTrainSGD(trainAugment, modelParams, iterations)

    %load('optimal_augmented_theta_after_2500.mat')

    gradFn = @(theta, i)LRCost_OCR_SGD(trainAugment, theta, i, modelParams);

    [cost, thetaOpt] = SGD(gradFn, zeros(2366,1), iterations);

end
