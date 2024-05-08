function [cost, grad] = LRCost_OCR_SGD(trainAugment, theta, iter, modelParams)

    i = mod(iter, size(trainAugment, 2)) + 1;

    [NLL, GRAD] = sample_negative_log_likelihood(trainAugment(i).X, trainAugment(i).y, theta, modelParams);
    
    % Calculate gradient
    grad = GRAD;
    
    % Calculate cost function
    cost = NLL;
    
    display(cost)
    %display(cost)
 
end
