clear; close all; clc;

X = [10, 50;
    40, 50;
    50, 50;
    55, 50;
    ];

m = size(X, 1);
weights = [1, 1, 1, 1];

myrbf = rbf('sigma', 10.);
psi = kernel_expansion('kernel', myrbf, 'reference', X, 'weights', weights);

K = myrbf.gramian(X, X);
G = 0.5 * eye(m);
G(1, 2) = 1;
G(2, 3) = 1;

[V, D] = eigs(K);

figure
plot(1:m, V(:, 1), '-o')

figure
plot(1:m, diag(D), '-o')