function x = calc_sampled(obj, num_points)
%CALC_SAMPLED Summary of this function goes here
%   Detailed explanation goes here

% Sample points using normal distribution
% x = disk_uniform(obj.params_.center, obj.params_.radius, num_points)

% Inverse trasform sampling using the curvature distribution
theta = acos(1 - 2*rand(num_points, 1));
phi = 2*pi*rand(num_points, 1);
x = obj.embedding([theta,phi]);
end

