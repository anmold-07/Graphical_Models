function Joint = ComputeJointDistribution(F)

if (numel(F) == 0)
     Joint = struct('var', [], 'card', [], 'val', []);      
     return;
end

Joint = F(1);
if numel(F)>1
    for i = 2:numel(F)
        Joint = FactorProduct(Joint,F(i));
    end
end

end

