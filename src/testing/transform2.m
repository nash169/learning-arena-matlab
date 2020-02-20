clear; close all; clc;

sigma = 5;
my_rbf = rbf('sigma', sigma);
Xi_ref = [-25,-25];

a = -50; b = 50;
res = 100;
[xi1, xi2] = meshgrid(linspace(a,b,res), linspace(a,b,res));
Xi = [xi1(:), xi2(:)];

x1 = xi1;
x2 = xi2;
x3 = reshape(my_rbf.kernel(Xi,Xi_ref), res, []);

surf(x1, x2, x3, (x1.^2 + x2.^2)/2,'FaceAlpha', 0.7)
shading interp
colorbar
hold on

x1_dot = -x1;
x2_dot = -x2;
x3_dot = ((x1- Xi_ref(1)).*x3.*x1 + (x2- Xi_ref(2)).*x3.*x2)/sigma^4;

scale_factor = 0.05;
% quiver3(x1(:),x2(:),x3(:),x1_dot(:)*scale_factor,x2_dot(:)*scale_factor,x3_dot(:)*scale_factor, 'color', 'r','AutoScale','off')

num_samples = 1000;
xi1_sampled = a + (b-a)*rand(num_samples,1);
xi2_sampled = a + (b-a)*rand(num_samples,1);

x1_sampled = xi1_sampled;
x2_sampled = xi2_sampled;
x3_sampled = my_rbf.kernel([xi1_sampled,xi2_sampled],Xi_ref);

scatter3(x1_sampled, x2_sampled, x3_sampled, 'r', 'filled')