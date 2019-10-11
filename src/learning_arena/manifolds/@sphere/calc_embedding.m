function f = calc_embedding(obj)
%CALC_EMBEDDING Summary of this function goes here
%   Detailed explanation goes here
f = cell(3,1);
theta = obj.data_{1};
phi = obj.data_{2};

f{1} = obj.params_.center(1) + obj.params_.radius*sin(theta).*cos(phi);
f{2} = obj.params_.center(2) + obj.params_.radius*sin(theta).*sin(phi);
f{3} = obj.params_.center(3) + obj.params_.radius*cos(theta);
end

