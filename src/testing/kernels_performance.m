clear; close all; clc;

% Dataset
res = 100;
x_train = [50., 50.];
[x,y] = meshgrid(linspace(0,100,res), linspace(0,100,res));
x_test = [x(:), y(:)];

% Kernels' parameters
sigma = 5.;
weights = 1.;

% RBF kernel - class implementation from ansitropic parent
my_rbf = rbf;
my_rbf.set_params('length', -1/2/sigma^2);

tic;
my_rbf.get_kernel(x_train, x_test);
toc;

% RBF kernel - class implementation
my_rbf_old = rbf_old;
my_rbf_old.set_params('length', -1/2/sigma^2);

tic;
my_rbf_old.get_kernel(x_train, x_test);
toc;

% RBF kernel - anonymous function implementation
kpar.sigma = sigma;
[k, dk, d2k] = Kernels('gauss',kpar);

tic;
k(x_train,x_test);
toc;