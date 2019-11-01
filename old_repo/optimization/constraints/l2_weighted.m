function [c, ceq, DC, DCeq] = l2_weighted(x,W)
%L2_WEIGHTED Summary of this function goes here
%   Detailed explanation goes here
c = x'*W*x - 1;
ceq = [];

if nargout > 2
    DC= (W + W')*x;
    DCeq = [];
end
end

