function [cost_arr, thetaOpt] = SGD(gradFunc, theta0, maxIter)

 global cost_arr
 
theta0 = theta0';
thetaOpt = zeros(size(theta0));
thetaOpt = thetaOpt';
theta = theta0;

for dummy_iter = 1:maxIter
    [cost, grad] = gradFunc(theta, dummy_iter);
    ak = 1/(1+0.05*(dummy_iter));
    theta = theta-ak*grad;
    cost_arr{dummy_iter} = cost;
end 

thetaOpt = theta;

end

