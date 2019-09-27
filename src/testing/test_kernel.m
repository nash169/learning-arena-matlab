clear; close all; clc;

num_points = 10000;
dim = 2;
a = rand(num_points,dim);

kpar.sigma = 5.;
[k, dk, d2k] = Kernels('gauss', kpar);

myrbf = rbf('sigma', 5.);

tic;
myrbf.kernel(a,a);
toc;

tic;
k(a,a);
toc;
