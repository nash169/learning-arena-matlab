clear; close all; clc;

num_points = 5000;

A = rand(num_points);
A = 0.5*(A+A') + eye(num_points)*num_points;
b = rand(num_points, 1);

A = (A + A')/2 + eye(num_points)*1e-5;

% tic;
% x1 = A\b;
% toc;

tic;
L = chol(A,'lower');
opts1.LT = true;
opts2.UT = true;
u = linsolve(L,eye(num_points),opts1);
S_inv = linsolve(L',u, opts2);
% x2 = L'\(L\b);
toc;

tic;
A_inv = inv(A);
% x3 = A_inv*b;
toc;

tic;
opts.SYM = true;
D_inv = linsolve(A,eye(num_points), opts);
toc;