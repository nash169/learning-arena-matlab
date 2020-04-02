function x = calc_sampled(obj, num_points)
%CALC_SAMPLED Summary of this function goes here
%   Detailed explanation goes here

% Area fo the swiss roll (0,2pi extremes are considered, make it variable)
% Width of the swiss roll not included because it canceled out later
A = (pi*sqrt(1+4*pi^2) + log(sqrt(1+4*pi^2) + 2*pi)/2);

% Inverse trasform sampling using the curvature distribution
theta = sqrt(A^2*rand(num_points, 1).^2-1);
xi = rand(num_points, 1);

x = obj.embedding([theta,xi]);
end

