clear; close all; clc;

num_points = 100000;
a = rand(num_points,1);

tic;
speye(num_points)./a;
toc;

tic;
spdiags(1./a, 0, num_points, num_points);
toc;

tic;
sparse(1:num_points,1:num_points,1./a,num_points,num_points);
toc;