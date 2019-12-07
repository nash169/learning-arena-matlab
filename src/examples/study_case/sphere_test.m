clear; close all; clc

% Create sphere
res = 50;
[theta, phi] = meshgrid(linspace(0, pi, res),linspace(0, 2*pi, res));
x = sin(theta).*cos(phi);
y = sin(theta).*sin(phi);
z = cos(theta);

figure (1)
surf(x,y,z)
hold on
scatter3(sin(0).*cos(0), sin(0).*sin(0), cos(0) ,50, 'r', 'filled')
axis equal


[x, y] = meshgrid(linspace(-5, 5, res),linspace(-5, 5, res));

X = [x(:), y(:)];

f = sum(X.*X,2);

figure(2)
surf(x,y,reshape(f, res, []))
figure (3)
contourf(x,y,reshape(f, res, []))
