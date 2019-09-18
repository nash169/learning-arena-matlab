function D = ShortestPath(D)
%SHORTESTPATH Summary of this function goes here
%   Detailed explanation goes here
D(D==0) = inf;
m = size(D,1);

for i = 1:m
    for j = 1:m
        for k = 1:m
            D(i,j) = min(D(i,j), D(i,k)+D(k,j));
        end
    end
end

D(isinf(D)) = 0;

end

