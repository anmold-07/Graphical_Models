function factors = ComputeAllSimilarityFactors (images, K)
% This function computes all of the similarity factors for the images in one word.
% Input:
%   images: An array of structs containing the 'img' value for each
%     character in the word.
%   K: The alphabet size (accessible in imageModel.K for the provided
%     imageModel).
%
% Output:
%   factors: Every similarity factor in the word. You should use
%     ComputeSimilarityFactor to compute these.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

n = length(images);
nFactors = nchoosek (n, 2);

factors = repmat(struct('var', [], 'card', [], 'val', []), nFactors, 1);

% Your code here:
dummy_total = 1;

for first = 1:(n-1)
    for second = (first+1):n
        factors(dummy_total) = ComputeSimilarityFactor(images, K, first, second);
        dummy_total = dummy_total + 1;
    end
end

end