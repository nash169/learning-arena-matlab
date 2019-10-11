function f = calc_embedding(obj)
%CALC_EMBEDDING Summary of this function goes here
%   Detailed explanation goes here
f = cell(3,1);
x = obj.data_{1};
y = obj.data_{2};


f{1} = sin(x);
f{2} = obj.params_.width*y;
f{3} = sign(x).*(cos(x) - 1);
end

