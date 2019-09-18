function [f,g] = test_function(x)
%FUNTOOPT Summary of this function goes here
%   Detailed explanation goes here
f = (x(1) -2)^2 + 2*(x(2)-1)^2;
g = [2*(x(1) -2); 4*(x(2)-1)];
end

