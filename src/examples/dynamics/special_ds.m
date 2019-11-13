clear; close all; clc;

[x,y] = meshgrid(linspace(-5,5,100),linspace(-5,5,100));
x_test = [x(:), y(:)];

%% Duffing equation
f_duff = @(x) [2*x(1)-x(1)*x(2), 2*x(1)^2-x(2)];

F_duff = zeros(size(x_test,1),2);

for i = 1 : size(x_test,1)
    F_duff(i,:) = f_duff(x_test(i,:));
end

figure (1)
streamslice(x,y,reshape(F_duff(:,1),100,[]),reshape(F_duff(:,2),100,[]));
title("Duffing equation")

%% Van Der Pol oscillator
f_pol = @(x) [x(2), 0.3*(4*x(1)-x(1)^3-x(2))];

F_pol = zeros(size(x_test,1),2);

for i = 1 : size(x_test,1)
    F_pol(i,:) = f_pol(x_test(i,:));
end

figure (2)
streamslice(x,y,reshape(F_pol(:,1),100,[]),reshape(F_pol(:,2),100,[]));
title("Van der Pol oscillator")