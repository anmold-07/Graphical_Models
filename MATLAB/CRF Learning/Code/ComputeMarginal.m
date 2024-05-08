function M = ComputeMarginal(V, F, E)

if (numel(F) == 0)
      M = struct('var', [], 'card', [], 'val', []);      
      return;
end

factor = ComputeJointDistribution(F);

factor = ObserveEvidence(factor,E);

factor.val = factor.val/(sum(factor.val));

[resulting_factor, ~] = setdiff(factor.var,V);

M = FactorMarginalization(factor,resulting_factor);

end
