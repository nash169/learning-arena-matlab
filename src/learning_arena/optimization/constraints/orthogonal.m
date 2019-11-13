function [c, ceq, DC, DCeq] = orthogonal(x, U, W)
%ORTHOGONAL_TO Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3; W = eye(length(x)); end

c = [];
ceq = x'*W*U;

if nargout > 2
    DC = [];
    DCeq = W*U;
end
end

