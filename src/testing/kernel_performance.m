clear; close all; clc;
[X,Y] = meshgrid(-10:.1:10);
Z = Y.*sin(X) - X.*cos(Y);

num_points = 90;

X_sampled = 20*rand(num_points) - 10;
Y_sampled = 20*rand(num_points) - 10;
Z_noisy = Y_sampled.*sin(X_sampled) - X_sampled.*cos(Y_sampled) + rand(num_points) - 0.5;

sigma = 3.5;
noise_std = 0.2;
signal_std = 6.2;
myrbf = rbf('sigma', sigma, 'sigma_n', noise_std, 'sigma_f', signal_std);

tic;
myrbf.kernel([X_sampled(:),Y_sampled(:)], [X_sampled(:),Y_sampled(:)]);
toc;