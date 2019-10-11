function f = calc_embedding(obj)
%CALC_EMBEDDING Summary of this function goes here
%   Detailed explanation goes here
f = cell(3,1);
% x = obj.data_{1};
% y = obj.data_{2};

% [x,y] = meshgrid(1.5 * pi * (1 + 2 * linspace(0,1,100)), 0:1);
[x,y] = meshgrid(linspace(1.5*pi,4.5*pi,100), linspace(0,1,100));

f{1} = x.*cos(x);
f{2} = obj.params_.width*y;
f{3} = x.*sin(x);
end