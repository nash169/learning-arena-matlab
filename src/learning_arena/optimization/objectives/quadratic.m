function [f,g] = quadratic(x, W)
%QUADRATIC_OBJ Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2; W = eye(length(x)); end

f = x'*W*x;
g = (W + W')*x;
end

