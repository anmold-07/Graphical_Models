function factors = ComputeEqualPairwiseFactors (images, K)
% This function computes the pairwise factors for one word in which every
% factor value is set to be 1.
%
% Input:
%   images: An array of structs containing the 'img' value for each
%     character in the word.
%   K: The alphabet size (accessible in imageModel.K for the provided
%     imageModel).
%
% Output:
%   factors: The pairwise factors for this word. Every entry in the factor
%     vals should be 1.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

n = length(images);

factors = repmat(struct('var', [], 'card', [], 'val', []), n - 1, 1);

% Your code here:
for dummy_character = 1:(n-1)
    factors(dummy_character).var = [dummy_character, dummy_character + 1];
    factors(dummy_character).card = [K, K];
    for j=1:(K*K)
        dummy_assignment = IndexToAssignment(j, [K,K]);
        factors(dummy_character).val(j,1) = 1/(K*K);
    end
end
end
