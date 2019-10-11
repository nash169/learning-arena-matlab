function x = disk_uniform(center, radius, num_points)
%DISK_UNIFORM Summary of this function goes here
%   Detailed explanation goes here
d = length(center);

x = randn(num_points, d);
x = x./vecnorm(x, 2, 2);
x = center + radius*x;
end

