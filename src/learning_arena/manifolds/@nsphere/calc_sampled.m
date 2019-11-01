function x = calc_sampled(obj, num_points)
%CALC_SAMPLED Summary of this function goes here
%   Detailed explanation goes here

x = randn(num_points,3);
x = x./vecnorm(x, 2, 2);
x = obj.params_.center + obj.params_.radius*x;

% x = disk_uniform(obj.params_.center, obj.params_.radius, num_points)
end

