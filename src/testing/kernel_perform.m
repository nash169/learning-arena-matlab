clear; close all; clc;

num_points = 20000;
dim = 2;
a = rand(num_points,dim);

% kpar.sigma = 5.;
% [k, dk, d2k] = Kernels('gauss', kpar);

myrbf = rbf('sigma', 1., 'sigma_n', 1.);

% tic;
% myrbf.set_data(a,a);
% toc;

tic;
myrbf.kernel(a,a);
toc;

% tic;
% k(a,a);
% toc;