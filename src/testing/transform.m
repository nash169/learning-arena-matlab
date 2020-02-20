clear; close all; clc;

bounds = [0, 2*pi, 0, 1];
res = 100;
k = 5;

[x,y] = meshgrid(linspace(bounds(1),bounds(2),res), linspace(bounds(3),bounds(4),res));

x_dot = -x;
y_dot = -y;

figure
h = streamslice(x,y,x_dot,y_dot);
axis tight
grid on
set( h, 'Color', 'r' )

f1 = x.*cos(x);
f2 = k*y;
f3 = x.*sin(x);

[phi1,phi2,phi3] = meshgrid(linspace(min(min(f1)), max(max(f1)),res), ...
    linspace(min(min(f2)), max(max(f2)), res), ...
    linspace(min(min(f3)), max(max(f3)), res) ...
);

v = -(phi2.^2/k^2 + phi1.^2 + phi3.^2)/2;

figure
slice(phi1,phi2,phi3,v,f1,f2,f3)
colorbar
shading interp
hold on

% phi1_dot = phi2/k.*(cos(sqrt(phi1.^2 + phi3.^2)) - phi3);
% phi2_dot = k*sqrt(phi1.^2 + phi3.^2);
% phi3_dot = phi2/k.*(sin(sqrt(phi1.^2 + phi3.^2)) - phi1);

phi1_dot = -f1 + sqrt(f1.^2 + f3.^2).*f3;
phi2_dot = -f2;
phi3_dot = -f2 - sqrt(f1.^2 + f3.^2).*f1;

scale_factor = 0.005;
quiver3(f1(:),f2(:),f3(:),phi1_dot(:)*scale_factor,phi2_dot(:)*scale_factor,phi3_dot(:)*scale_factor, 'color', 'r', 'AutoScale','off')

% figure
% streamslice(phi1,phi2,phi3,phi1_dot,phi2_dot,phi3_dot,f1,f2,f3)

% surf(f1, f2, f3, -(f2.^2/k^2 + f1.^2 + f3.^2)/2,  'FaceAlpha', 0.5)
% shading interp
% axis equal
