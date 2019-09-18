clear; close all; clc;

f = @(x) [x(2), 0.3*(4*x(1)-x(1)^3-x(2))];

[x,y] = meshgrid(linspace(-5,5,100),linspace(-5,5,100));

x_test = [x(:), y(:)];

F = zeros(size(x_test,1),2);

for i = 1 : size(x_test,1)
    F(i,:) = f(x_test(i,:));
end

streamslice(x,y,reshape(F(:,1),100,[]),reshape(F(:,2),100,[]));