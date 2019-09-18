function [X] = UniformDisk(center,radius,n_samples)
%UNIFORMDISK Summary of this function goes here
%   Detailed explanation goes here

theta = 2*pi*rand(n_samples,1);
r = radius*rand(n_samples,1);
X = repmat(center, n_samples,1) + [r.*cos(theta), r.*sin(theta)];
end

