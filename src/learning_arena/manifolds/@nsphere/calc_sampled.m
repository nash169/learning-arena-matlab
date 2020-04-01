function x = calc_sampled(obj, num_points)
%CALC_SAMPLED Summary of this function goes here
%   Detailed explanation goes here

% x = randn(num_points,3);
% x = x./vecnorm(x, 2, 2);
% x = obj.params_.center + obj.params_.radius*x;

theta = 2*pi*rand(num_points, 1);
phi = acos(1 - 2*rand(num_points, 1));

x = obj.embedding([theta,phi]);

% x = disk_uniform(obj.params_.center, obj.params_.radius, num_points)
end

