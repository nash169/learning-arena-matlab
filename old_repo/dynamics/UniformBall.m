function [X] = UniformBall(center,radius,n_samples)
%UNIFORMBALL Summary of this function goes here
%   Detailed explanation goes here

phi = 2*pi*rand(n_samples,1);
theta = pi*rand(n_samples,1);
r = radius*rand(n_samples,1);
X = repmat(center, n_samples,1) + [ r.*sin(theta).*cos(phi), r.*sin(theta).*sin(phi), r.*cos(theta)];
end

