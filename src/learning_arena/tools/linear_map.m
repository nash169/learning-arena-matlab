function y = linear_map(x, xmin, xmax, ymin, ymax)
%RESCALE_INVERT Summary of this function goes here
%   Detailed explanation goes here

m = (ymin - ymax)/(xmin-xmax);
q = ymin - m*xmin;

y = m*x + q;
end

