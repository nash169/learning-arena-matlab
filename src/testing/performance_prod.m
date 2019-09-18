clear; close all; clc;

dim = 2;
num = 10000000;

a = rand(dim*num,dim);
b = rand(dim*num,dim);

tic;
c = matrix_prod(a,b);
toc;

tic;
A = blk_matrix(a);
toc;
tic;
B = blk_matrix(b);
toc;
tic;
C = A*B;
toc;