function x = ball_uniform(center, radius, num_points)
%BALL_UNIFORM Summary of this function goes here
%   This function samples uniformly indside the n-sphere

d = length(center);
x = randn(num_points, d);
x = x./vecnorm(x, 2, 2);
radius = radius*rand(num_points,1).^(1/d);
x = center + radius.*x;
end
